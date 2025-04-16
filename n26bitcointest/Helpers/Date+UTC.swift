import Foundation

/// Formats the current `Date` as a UTC string in the "dd-MM-yyyy" format.
extension Date {
    func todayUTCString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }
}
