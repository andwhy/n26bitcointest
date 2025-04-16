import Foundation
import Combine

// MARK: - URLSession Extension for Unified Error Handling

extension URLSession {
    /// Wraps `dataTaskPublisher` with API-specific error decoding and decoding to expected model
    func publisherWithAPICheck<T: Decodable>(
        for request: URLRequest,
        decodeTo type: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<T, Error> {
        return self.dataTaskPublisher(for: request)
            .tryMap { data, _ in
                // Try to decode as API error (e.g., rate limit)
                if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data),
                   apiError.status.error_code == 429 {
                    throw NSError(
                        domain: "CoinGecko",
                        code: 429,
                        userInfo: [NSLocalizedDescriptionKey: apiError.status.error_message]
                    )
                }
                return data
            }
            .decode(type: T.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
