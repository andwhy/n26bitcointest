import Combine
import Foundation

struct MarketChartResponse: Codable {
    let prices: [[Double]]
}

struct CoinHistoryResponse: Codable {
    let market_data: MarketData?
    
    struct MarketData: Codable {
        let current_price: [String: Double]
    }
}

class BitcoinService: BitcoinServiceProtocol {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func fetchHistoricalRates() -> AnyPublisher<[BitcoinRate], Error> {
        let url = URL(string: "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=eur&days=13")!
        let request = URLRequest(url: url)

        return URLSession.shared
            .publisherWithAPICheck(for: request, decodeTo: MarketChartResponse.self, decoder: decoder)
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
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/bitcoin/history?date=\(date.todayUTCString())&localization=false") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        let request = URLRequest(url: url)
        
        return URLSession.shared
            .publisherWithAPICheck(for: request, decodeTo: CoinHistoryResponse.self, decoder: decoder)
            .tryMap { response in
                guard
                    let eur = response.market_data?.current_price["eur"],
                    let usd = response.market_data?.current_price["usd"],
                    let gbp = response.market_data?.current_price["gbp"]
                else {
                    throw URLError(.cannotParseResponse)
                }
                return BitcoinDetailRate(eur: eur, usd: usd, gbp: gbp)
            }
            .eraseToAnyPublisher()
    }
}
