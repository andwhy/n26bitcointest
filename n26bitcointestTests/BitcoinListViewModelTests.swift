import XCTest
import Combine
@testable import n26bitcointest

final class BitcoinListViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []

    class MockBitcoinService: BitcoinServiceProtocol {
        var shouldFail = false
        var mockRates: [BitcoinRate] = []

        func fetchHistoricalRates() -> AnyPublisher<[BitcoinRate], Error> {
            if shouldFail {
                return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
            }
            return Just(mockRates)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        func fetchDetailRate(for date: Date) -> AnyPublisher<BitcoinDetailRate, Error> {
            fatalError("Not needed for this test")
        }

        func fetchTodayRate() -> AnyPublisher<Double, Error> {
            fatalError("Not needed for this test")
        }
    }

    // Test successful fetch of historical rates
    func testFetchRatesSuccess() {
        let mockRates = (0..<3).map {
            BitcoinRate(date: Date().addingTimeInterval(Double(-$0 * 86400)), eur: 20000 + Double($0))
        }

        let service = MockBitcoinService()
        service.mockRates = mockRates

        let viewModel = BitcoinListViewModel(service: service)

        let expectation = XCTestExpectation(description: "Fetch success")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertNil(viewModel.error)
            XCTAssertEqual(viewModel.rates.count, 3)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    // Test fetch failure and error handling
    func testFetchRatesFailure() {
        let service = MockBitcoinService()
        service.shouldFail = true

        let viewModel = BitcoinListViewModel(service: service)

        let expectation = XCTestExpectation(description: "Fetch failed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertNotNil(viewModel.error)
            XCTAssertTrue(viewModel.rates.isEmpty)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}
