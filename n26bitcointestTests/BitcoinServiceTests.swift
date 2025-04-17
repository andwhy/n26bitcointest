import XCTest
import Combine
@testable import n26bitcointest

final class BitcoinServiceTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []

    class MockBitcoinService: BitcoinServiceProtocol {
        var shouldFail = false

        func fetchHistoricalRates() -> AnyPublisher<[BitcoinRate], Error> {
            if shouldFail {
                return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
            }
            let mock = (0..<5).map {
                BitcoinRate(date: Date().addingTimeInterval(Double(-$0 * 86400)), eur: 10000 + Double($0))
            }
            return Just(mock)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        func fetchDetailRate(for date: Date) -> AnyPublisher<BitcoinDetailRate, Error> {
            if shouldFail {
                return Fail(error: URLError(.notConnectedToInternet)).eraseToAnyPublisher()
            }
            let detail = BitcoinDetailRate(eur: 27000, usd: 29000, gbp: 23000)
            return Just(detail)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        func fetchTodayRate() -> AnyPublisher<Double, Error> {
            if shouldFail {
                return Fail(error: URLError(.timedOut)).eraseToAnyPublisher()
            }
            return Just(28000.0)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    func testFetchHistoricalRatesSuccess() {
        let service = MockBitcoinService()
        let expectation = XCTestExpectation(description: "Historical rates fetched")

        service.fetchHistoricalRates()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { rates in
                XCTAssertEqual(rates.count, 5)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testFetchDetailRateSuccess() {
        let service = MockBitcoinService()
        let expectation = XCTestExpectation(description: "Detail rate fetched")

        service.fetchDetailRate(for: Date())
            .sink(receiveCompletion: { _ in },
                  receiveValue: { detail in
                XCTAssertEqual(detail.eur, 27000)
                XCTAssertEqual(detail.usd, 29000)
                XCTAssertEqual(detail.gbp, 23000)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testFetchTodayRateSuccess() {
        let service = MockBitcoinService()
        let expectation = XCTestExpectation(description: "Today's rate fetched")

        service.fetchTodayRate()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { value in
                XCTAssertEqual(value, 28000.0)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testAllFailures() {
        let service = MockBitcoinService()
        service.shouldFail = true

        let failExpectation = XCTestExpectation(description: "All methods fail")
        failExpectation.expectedFulfillmentCount = 3

        service.fetchHistoricalRates()
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    failExpectation.fulfill()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        service.fetchDetailRate(for: Date())
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    failExpectation.fulfill()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        service.fetchTodayRate()
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    failExpectation.fulfill()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(for: [failExpectation], timeout: 1)
    }
}
