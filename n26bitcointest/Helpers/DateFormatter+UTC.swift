import Foundation

extension DateFormatter {
    /// A reusable `DateFormatter` instance configured to display dates in UTC with `.medium` date style.
    static var utc: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
}
