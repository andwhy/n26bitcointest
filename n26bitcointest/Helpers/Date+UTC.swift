import Foundation

extension Date {
    /// Formats the current `Date` as a UTC string in the "dd-MM-yyyy" format.
    func todayUTCString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }
    
    /// Returns the start of the day (00:00) in UTC for the given `Date`.
    func utcStartOfDay() -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.startOfDay(for: self)
    }
}
