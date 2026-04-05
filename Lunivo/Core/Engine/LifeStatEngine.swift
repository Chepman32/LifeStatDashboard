import Foundation

struct LifeStatEngine {
    private let calendar = Calendar(identifier: .gregorian)

    func snapshot(profile: UserProfile, now: Date = .now, language: AppLanguage = .system) -> LifeSnapshot {
        let clampedNow = max(now, profile.effectiveBirthDate)
        let timeline = LifeTimeline(profile: profile, now: clampedNow, calendar: calendar)
        let locale = language.locale

        let body = bodyStats(timeline: timeline, locale: locale)
        let time = timeStats(timeline: timeline, locale: locale)
        let space = spaceStats(timeline: timeline, locale: locale)
        let life = lifeStats(timeline: timeline, locale: locale)
        let absurd = absurdStats(timeline: timeline, locale: locale)

        let milestoneSpotlight = ([body, time, space, life, absurd].flatMap { $0.flatMap(\.nextMilestones) })
            .sorted { lhs, rhs in
                switch (lhs.estimatedDate, rhs.estimatedDate) {
                case let (left?, right?):
                    return left < right
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                case (.none, .none):
                    return lhs.progress > rhs.progress
                }
            }
            .first

        let statsByCategory: [StatCategory: [LifeStat]] = [
            .body: body,
            .time: time,
            .space: space,
            .life: life,
            .absurd: absurd,
            .milestones: milestoneSpotlight.map { spotlight in
                [spotlight.asLifeStat(locale: locale)]
            } ?? []
        ]

        return LifeSnapshot(
            generatedAt: clampedNow,
            ageSummary: timeline.ageSummary,
            statsByCategory: statsByCategory,
            tickerStats: [time.first, body.first, body[1], space[1], life[1], body[2]].compactMap { $0 },
            closestMilestone: milestoneSpotlight,
            methodologySections: methodologySections(locale: locale)
        )
    }

    private func bodyStats(timeline: LifeTimeline, locale: Locale) -> [LifeStat] {
        let heartbeats = timeline.minutes * 72
        let breaths = timeline.minutes * 15.5
        let blinks = timeline.wakingMinutes * 17
        let sleepHours = timeline.hours * 0.333
        let dreams = sleepHours / 1.5
        let hairGrowthMillimeters = timeline.days * 0.35
        let nailGrowthMillimeters = timeline.days * 0.1

        return [
            stat(
                id: "heartbeats",
                category: .body,
                title: "Heartbeats",
                icon: "heart.circle.fill",
                rawValue: heartbeats,
                unit: "beats",
                style: .count,
                derivation: .physicalConstant,
                deltaPerSecond: 1.2,
                locale: locale,
                visualStyle: .pulse,
                highlight: true,
                estimated: false,
                description: "Your involuntary percussion section has barely taken a break.",
                witty: "Your heart likely kept perfect time without asking permission.",
                methodology: "Elapsed minutes multiplied by a blended 72 BPM assumption.",
                alternates: [
                    alt("Per day", value: formatted(72 * 60 * 24, locale: locale), subtitle: "Average beats on an ordinary day", locale: locale),
                    alt("At 1 billion", value: countdownDate(current: heartbeats, rate: 1.2, nextTarget: nextRoundNumber(for: heartbeats), locale: locale), subtitle: "Projected next major heartbeat milestone", locale: locale)
                ]
            ),
            stat(
                id: "breaths",
                category: .body,
                title: "Breaths",
                icon: "wind",
                rawValue: breaths,
                unit: "breaths",
                style: .count,
                derivation: .physicalConstant,
                deltaPerSecond: 15.5 / 60,
                locale: locale,
                visualStyle: .pulse,
                description: "A lifetime of quiet negotiations with oxygen.",
                witty: "Millions of breaths, and the occasional sigh still finds room.",
                methodology: "Elapsed minutes multiplied by an average 15.5 breaths per minute.",
                alternates: [
                    alt("Per hour", value: formatted(15.5 * 60, locale: locale), subtitle: "Breaths in a typical hour", locale: locale),
                    alt("Sleep share", value: "\(formatted(33, locale: locale))%", subtitle: "Approximate portion spent resting", locale: locale)
                ]
            ),
            stat(
                id: "blinks",
                category: .body,
                title: "Blinks",
                icon: "eye.fill",
                rawValue: blinks,
                unit: "blinks",
                style: .count,
                derivation: .lifestyleEstimate,
                deltaPerSecond: 17 / 60,
                locale: locale,
                visualStyle: .pulse,
                description: "Thousands of tiny scene cuts, all handled locally.",
                witty: "You have edited reality one eyelid at a time.",
                methodology: "Waking minutes multiplied by an estimated 17 blinks per minute.",
                alternates: [
                    alt("Per waking day", value: formatted(17 * 60 * 16, locale: locale), subtitle: "Assuming roughly 16 waking hours", locale: locale),
                    alt("In film terms", value: formatted(blinks / 24, locale: locale), subtitle: "Equivalent seconds at 24 frames per second", locale: locale)
                ]
            ),
            stat(
                id: "sleep-hours",
                category: .body,
                title: "Hours Slept",
                icon: "bed.double.fill",
                rawValue: sleepHours,
                unit: "hours",
                style: .hours,
                derivation: .lifestyleEstimate,
                deltaPerSecond: 0.333 / 3600,
                locale: locale,
                visualStyle: .lunar,
                description: "A substantial fraction of your timeline has been moonlit.",
                witty: "A reminder that rest has quietly occupied years of the plot.",
                methodology: "Elapsed lifetime hours multiplied by a 33.3% sleep assumption.",
                alternates: [
                    alt("In days", value: formatted(sleepHours / 24, locale: locale), subtitle: "Full days spent sleeping", locale: locale),
                    alt("Sleep ratio", value: "\(formatted(33.3, locale: locale))%", subtitle: "A third of the whole arc, more or less", locale: locale)
                ]
            ),
            stat(
                id: "dreams",
                category: .body,
                title: "Dreams Estimated",
                icon: "sparkles",
                rawValue: dreams,
                unit: "dreams",
                style: .count,
                derivation: .lifestyleEstimate,
                deltaPerSecond: (0.333 / 1.5) / 3600,
                locale: locale,
                visualStyle: .lunar,
                description: "An editorial estimate for how often your sleeping brain improvised.",
                witty: "Entire private universes, drafted and discarded overnight.",
                methodology: "Estimated sleep hours divided by 1.5 hours per dream-heavy cycle.",
                alternates: [
                    alt("Per year", value: formatted(dreams / max(1, Double(timeline.ageSummary.years)), locale: locale), subtitle: "Average annual dream count", locale: locale),
                    alt("REM cycles", value: formatted(dreams, locale: locale), subtitle: "A loose one-to-one with dream cycles", locale: locale)
                ]
            ),
            growthStat(
                id: "hair-growth",
                category: .body,
                title: "Hair Growth",
                icon: "scissors",
                millimeters: hairGrowthMillimeters,
                dailyRateMillimeters: 0.35,
                timeline: timeline,
                locale: locale,
                description: "A quietly astonishing amount of biological material.",
                witty: "Your follicles have been working longer shifts than anyone asked of them.",
                methodology: "Elapsed days multiplied by an average 0.35 mm of hair growth per day.",
                visualStyle: .stacked
            ),
            growthStat(
                id: "nail-growth",
                category: .body,
                title: "Fingernail Growth",
                icon: "hands.sparkles.fill",
                millimeters: nailGrowthMillimeters,
                dailyRateMillimeters: 0.1,
                timeline: timeline,
                locale: locale,
                description: "Small keratin receipts from the passage of time.",
                witty: "Evidence that time leaves a trace even at the tips of your fingers.",
                methodology: "Elapsed days multiplied by an average 0.1 mm of fingernail growth per day.",
                visualStyle: .stacked
            )
        ]
    }

    private func timeStats(timeline: LifeTimeline, locale: Locale) -> [LifeStat] {
        let seconds = timeline.seconds
        let minutes = timeline.minutes
        let days = timeline.days
        let weeks = days / 7
        let months = Double(timeline.calendarMonths)
        let sunrises = floor(days)
        let leapDays = Double(timeline.leapDaysCrossed)

        return [
            stat(
                id: "seconds-lived",
                category: .time,
                title: "Seconds Lived",
                icon: "timer",
                rawValue: seconds,
                unit: "seconds",
                style: .seconds,
                derivation: .exactFromTime,
                deltaPerSecond: 1,
                locale: locale,
                visualStyle: .horizon,
                highlight: true,
                estimated: false,
                description: "The cleanest possible count of your time so far.",
                witty: "The number is absurd. That part is real.",
                methodology: "Direct elapsed time between your birth date and the current device time.",
                alternates: [
                    alt("Minutes", value: formatted(minutes, locale: locale), subtitle: "The same time, less dramatic punctuation", locale: locale),
                    alt("Days", value: formatted(days, locale: locale), subtitle: "A calmer way to say the same thing", locale: locale)
                ]
            ),
            stat(
                id: "days-lived",
                category: .time,
                title: "Days Lived",
                icon: "calendar",
                rawValue: days,
                unit: "days",
                style: .days,
                derivation: .exactFromTime,
                deltaPerSecond: 1 / 86_400,
                locale: locale,
                visualStyle: .horizon,
                description: "Long-form time, counted in sunrises and exits.",
                witty: "An elegant count of every day you have successfully occupied.",
                methodology: "Exact elapsed seconds divided by 86,400.",
                alternates: [
                    alt("Weeks", value: formatted(weeks, locale: locale), subtitle: "Rounded into seven-day chapters", locale: locale),
                    alt("Months", value: formatted(months, locale: locale), subtitle: "Calendar months crossed so far", locale: locale)
                ]
            ),
            stat(
                id: "weeks-lived",
                category: .time,
                title: "Weeks Lived",
                icon: "calendar.day.timeline.left",
                rawValue: weeks,
                unit: "weeks",
                style: .count,
                derivation: .exactFromTime,
                deltaPerSecond: 1 / 604_800,
                locale: locale,
                visualStyle: .stacked,
                description: "Time turned into something that feels almost manageable.",
                witty: "Enough weeks to lose count, but still not enough to finish every plan.",
                methodology: "Elapsed days divided by seven.",
                alternates: [
                    alt("Working weeks", value: formatted(weeks * 0.714, locale: locale), subtitle: "Assuming five workdays in seven", locale: locale),
                    alt("Sundays", value: formatted(weeks, locale: locale), subtitle: "One ending and one beginning, repeated", locale: locale)
                ]
            ),
            stat(
                id: "sunsets",
                category: .time,
                title: "Sunrises and Sunsets",
                icon: "sun.horizon.fill",
                rawValue: sunrises,
                unit: "cycles",
                style: .count,
                derivation: .physicalConstant,
                deltaPerSecond: 1 / 86_400,
                locale: locale,
                visualStyle: .horizon,
                description: "Approximate daylight cycles observed across your run.",
                witty: "A lifetime of horizons, whether or not you made eye contact with them.",
                methodology: "Elapsed days rounded down to whole solar day cycles.",
                alternates: [
                    alt("Golden hours", value: formatted(sunrises * 2, locale: locale), subtitle: "If you count both edges of the day", locale: locale),
                    alt("Future 10,000", value: countdownDate(current: sunrises, rate: 1 / 86_400, nextTarget: nextRoundNumber(for: sunrises), locale: locale), subtitle: "Projected next solar milestone", locale: locale)
                ]
            ),
            stat(
                id: "leap-days",
                category: .time,
                title: "Leap Days Crossed",
                icon: "calendar.badge.plus",
                rawValue: leapDays,
                unit: "leap days",
                style: .count,
                derivation: .exactFromTime,
                deltaPerSecond: 0,
                locale: locale,
                visualStyle: .editorial,
                description: "Actual February 29 crossings since your birth date.",
                witty: "Extra calendar fabric, quietly stitched into your life.",
                methodology: "Calendar-based count of leap days between birth date and now.",
                alternates: [
                    alt("Leap years", value: formatted(leapDays, locale: locale), subtitle: "Whole extra days successfully collected", locale: locale),
                    alt("Calendar quirk", value: LunivoLocalization.string("1 day at a time", locale: locale), subtitle: "Rare enough to stay special", locale: locale)
                ]
            )
        ]
    }

    private func spaceStats(timeline: LifeTimeline, locale: Locale) -> [LifeStat] {
        let orbits = timeline.days / 365.256
        let distanceKm = timeline.seconds * 29.78
        let fullMoons = timeline.days / 29.53058867
        let moonOrbits = timeline.days / 27.321661
        let seasonCycles = timeline.days / 91.3125
        let orbitProgress = timeline.birthdayProgress * 100

        return [
            stat(
                id: "earth-orbits",
                category: .space,
                title: "Earth Orbits",
                icon: "circle.dotted.circle",
                rawValue: orbits,
                unit: "orbits",
                style: .count,
                derivation: .physicalConstant,
                deltaPerSecond: 1 / (365.256 * 86_400),
                locale: locale,
                visualStyle: .orbit,
                highlight: true,
                estimated: false,
                description: "You have circled the Sun this many times, more or less exactly.",
                witty: "A yearly spiral completed with almost suspicious consistency.",
                methodology: "Elapsed days divided by Earth's orbital period of 365.256 days.",
                alternates: [
                    alt("Birthdays", value: formatted(Double(timeline.ageSummary.years), locale: locale), subtitle: "The ceremonial version of the same idea", locale: locale),
                    alt("Next full orbit", value: countdownDate(current: orbits, rate: 1 / (365.256 * 86_400), nextTarget: ceil(orbits), locale: locale), subtitle: "Projected next orbital return", locale: locale)
                ]
            ),
            distanceStat(
                id: "space-distance",
                category: .space,
                title: "Distance Traveled Through Space",
                icon: "point.3.filled.connected.trianglepath.dotted",
                kilometers: distanceKm,
                timeline: timeline,
                locale: locale,
                deltaPerSecond: 29.78,
                description: "Earth has been carrying you around the Sun at unsettling speed.",
                witty: "Billions of miles through space while still occasionally misplacing a charger.",
                methodology: "Elapsed seconds multiplied by Earth's orbital velocity of 29.78 km/s.",
                visualStyle: .orbit,
                highlight: true
            ),
            stat(
                id: "full-moons",
                category: .space,
                title: "Full Moons Witnessed",
                icon: "moon.stars.fill",
                rawValue: fullMoons,
                unit: "full moons",
                style: .count,
                derivation: .physicalConstant,
                deltaPerSecond: 1 / (29.53058867 * 86_400),
                locale: locale,
                visualStyle: .lunar,
                description: "A rough count of how many complete moon cycles your lifetime has hosted.",
                witty: "Enough lunar finales to make time feel theatrical.",
                methodology: "Elapsed days divided by the synodic month constant of 29.53 days.",
                alternates: [
                    alt("Years in moons", value: formatted(fullMoons / 12.37, locale: locale), subtitle: "Lunar years, more or less", locale: locale),
                    alt("500th full moon", value: countdownDate(current: fullMoons, rate: 1 / (29.53058867 * 86_400), nextTarget: nextRoundNumber(for: fullMoons), locale: locale), subtitle: "Projected next moon milestone", locale: locale)
                ]
            ),
            stat(
                id: "moon-orbits",
                category: .space,
                title: "Moon Orbits Around Earth",
                icon: "circle.hexagongrid.circle",
                rawValue: moonOrbits,
                unit: "orbits",
                style: .count,
                derivation: .physicalConstant,
                deltaPerSecond: 1 / (27.321661 * 86_400),
                locale: locale,
                visualStyle: .orbit,
                description: "The Moon has completed this many laps while you handled the rest of life.",
                witty: "An entire side plot running on a 27-day cadence above you.",
                methodology: "Elapsed days divided by the Moon's sidereal orbital period of 27.32 days.",
                alternates: [
                    alt("Per year", value: formatted(moonOrbits / max(1, Double(timeline.ageSummary.years)), locale: locale), subtitle: "Average lunar laps each year", locale: locale),
                    alt("Lunar pace", value: LunivoLocalization.string("27.3 days", locale: locale), subtitle: "One orbit, give or take", locale: locale)
                ]
            ),
            stat(
                id: "seasonal-cycles",
                category: .space,
                title: "Seasonal Cycles Experienced",
                icon: "leaf.circle.fill",
                rawValue: seasonCycles,
                unit: "seasons",
                style: .count,
                derivation: .physicalConstant,
                deltaPerSecond: 4 / (365.25 * 86_400),
                locale: locale,
                visualStyle: .editorial,
                description: "Quarter-turns of the year, counted across your entire arc.",
                witty: "Enough seasonal resets to know that change is normal and repetitive.",
                methodology: "Elapsed days divided by one quarter of a tropical year.",
                alternates: [
                    alt("Years", value: formatted(seasonCycles / 4, locale: locale), subtitle: "Four seasons per full orbit", locale: locale),
                    alt("Next round number", value: countdownDate(current: seasonCycles, rate: 4 / (365.25 * 86_400), nextTarget: nextRoundNumber(for: seasonCycles), locale: locale), subtitle: "Projected next seasonal milestone", locale: locale)
                ]
            ),
            stat(
                id: "birthday-progress",
                category: .space,
                title: "Current Orbit Progress Since Last Birthday",
                icon: "scope",
                rawValue: orbitProgress,
                unit: "%",
                style: .percent,
                derivation: .exactFromTime,
                deltaPerSecond: 100 / (timeline.lengthOfCurrentAgeYear * 86_400),
                locale: locale,
                visualStyle: .orbit,
                description: "Your present position on the current lap around the Sun.",
                witty: "A clean little reminder that another orbit is already underway.",
                methodology: "Elapsed time since your last birthday divided by time until the next one.",
                alternates: [
                    alt("Days since birthday", value: formatted(timeline.daysSinceLastBirthday, locale: locale), subtitle: "So far on this current loop", locale: locale),
                    alt("Days to next", value: formatted(timeline.daysUntilNextBirthday, locale: locale), subtitle: "Remaining before the next return", locale: locale)
                ]
            )
        ]
    }

    private func lifeStats(timeline: LifeTimeline, locale: Locale) -> [LifeStat] {
        let meals = timeline.days * 2.65
        let water = timeline.days * 6.5
        let words = timeline.wakingHours * 930
        let laughs = timeline.days * 17
        let steps = timeline.days * 5_200
        let songs = timeline.seconds / 210
        let phoneUnlocks = timeline.days * 58
        let coffees = timeline.days * 0.82
        let movies = timeline.minutes / 120
        let typing = timeline.days * 2_100

        return [
            stat(
                id: "meals",
                category: .life,
                title: "Meals Eaten",
                icon: "fork.knife.circle.fill",
                rawValue: meals,
                unit: "meals",
                style: .meals,
                derivation: .lifestyleEstimate,
                deltaPerSecond: 2.65 / 86_400,
                locale: locale,
                visualStyle: .stacked,
                description: "A domestic estimate of how many times life paused for food.",
                witty: "A substantial archive of breakfasts, late dinners, and compromised snacks.",
                methodology: "Elapsed days multiplied by an estimated 2.65 meals per day.",
                alternates: [
                    alt("Years of meals", value: formatted(meals / 365, locale: locale), subtitle: "If each day offered roughly one memorable plate", locale: locale),
                    alt("Restaurant nights", value: formatted(meals * 0.18, locale: locale), subtitle: "If a fraction happened somewhere with menus", locale: locale)
                ]
            ),
            stat(
                id: "words-spoken",
                category: .life,
                title: "Words Spoken",
                icon: "quote.bubble.fill",
                rawValue: words,
                unit: "words",
                style: .words,
                derivation: .lifestyleEstimate,
                deltaPerSecond: 930 / 3600,
                locale: locale,
                visualStyle: .editorial,
                highlight: true,
                estimated: true,
                description: "Estimated language volume across the waking portions of your life.",
                witty: "Enough words to fill books, texts, apologies, and very average small talk.",
                methodology: "Estimated waking hours multiplied by roughly 930 spoken words per hour.",
                alternates: [
                    alt("Novel equivalents", value: formatted(words / 80_000, locale: locale), subtitle: "Using 80,000 words per novel", locale: locale),
                    alt("Per day awake", value: formatted(930 * 16, locale: locale), subtitle: "A loose daily speaking total", locale: locale)
                ]
            ),
            stat(
                id: "water",
                category: .life,
                title: "Glasses of Water",
                icon: "drop.circle.fill",
                rawValue: water,
                unit: "glasses",
                style: .glasses,
                derivation: .lifestyleEstimate,
                deltaPerSecond: 6.5 / 86_400,
                locale: locale,
                visualStyle: .stacked,
                description: "Hydration, rendered as a lifetime stack.",
                witty: "An ocean would be exaggeration. A respectable reservoir would not.",
                methodology: "Elapsed days multiplied by an estimated 6.5 glasses of water per day.",
                alternates: [
                    alt("Liters", value: formatted(water * 0.24, locale: locale), subtitle: "Assuming 240 mL per glass", locale: locale),
                    alt("Daily rhythm", value: LunivoLocalization.string("6.5", locale: locale), subtitle: "Estimated glasses per day", locale: locale)
                ]
            ),
            stat(
                id: "steps",
                category: .life,
                title: "Steps Estimated",
                icon: "figure.walk.circle.fill",
                rawValue: steps,
                unit: "steps",
                style: .count,
                derivation: .lifestyleEstimate,
                deltaPerSecond: 5_200 / 86_400,
                locale: locale,
                visualStyle: .stacked,
                description: "A modest lifetime step estimate, not a fitness claim.",
                witty: "Enough steps to cross cities, routines, and several existential afternoons.",
                methodology: "Elapsed days multiplied by a blended estimate of 5,200 steps per day.",
                alternates: [
                    alt("Kilometers walked", value: formatted(steps * 0.000762, locale: locale), subtitle: "Assuming roughly 0.762 meters per step", locale: locale),
                    alt("10k days", value: formatted(steps / 10_000, locale: locale), subtitle: "Equivalent days at a classic goal", locale: locale)
                ]
            ),
            stat(
                id: "songs",
                category: .life,
                title: "Songs You Could Have Heard",
                icon: "music.note.list",
                rawValue: songs,
                unit: "songs",
                style: .count,
                derivation: .lifestyleEstimate,
                deltaPerSecond: 1 / 210,
                locale: locale,
                visualStyle: .editorial,
                description: "A whole soundtrack, if your lifetime were spent in three-and-a-half-minute tracks.",
                witty: "Enough songs to keep even your nostalgia in rotation.",
                methodology: "Elapsed seconds divided by an average song length of 210 seconds.",
                alternates: [
                    alt("Albums", value: formatted(songs / 10, locale: locale), subtitle: "At ten songs per album", locale: locale),
                    alt("Listening years", value: formatted((songs * 210) / 31_536_000, locale: locale), subtitle: "If you never stopped the playback", locale: locale)
                ]
            ),
            stat(
                id: "phone-unlocks",
                category: .life,
                title: "Phone Unlocks",
                icon: "lock.open.rotation",
                rawValue: phoneUnlocks,
                unit: "unlocks",
                style: .count,
                derivation: .lifestyleEstimate,
                deltaPerSecond: 58 / 86_400,
                locale: locale,
                visualStyle: .editorial,
                description: "A contemporary measure of how often life met a screen.",
                witty: "A private ritual repeated more often than anyone admits.",
                methodology: "Elapsed days multiplied by an estimated 58 phone unlocks per day.",
                alternates: [
                    alt("Per hour awake", value: formatted(58 / 16, locale: locale), subtitle: "Unlocks per waking hour", locale: locale),
                    alt("Attention checks", value: formatted(phoneUnlocks, locale: locale), subtitle: "A gentle estimate, not an accusation", locale: locale)
                ]
            ),
            stat(
                id: "coffees",
                category: .life,
                title: "Coffees Hypothetically Consumed",
                icon: "cup.and.saucer.fill",
                rawValue: coffees,
                unit: "cups",
                style: .count,
                derivation: .lifestyleEstimate,
                deltaPerSecond: 0.82 / 86_400,
                locale: locale,
                visualStyle: .editorial,
                description: "A culture-wide estimate for how often your day may have been negotiated via caffeine.",
                witty: "Possibly enough coffee to explain several ambitions and a few recoveries.",
                methodology: "Elapsed days multiplied by an estimated 0.82 coffees per day.",
                alternates: [
                    alt("Liters", value: formatted(coffees * 0.24, locale: locale), subtitle: "At roughly 240 mL per cup", locale: locale),
                    alt("Coffee shops", value: formatted(coffees / 2.7, locale: locale), subtitle: "If many cups happened on the move", locale: locale)
                ]
            ),
            stat(
                id: "movies",
                category: .life,
                title: "Movies Long Enough to Fill Your Lifetime",
                icon: "film.stack.fill",
                rawValue: movies,
                unit: "films",
                style: .count,
                derivation: .lifestyleEstimate,
                deltaPerSecond: 1 / 7_200,
                locale: locale,
                visualStyle: .editorial,
                description: "Your lifetime translated into feature-length pacing.",
                witty: "A very long festival, no intermission guaranteed.",
                methodology: "Elapsed minutes divided by a 120-minute film runtime.",
                alternates: [
                    alt("Seasons of TV", value: formatted(movies / 5, locale: locale), subtitle: "At roughly five films worth per prestige season", locale: locale),
                    alt("Credits still rolling", value: LunivoLocalization.string("Always", locale: locale), subtitle: "The runtime has not ended", locale: locale)
                ]
            ),
            stat(
                id: "typing",
                category: .life,
                title: "Typing Volume",
                icon: "keyboard.fill",
                rawValue: typing,
                unit: "keystrokes",
                style: .count,
                derivation: .lifestyleEstimate,
                deltaPerSecond: 2_100 / 86_400,
                locale: locale,
                visualStyle: .editorial,
                description: "Roughly how much of your life has passed through keys and glass.",
                witty: "Enough typing to compose plans, revisions, and a dignified amount of overthinking.",
                methodology: "Elapsed days multiplied by an estimated 2,100 typed characters per day.",
                alternates: [
                    alt("Pages", value: formatted(typing / 1_800, locale: locale), subtitle: "At roughly 1,800 characters per page", locale: locale),
                    alt("Daily total", value: formatted(2_100, locale: locale), subtitle: "A conservative estimate per day", locale: locale)
                ]
            ),
            stat(
                id: "laughs",
                category: .life,
                title: "Laughs Estimated",
                icon: "face.smiling.fill",
                rawValue: laughs,
                unit: "laughs",
                style: .count,
                derivation: .lifestyleEstimate,
                deltaPerSecond: 17 / 86_400,
                locale: locale,
                visualStyle: .editorial,
                description: "A low-friction estimate of how many times the day softened.",
                witty: "Small bursts of relief, counted generously but not irresponsibly.",
                methodology: "Elapsed days multiplied by an estimated 17 laughs per day.",
                alternates: [
                    alt("Per week", value: formatted(17 * 7, locale: locale), subtitle: "Average weekly laugh count", locale: locale),
                    alt("Comic value", value: LunivoLocalization.string("Unquantifiable", locale: locale), subtitle: "The count is not the meaning", locale: locale)
                ]
            )
        ]
    }

    private func absurdStats(timeline: LifeTimeline, locale: Locale) -> [LifeStat] {
        let heartbeats = timeline.minutes * 72
        let breaths = timeline.minutes * 15.5
        let distanceKm = timeline.seconds * 29.78
        let mondays = Double(timeline.mondaysCrossed)

        return [
            stat(
                id: "task-avoidance-distance",
                category: .absurd,
                title: "Distance Traveled While Avoiding One Task",
                icon: "ellipsis.circle.fill",
                rawValue: distanceKm,
                unit: timeline.profile.unitPreference == .metric ? "km" : "mi",
                style: timeline.profile.unitPreference == .metric ? .kilometers : .miles,
                derivation: .lifestyleEstimate,
                deltaPerSecond: timeline.profile.unitPreference == .metric ? 29.78 : 18.504,
                locale: locale,
                visualStyle: .editorial,
                highlight: true,
                estimated: true,
                description: "Technically a space statistic. Emotionally, a procrastination statistic.",
                witty: "You have traveled billions through space and that one task still feels negotiable.",
                methodology: "Same orbital-distance calculation, reframed with restraint and honesty.",
                alternates: [
                    alt("Earth circles", value: formatted(distanceKm / 40_075, locale: locale), subtitle: "Enough to wrap Earth many times", locale: locale),
                    alt("Still pending", value: LunivoLocalization.string("Possibly", locale: locale), subtitle: "A soft accusation, not a data point", locale: locale)
                ]
            ),
            stat(
                id: "permissionless-heart",
                category: .absurd,
                title: "Times Your Heart Kept Going Anyway",
                icon: "bolt.heart.fill",
                rawValue: heartbeats,
                unit: "beats",
                style: .count,
                derivation: .physicalConstant,
                deltaPerSecond: 1.2,
                locale: locale,
                visualStyle: .pulse,
                description: "The most dependable performance review in your body.",
                witty: "A multi-billion beat performance with no meeting requests.",
                methodology: "The heartbeat count, stated with appropriate awe.",
                alternates: [
                    alt("Per hesitation", value: LunivoLocalization.string("Still running", locale: locale), subtitle: "Your internal engine remains committed", locale: locale),
                    alt("Billions", value: formatted(heartbeats / 1_000_000_000, locale: locale), subtitle: "In clean big-number terms", locale: locale)
                ]
            ),
            stat(
                id: "books-worth-of-words",
                category: .absurd,
                title: "Books Worth of Spoken Words",
                icon: "books.vertical.fill",
                rawValue: timeline.wakingHours * 930 / 80_000,
                unit: "books",
                style: .count,
                derivation: .lifestyleEstimate,
                deltaPerSecond: (930 / 80_000) / 3600,
                locale: locale,
                visualStyle: .editorial,
                description: "A literary framing for all that everyday speech.",
                witty: "Enough words to shelve entire versions of yourself.",
                methodology: "Estimated spoken words divided by 80,000 words per novel.",
                alternates: [
                    alt("Long novels", value: formatted((timeline.wakingHours * 930) / 120_000, locale: locale), subtitle: "At 120,000 words each", locale: locale),
                    alt("Short books", value: formatted((timeline.wakingHours * 930) / 50_000, locale: locale), subtitle: "At 50,000 words each", locale: locale)
                ]
            ),
            stat(
                id: "sigh-capacity",
                category: .absurd,
                title: "Breaths Taken Despite Everything",
                icon: "aqi.medium",
                rawValue: breaths,
                unit: "breaths",
                style: .count,
                derivation: .physicalConstant,
                deltaPerSecond: 15.5 / 60,
                locale: locale,
                visualStyle: .pulse,
                description: "A cleaner framing for persistence than most motivational posters.",
                witty: "You have completed millions of breaths and still occasionally sighed about it.",
                methodology: "The same breath estimate, written with a little more dramatic truth.",
                alternates: [
                    alt("Daily baseline", value: formatted(15.5 * 60 * 24, locale: locale), subtitle: "Estimated breaths in one day", locale: locale),
                    alt("Next round number", value: countdownDate(current: breaths, rate: 15.5 / 60, nextTarget: nextRoundNumber(for: breaths), locale: locale), subtitle: "Projected next breathing milestone", locale: locale)
                ]
            ),
            stat(
                id: "mondays-survived",
                category: .absurd,
                title: "Mondays Survived",
                icon: "briefcase.circle.fill",
                rawValue: mondays,
                unit: "Mondays",
                style: .count,
                derivation: .exactFromTime,
                deltaPerSecond: 0,
                locale: locale,
                visualStyle: .editorial,
                description: "A calendar-grounded measure of persistence.",
                witty: "You have survived this many Mondays and still expect better from the next one.",
                methodology: "Calendar-based count of Mondays crossed since your birth date.",
                alternates: [
                    alt("Work weeks", value: formatted(mondays, locale: locale), subtitle: "One reluctant beginning at a time", locale: locale),
                    alt("Motivation status", value: LunivoLocalization.string("Still not found", locale: locale), subtitle: "A required line item, now properly documented", locale: locale)
                ]
            )
        ]
    }

    private func stat(
        id: String,
        category: StatCategory,
        title: String,
        icon: String,
        rawValue: Double,
        unit: String,
        style: StatUnitStyle,
        derivation: DerivationType,
        deltaPerSecond: Double,
        locale: Locale,
        visualStyle: StatVisualStyle,
        highlight: Bool = false,
        estimated: Bool = true,
        description: String,
        witty: String,
        methodology: String,
        alternates: [LifeStatAlternate]
    ) -> LifeStat {
        let fractionDigits: Int
        switch style {
        case .percent:
            fractionDigits = 1
        case .count where rawValue < 100:
            fractionDigits = 1
        default:
            fractionDigits = 0
        }

        let formattedValue = formatted(rawValue, locale: locale, fractionDigits: fractionDigits)
        let compactValue = compact(rawValue, locale: locale)
        let milestones = milestoneSeries(for: id, title: title, current: rawValue, ratePerSecond: deltaPerSecond, unit: unit, description: witty, locale: locale)

        return LifeStat(
            id: id,
            category: category,
            title: LunivoLocalization.string(title, locale: locale),
            iconName: icon,
            rawValue: rawValue,
            formattedValue: formattedValue,
            compactValue: compactValue,
            unit: LunivoLocalization.string(unit, locale: locale),
            precisionStyle: style,
            derivationType: derivation,
            shortDescription: LunivoLocalization.string(description, locale: locale),
            wittyComparison: LunivoLocalization.string(witty, locale: locale),
            methodologySummary: LunivoLocalization.string(methodology, locale: locale),
            alternateRepresentations: alternates,
            nextMilestones: milestones,
            deltaPerSecond: deltaPerSecond,
            visualStyle: visualStyle,
            highlight: highlight,
            estimated: estimated
        )
    }

    private func growthStat(
        id: String,
        category: StatCategory,
        title: String,
        icon: String,
        millimeters: Double,
        dailyRateMillimeters: Double,
        timeline: LifeTimeline,
        locale: Locale,
        description: String,
        witty: String,
        methodology: String,
        visualStyle: StatVisualStyle
    ) -> LifeStat {
        let display = LunivoNumberFormatter.growth(millimeters, unitPreference: timeline.profile.unitPreference, locale: locale)
        let rate = timeline.profile.unitPreference == .metric ? dailyRateMillimeters / 86_400 / 10 : dailyRateMillimeters / 86_400 / 25.4
        return LifeStat(
            id: id,
            category: category,
            title: LunivoLocalization.string(title, locale: locale),
            iconName: icon,
            rawValue: timeline.profile.unitPreference == .metric ? millimeters / 10 : millimeters / 25.4,
            formattedValue: display.0,
            compactValue: display.0,
            unit: LunivoLocalization.string(display.1, locale: locale),
            precisionStyle: timeline.profile.unitPreference == .metric ? .centimeters : .inches,
            derivationType: .lifestyleEstimate,
            shortDescription: LunivoLocalization.string(description, locale: locale),
            wittyComparison: LunivoLocalization.string(witty, locale: locale),
            methodologySummary: LunivoLocalization.string(methodology, locale: locale),
            alternateRepresentations: [
                alt("Millimeters", value: formatted(millimeters, locale: locale), subtitle: "The unromantic raw unit", locale: locale),
                alt("Daily rate", value: LunivoLocalization.string(timeline.profile.unitPreference == .metric ? "0.35 mm" : "0.014 in", locale: locale), subtitle: "Estimated growth per day", locale: locale)
            ],
            nextMilestones: milestoneSeries(for: id, title: title, current: millimeters, ratePerSecond: dailyRateMillimeters / 86_400, unit: "mm", description: witty, locale: locale),
            deltaPerSecond: rate,
            visualStyle: visualStyle,
            highlight: false,
            estimated: true
        )
    }

    private func distanceStat(
        id: String,
        category: StatCategory,
        title: String,
        icon: String,
        kilometers: Double,
        timeline: LifeTimeline,
        locale: Locale,
        deltaPerSecond: Double,
        description: String,
        witty: String,
        methodology: String,
        visualStyle: StatVisualStyle,
        highlight: Bool = false
    ) -> LifeStat {
        let distance = LunivoNumberFormatter.distance(kilometers, unitPreference: timeline.profile.unitPreference, locale: locale)
        let adjustedRaw = timeline.profile.unitPreference == .metric ? kilometers : kilometers * 0.621371
        let adjustedRate = timeline.profile.unitPreference == .metric ? deltaPerSecond : deltaPerSecond * 0.621371
        return LifeStat(
            id: id,
            category: category,
            title: LunivoLocalization.string(title, locale: locale),
            iconName: icon,
            rawValue: adjustedRaw,
            formattedValue: distance.0,
            compactValue: distance.0,
            unit: LunivoLocalization.string(distance.1, locale: locale),
            precisionStyle: timeline.profile.unitPreference == .metric ? .kilometers : .miles,
            derivationType: .physicalConstant,
            shortDescription: LunivoLocalization.string(description, locale: locale),
            wittyComparison: LunivoLocalization.string(witty, locale: locale),
            methodologySummary: LunivoLocalization.string(methodology, locale: locale),
            alternateRepresentations: [
                alt("Earth circles", value: formatted(kilometers / 40_075, locale: locale), subtitle: "At Earth's equatorial circumference", locale: locale),
                alt("AU traveled", value: formatted(kilometers / 149_597_870.7, locale: locale), subtitle: "Astronomical units, for scale", locale: locale)
            ],
            nextMilestones: milestoneSeries(for: id, title: title, current: adjustedRaw, ratePerSecond: adjustedRate, unit: distance.1, description: witty, locale: locale),
            deltaPerSecond: adjustedRate,
            visualStyle: visualStyle,
            highlight: highlight,
            estimated: false
        )
    }

    private func milestoneSeries(for id: String, title: String, current: Double, ratePerSecond: Double, unit: String, description: String, locale: Locale) -> [Milestone] {
        let targets = nextMilestoneTargets(after: current)
        return targets.map { target in
            let secondsUntilTarget = ratePerSecond > 0 ? max(0, (target - current) / ratePerSecond) : nil
            let date = secondsUntilTarget.map { Date().addingTimeInterval($0) }
            let progress = min(max(current / target, 0), 1)
            let localizedDescription = LunivoLocalization.string(description, locale: locale)
            let marker = LunivoLocalization.formatted("Next marker: %@ %@.", locale: locale, compact(target, locale: locale), LunivoLocalization.string(unit, locale: locale))
            return Milestone(
                id: "\(id)-\(target)",
                statID: id,
                title: LunivoLocalization.string(title, locale: locale),
                value: compact(target, locale: locale),
                targetValue: target,
                estimatedDate: date,
                progress: progress,
                description: localizedDescription + " " + marker
            )
        }
    }

    private func nextMilestoneTargets(after value: Double) -> [Double] {
        let first = nextRoundNumber(for: value)
        return [first, first * 2, first * 5]
    }

    private func nextRoundNumber(for value: Double) -> Double {
        guard value > 0 else { return 1 }
        let magnitude = pow(10.0, floor(log10(value)))
        let normalized = value / magnitude
        let targetBase: Double
        switch normalized {
        case ..<1.5: targetBase = 2
        case ..<3.5: targetBase = 5
        default: targetBase = 10
        }
        return targetBase * magnitude
    }

    private func formatted(_ value: Double, locale: Locale, fractionDigits: Int = 0) -> String {
        LunivoNumberFormatter.exact(value, locale: locale, fractionDigits: fractionDigits)
    }

    private func compact(_ value: Double, locale: Locale) -> String {
        LunivoNumberFormatter.compact(value, locale: locale, fractionDigits: value < 1000 ? 1 : 1)
    }

    private func alt(_ title: String, value: String, subtitle: String, locale: Locale) -> LifeStatAlternate {
        LifeStatAlternate(
            title: LunivoLocalization.string(title, locale: locale),
            value: value,
            subtitle: LunivoLocalization.string(subtitle, locale: locale)
        )
    }

    private func countdownDate(current: Double, rate: Double, nextTarget: Double, locale: Locale) -> String {
        guard rate > 0 else { return LunivoLocalization.string("Static", locale: locale) }
        let seconds = max(0, (nextTarget - current) / rate)
        let date = Date().addingTimeInterval(seconds)
        return LunivoDateFormatter.medium(date: date, locale: locale)
    }

    private func methodologySections(locale: Locale) -> [MethodologySection] {
        [
            MethodologySection(
                title: LunivoLocalization.string("Exact from time", locale: locale),
                summary: LunivoLocalization.string("These values come directly from elapsed time and calendar math.", locale: locale),
                rows: [
                    MethodologyRow(title: LunivoLocalization.string("Seconds lived", locale: locale), formula: "current time - birth time", derivationType: .exactFromTime, note: LunivoLocalization.string("No estimation layer.", locale: locale)),
                    MethodologyRow(title: LunivoLocalization.string("Days and weeks", locale: locale), formula: "elapsed seconds / 86,400", derivationType: .exactFromTime, note: LunivoLocalization.string("Displayed in multiple calendar-friendly units.", locale: locale)),
                    MethodologyRow(title: LunivoLocalization.string("Leap days crossed", locale: locale), formula: "count February 29 dates crossed", derivationType: .exactFromTime, note: LunivoLocalization.string("Calendar aware.", locale: locale))
                ]
            ),
            MethodologySection(
                title: LunivoLocalization.string("Physical constants", locale: locale),
                summary: LunivoLocalization.string("These use stable astronomical or physiological constants to turn time into scale.", locale: locale),
                rows: [
                    MethodologyRow(title: LunivoLocalization.string("Earth orbits", locale: locale), formula: "elapsed days / 365.256", derivationType: .physicalConstant, note: LunivoLocalization.string("Uses Earth's sidereal year.", locale: locale)),
                    MethodologyRow(title: LunivoLocalization.string("Space distance", locale: locale), formula: "elapsed seconds × 29.78 km/s", derivationType: .physicalConstant, note: LunivoLocalization.string("Based on Earth's orbital velocity.", locale: locale)),
                    MethodologyRow(title: LunivoLocalization.string("Full moons", locale: locale), formula: "elapsed days / 29.53058867", derivationType: .physicalConstant, note: LunivoLocalization.string("Uses the synodic month.", locale: locale))
                ]
            ),
            MethodologySection(
                title: LunivoLocalization.string("Lifestyle estimates", locale: locale),
                summary: LunivoLocalization.string("These are intentionally labeled estimates. They are for delight and perspective, not clinical truth.", locale: locale),
                rows: [
                    MethodologyRow(title: LunivoLocalization.string("Words spoken", locale: locale), formula: "waking hours × 930 words/hour", derivationType: .lifestyleEstimate, note: LunivoLocalization.string("A blended average.", locale: locale)),
                    MethodologyRow(title: LunivoLocalization.string("Meals and water", locale: locale), formula: "elapsed days × daily estimate", derivationType: .lifestyleEstimate, note: LunivoLocalization.string("Uses broad, demographic-neutral assumptions.", locale: locale)),
                    MethodologyRow(title: LunivoLocalization.string("Phone unlocks", locale: locale), formula: "elapsed days × 58", derivationType: .lifestyleEstimate, note: LunivoLocalization.string("Represents general digital behavior.", locale: locale))
                ]
            )
        ]
    }
}

private extension Milestone {
    func asLifeStat(locale: Locale) -> LifeStat {
        LifeStat(
            id: id,
            category: .milestones,
            title: LunivoLocalization.string("Closest Upcoming Milestone", locale: locale),
            iconName: "sparkles",
            rawValue: targetValue,
            formattedValue: value,
            compactValue: value,
            unit: title,
            precisionStyle: .count,
            derivationType: .lifestyleEstimate,
            shortDescription: description,
            wittyComparison: description,
            methodologySummary: LunivoLocalization.string("Projected using the current live rate of the source statistic.", locale: locale),
            alternateRepresentations: [
                LifeStatAlternate(
                    title: LunivoLocalization.string("Date", locale: locale),
                    value: estimatedDate.map { LunivoDateFormatter.medium(date: $0, locale: locale) } ?? LunivoLocalization.string("Static", locale: locale),
                    subtitle: LunivoLocalization.string("Estimated arrival", locale: locale)
                ),
                LifeStatAlternate(
                    title: LunivoLocalization.string("Progress", locale: locale),
                    value: LunivoNumberFormatter.exact(progress * 100, locale: locale, fractionDigits: 1) + "%",
                    subtitle: LunivoLocalization.string("How close you already are", locale: locale)
                )
            ],
            nextMilestones: [self],
            deltaPerSecond: 0,
            visualStyle: .editorial,
            highlight: true,
            estimated: true
        )
    }
}
