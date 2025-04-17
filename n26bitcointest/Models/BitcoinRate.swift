import Foundation

struct BitcoinRate: Identifiable, Codable, Equatable {
    let id = UUID()
    let date: Date
    let eur: Double
    
    private enum CodingKeys: String, CodingKey {
        case date
        case eur
    }
}
