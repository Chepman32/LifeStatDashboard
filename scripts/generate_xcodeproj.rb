#!/usr/bin/env ruby

require "fileutils"
require "xcodeproj"

ROOT = File.expand_path("..", __dir__)
PROJECT_PATH = File.join(ROOT, "Lifta.xcodeproj")
APP_ROOT = File.join(ROOT, "Lifta")
TEST_ROOT = File.join(ROOT, "Tests", "LiftaTests")

def ensure_group(parent, name)
  parent.children.find { |child| child.display_name == name } || parent.new_group(name, name)
end

def group_for_path(root_group, relative_path)
  group = root_group
  relative_path.split("/").reject(&:empty?).each do |component|
    group = ensure_group(group, component)
  end
  group
end

def add_file_to_target(project, root_group, target, relative_path, phase)
  group_path = File.dirname(relative_path)
  group = group_path == "." ? root_group : group_for_path(root_group, group_path)
  reference_name = File.basename(relative_path)
  reference = group.files.find { |file| file.path == reference_name } || group.new_file(reference_name)
  phase.add_file_reference(reference, true)
  reference
end

FileUtils.rm_rf(PROJECT_PATH)
project = Xcodeproj::Project.new(PROJECT_PATH)
project.root_object.attributes["LastUpgradeCheck"] = "1640"
project.root_object.attributes["TargetAttributes"] = {}

app_target = project.new_target(:application, "Lifta", :ios, "17.0")
tests_target = project.new_target(:unit_test_bundle, "LiftaTests", :ios, "17.0")
tests_target.add_dependency(app_target)

project.root_object.attributes["TargetAttributes"][app_target.uuid] = {
  "CreatedOnToolsVersion" => "16.4"
}

project.root_object.attributes["TargetAttributes"][tests_target.uuid] = {
  "CreatedOnToolsVersion" => "16.4",
  "TestTargetID" => app_target.uuid
}

app_target.build_configurations.each do |config|
  config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.lifta.app"
  config.build_settings["INFOPLIST_FILE"] = "Lifta/Resources/Info.plist"
  config.build_settings["GENERATE_INFOPLIST_FILE"] = "NO"
  config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "17.0"
  config.build_settings["MARKETING_VERSION"] = "1.0"
  config.build_settings["CURRENT_PROJECT_VERSION"] = "1"
  config.build_settings["PRODUCT_NAME"] = "Lifta"
  config.build_settings["SWIFT_VERSION"] = "6.0"
  config.build_settings["SWIFT_EMIT_LOC_STRINGS"] = "YES"
  config.build_settings["TARGETED_DEVICE_FAMILY"] = "1"
  config.build_settings["SUPPORTED_PLATFORMS"] = "iphoneos iphonesimulator"
  config.build_settings["SUPPORTS_MACCATALYST"] = "NO"
  config.build_settings["DEVELOPMENT_ASSET_PATHS"] = ""
  config.build_settings["ENABLE_PREVIEWS"] = "YES"
end

tests_target.build_configurations.each do |config|
  config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.lifta.app.tests"
  config.build_settings["GENERATE_INFOPLIST_FILE"] = "YES"
  config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "17.0"
  config.build_settings["PRODUCT_NAME"] = "LiftaTests"
  config.build_settings["SWIFT_VERSION"] = "6.0"
  config.build_settings["TARGETED_DEVICE_FAMILY"] = "1"
  config.build_settings["SUPPORTED_PLATFORMS"] = "iphoneos iphonesimulator"
  config.build_settings["TEST_TARGET_NAME"] = "Lifta"
  config.build_settings["TEST_HOST"] = "$(BUILT_PRODUCTS_DIR)/Lifta.app/Lifta"
  config.build_settings["BUNDLE_LOADER"] = "$(TEST_HOST)"
end

Dir.glob(File.join(APP_ROOT, "**", "*"), File::FNM_DOTMATCH)
  .reject { |path| File.directory?(path) }
  .sort
  .each do |path|
    relative_path = path.delete_prefix("#{ROOT}/")
    next if relative_path.end_with?(".plist")
    next if relative_path.include?(".xcassets/")

    if relative_path.end_with?(".swift")
      add_file_to_target(project, project.main_group, app_target, relative_path, app_target.source_build_phase)
    elsif relative_path.include?("Resources/")
      add_file_to_target(project, project.main_group, app_target, relative_path, app_target.resources_build_phase)
    end
  end

Dir.glob(File.join(TEST_ROOT, "**", "*.swift")).sort.each do |path|
  relative_path = path.delete_prefix("#{ROOT}/")
  add_file_to_target(project, project.main_group, tests_target, relative_path, tests_target.source_build_phase)
end

scheme = Xcodeproj::XCScheme.new
scheme.configure_with_targets(app_target, tests_target)
scheme.save_as(PROJECT_PATH, "Lifta", true)

project.save
puts "Generated #{PROJECT_PATH}"
