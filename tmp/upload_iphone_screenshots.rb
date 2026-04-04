#!/opt/homebrew/opt/ruby/bin/ruby
# frozen_string_literal: true

require "fileutils"
$stdout.sync = true

ROOT = File.expand_path("..", __dir__)
FASTLANE_LIBEXEC = "/opt/homebrew/Cellar/fastlane/2.232.2/libexec"
ENV["GEM_HOME"] ||= FASTLANE_LIBEXEC
ENV["GEM_PATH"] ||= FASTLANE_LIBEXEC

require "fastimage"
require "spaceship"

APP_IDENTIFIER = "com.lunivo.app"
KEY_ID = "STDG5D3U5A"
ISSUER_ID = "5c3aee75-98b2-489d-b18e-c273d41d1e02"
KEY_FILEPATH = File.join(ROOT, "fastlane", "AuthKey_STDG5D3U5A.p8")
SOURCE_ROOT = File.join(ROOT, "fastlane", "screenshots", "iphone")
TEMP_ROOT = File.join(ROOT, "tmp", "prepared_iphone_screenshots")
DISPLAY_TYPE = Spaceship::ConnectAPI::AppScreenshotSet::DisplayType::APP_IPHONE_65
EXPECTED_SIZE = [1242, 2688].freeze
RESIZED_HEIGHT = "2715"
RESIZED_WIDTH = "1242"
CROPPED_HEIGHT = "2688"
CROPPED_WIDTH = "1242"

LOCALE_MAP = {
  "ar" => "ar-SA",
  "czech" => "cs",
  "danish" => "da",
  "dutch" => "nl-NL",
  "es-MX" => "es-MX",
  "finnish" => "fi",
  "fr" => "fr-FR",
  "greek" => "el",
  "heb" => "he",
  "hindi" => "hi",
  "hung" => "hu",
  "indonesian" => "id",
  "it" => "it",
  "jp" => "ja",
  "ko" => "ko",
  "malay" => "ms",
  "nor" => "no",
  "pl" => "pl",
  "pt-BR" => "pt-BR",
  "rom" => "ro",
  "ru" => "ru",
  "sw" => "sv",
  "thai" => "th",
  "turkish" => "tr",
  "uk" => "uk",
  "viet" => "vi",
  "zh" => "zh-Hans"
}.freeze

IMAGE_EXTENSIONS = %w[.jpg .jpeg .png].freeze
DRY_RUN = !ARGV.include?("--execute")

def image_file?(path)
  File.file?(path) && IMAGE_EXTENSIONS.include?(File.extname(path).downcase)
end

def sh!(*command)
  success = system(*command, out: File::NULL, err: File::NULL)
  return if success

  abort("Command failed: #{command.join(' ')}")
end

def locale_sources
  Dir.children(SOURCE_ROOT).sort.each_with_object({}) do |entry, hash|
    source_dir = File.join(SOURCE_ROOT, entry)
    next unless File.directory?(source_dir)
    next unless LOCALE_MAP.key?(entry)

    files = Dir.children(source_dir)
               .map { |name| File.join(source_dir, name) }
               .select { |path| image_file?(path) }
               .sort

    next if files.empty?

    hash[LOCALE_MAP.fetch(entry)] = {
      source_key: entry,
      files: files
    }
  end
end

def prepare_screenshots(source_files:, target_locale:)
  out_dir = File.join(TEMP_ROOT, target_locale)
  FileUtils.rm_rf(out_dir)
  FileUtils.mkdir_p(out_dir)

  source_files.each_with_index.map do |source_path, index|
    resized_path = File.join(out_dir, format("%02d_resized.jpg", index + 1))
    final_path = File.join(out_dir, format("%02d_1242x2688.jpg", index + 1))

    sh!("sips", "-s", "format", "jpeg", "--resampleHeightWidth", RESIZED_HEIGHT, RESIZED_WIDTH, source_path, "--out", resized_path)
    sh!("sips", "-s", "format", "jpeg", "--cropToHeightWidth", CROPPED_HEIGHT, CROPPED_WIDTH, resized_path, "--out", final_path)
    FileUtils.rm_f(resized_path)

    actual_size = FastImage.size(final_path)
    abort("Unexpected size for #{final_path}: #{actual_size.inspect}") unless actual_size == EXPECTED_SIZE

    final_path
  end
end

def wait_for_completion!(set_id:, expected_count:)
  loop do
    refreshed_set = Spaceship::ConnectAPI::AppScreenshotSet.get(app_screenshot_set_id: set_id)
    screenshots = refreshed_set.app_screenshots || []
    states = screenshots.map { |shot| shot.asset_delivery_state&.fetch("state", nil) }

    if screenshots.size == expected_count && states.all? { |state| state == "COMPLETE" }
      return refreshed_set
    end

    failures = screenshots.select(&:error?)
    unless failures.empty?
      details = failures.map { |shot| "#{shot.file_name}: #{shot.error_messages.join(', ')}" }.join(" | ")
      abort("Screenshot processing failed for #{set_id}: #{details}")
    end

    sleep(5)
  end
end

def localization_for(version:, locale:, localizations_by_locale:)
  localizations_by_locale[locale] ||= version.create_app_store_version_localization(attributes: { locale: locale })
end

def screenshot_set_for(localization)
  localization.get_app_screenshot_sets.find { |set| set.screenshot_display_type == DISPLAY_TYPE } ||
    localization.create_app_screenshot_set(attributes: { screenshotDisplayType: DISPLAY_TYPE })
end

sources = locale_sources
mapped_source_keys = sources.values.map { |value| value[:source_key] }.sort
unmapped_source_keys = Dir.children(SOURCE_ROOT).sort.select do |entry|
  source_dir = File.join(SOURCE_ROOT, entry)
  File.directory?(source_dir) && !LOCALE_MAP.key?(entry)
end

abort("No mapped iPhone screenshot source folders found under #{SOURCE_ROOT}") if sources.empty?

puts "Mode: #{DRY_RUN ? 'dry-run' : 'execute'}"
puts "Mapped source folders: #{mapped_source_keys.join(', ')}"
puts "Unmapped source folders skipped: #{unmapped_source_keys.join(', ')}" unless unmapped_source_keys.empty?

prepared = {}
sources.each do |target_locale, value|
  prepared[target_locale] = prepare_screenshots(source_files: value[:files], target_locale: target_locale)
  puts "Prepared #{prepared[target_locale].size} screenshot(s) for #{target_locale} from #{value[:source_key]}"
end

if DRY_RUN
  puts "Dry run complete. Prepared screenshots are in #{TEMP_ROOT}"
  exit 0
end

Spaceship::ConnectAPI.auth(
  key_id: KEY_ID,
  issuer_id: ISSUER_ID,
  filepath: KEY_FILEPATH,
  in_house: false
)

app = Spaceship::ConnectAPI::App.find(APP_IDENTIFIER)
abort("App #{APP_IDENTIFIER} not found in App Store Connect") unless app

version = app.get_edit_app_store_version(platform: Spaceship::ConnectAPI::Platform::IOS)
abort("No editable App Store version found for #{APP_IDENTIFIER}") unless version

localizations_by_locale = version.get_app_store_version_localizations.each_with_object({}) do |localization, hash|
  hash[localization.locale] = localization
end

prepared.keys.sort.each do |locale|
  files = prepared.fetch(locale)
  localization = localization_for(version: version, locale: locale, localizations_by_locale: localizations_by_locale)
  set = screenshot_set_for(localization)
  existing = set.app_screenshots || []

  puts "Uploading #{files.size} screenshot(s) to #{locale} #{DISPLAY_TYPE}; deleting #{existing.size} existing remote screenshot(s)"
  existing.each(&:delete!)

  refreshed_set = Spaceship::ConnectAPI::AppScreenshotSet.get(app_screenshot_set_id: set.id)
  remote_count = (refreshed_set.app_screenshots || []).size
  abort("Remote screenshots still exist for #{locale} after delete: #{remote_count}") unless remote_count.zero?

  files.each do |path|
    puts "Uploading #{File.basename(path)} to #{locale}"
    set.upload_screenshot(path: path, wait_for_processing: false)
  end

  completed_set = wait_for_completion!(set_id: set.id, expected_count: files.size)
  sorted_ids = (completed_set.app_screenshots || []).sort_by(&:file_name).map(&:id)
  completed_set.reorder_screenshots(app_screenshot_ids: sorted_ids) unless sorted_ids.empty?
  puts "Finished #{locale}"
end

puts "Upload finished successfully."
