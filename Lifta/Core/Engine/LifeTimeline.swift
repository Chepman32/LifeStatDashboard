import Foundation

struct LifeTimeline {
    let profile: UserProfile
    let now: Date
    let calendar: Calendar

    let seconds: Double
    let minutes: Double
    let hours: Double
    let days: Double
    let wakingHours: Double
    let wakingMinutes: Double
    let calendarMonths: Int
    let leapDaysCrossed: Int
    let mondaysCrossed: Int
    let birthdayProgress: Double
    let daysSinceLastBirthday: Double
    let daysUntilNextBirthday: Double
    let lengthOfCurrentAgeYear: Double
    let ageSummary: AgeSummary

    init(profile: UserProfile, now: Date, calendar: Calendar) {
        self.profile = profile
        self.now = now
        self.calendar = calendar

        let birth = profile.effectiveBirthDate
        let elapsed = max(now.timeIntervalSince(birth), 0)
        self.seconds = elapsed
        self.minutes = elapsed / 60
        self.hours = elapsed / 3_600
        self.days = elapsed / 86_400

        let sleepHours = hours * 0.333
        self.wakingHours = max(hours - sleepHours, 0)
        self.wakingMinutes = wakingHours * 60

        let components = calendar.dateComponents([.year, .month, .day], from: birth, to: now)
        let years = components.year ?? 0
        let months = components.month ?? 0
        let daysComponent = components.day ?? 0
        self.calendarMonths = max(0, years * 12 + months)
        self.ageSummary = AgeSummary(
            years: years,
            months: months,
            days: daysComponent,
            totalDays: Int(days.rounded(.down)),
            yearsLabel: "\(years) years"
        )

        self.leapDaysCrossed = LifeTimeline.countLeapDays(from: birth, to: now, calendar: calendar)
        self.mondaysCrossed = LifeTimeline.countWeekday(.monday, from: birth, to: now, calendar: calendar)

        let lastBirthday = Self.lastBirthday(since: birth, now: now, calendar: calendar)
        let nextBirthday = Self.nextBirthday(after: birth, now: now, calendar: calendar)
        self.daysSinceLastBirthday = max(now.timeIntervalSince(lastBirthday) / 86_400, 0)
        self.daysUntilNextBirthday = max(nextBirthday.timeIntervalSince(now) / 86_400, 0)
        self.lengthOfCurrentAgeYear = max(nextBirthday.timeIntervalSince(lastBirthday) / 86_400, 365)
        self.birthdayProgress = min(max(daysSinceLastBirthday / lengthOfCurrentAgeYear, 0), 1)
    }

    private static func countLeapDays(from start: Date, to end: Date, calendar: Calendar) -> Int {
        let startYear = calendar.component(.year, from: start)
        let endYear = calendar.component(.year, from: end)

        return (startYear...endYear).reduce(into: 0) { count, year in
            guard let leapDate = calendar.date(from: DateComponents(year: year, month: 2, day: 29)),
                  leapDate >= start,
                  leapDate <= end else {
                return
            }
            count += 1
        }
    }

    private static func countWeekday(_ weekday: Weekday, from start: Date, to end: Date, calendar: Calendar) -> Int {
        guard let first = calendar.nextDate(
            after: start.addingTimeInterval(-1),
            matching: DateComponents(weekday: weekday.rawValue),
            matchingPolicy: .nextTime
        ) else {
            return 0
        }

        var count = 0
        var current = first
        while current <= end {
            count += 1
            current = calendar.date(byAdding: .day, value: 7, to: current) ?? end.addingTimeInterval(1)
        }
        return count
    }

    private static func lastBirthday(since birth: Date, now: Date, calendar: Calendar) -> Date {
        let currentYear = calendar.component(.year, from: now)
        let thisYear = birthdayDate(in: currentYear, birth: birth, calendar: calendar)
        if thisYear <= now {
            return thisYear
        }
        return birthdayDate(in: currentYear - 1, birth: birth, calendar: calendar)
    }

    private static func nextBirthday(after birth: Date, now: Date, calendar: Calendar) -> Date {
        let currentYear = calendar.component(.year, from: now)
        let thisYear = birthdayDate(in: currentYear, birth: birth, calendar: calendar)
        if thisYear > now {
            return thisYear
        }
        return birthdayDate(in: currentYear + 1, birth: birth, calendar: calendar)
    }

    private static func birthdayDate(in year: Int, birth: Date, calendar: Calendar) -> Date {
        let birthComponents = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: birth)
        let month = birthComponents.month ?? 1
        let preferredDay = birthComponents.day ?? 1
        let maximumDay = calendar.range(of: .day, in: .month, for: calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? birth)?.count ?? preferredDay
        let adjustedDay = min(preferredDay, maximumDay)

        return calendar.date(from: DateComponents(
            year: year,
            month: month,
            day: adjustedDay,
            hour: birthComponents.hour,
            minute: birthComponents.minute,
            second: birthComponents.second
        )) ?? birth
    }
}

enum Weekday: Int {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
}
