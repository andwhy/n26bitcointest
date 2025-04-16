import Combine
import Foundation

struct MarketChartResponse: Codable {
    let prices: [[Double]]
}

class BitcoinService: BitcoinServiceProtocol {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func fetchHistoricalRates() -> AnyPublisher<[BitcoinRate], Error> {
        let url = URL(string: "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=eur&days=13")!

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: MarketChartResponse.self, decoder: decoder)
            .map { response in
                response.prices.compactMap { pair in
                    guard pair.count == 2 else { return nil }
                    let timestamp = pair[0]
                    let value = pair[1]
                    let date = Date(timeIntervalSince1970: timestamp / 1000)
                    return BitcoinRate(date: date, eur: value)
                }
            }
            .eraseToAnyPublisher()
    }

    func fetchDetailRate(for date: Date) -> AnyPublisher<BitcoinDetailRate, Error> {
        return Just(BitcoinDetailRate(eur: 27000, usd: 29000, gbp: 23000))
            .setFailureType(to: Error.self)
            .delay(for: 1.0, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
