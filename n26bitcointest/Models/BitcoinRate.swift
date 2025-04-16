
import Foundation

struct BitcoinRate: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let eur: Double
}
