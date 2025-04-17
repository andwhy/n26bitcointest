import Combine
import Foundation

protocol BitcoinServiceProtocol {
    func fetchHistoricalRates() -> AnyPublisher<[BitcoinRate], Error>
    func fetchDetailRate(for date: Date) -> AnyPublisher<BitcoinDetailRate, Error>
}
