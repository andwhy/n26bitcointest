import XCTest
import Combine
@testable import n26bitcointest

final class BitcoinDetailViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []

    class MockBitcoinService: BitcoinServiceProtocol {
        var shouldFail = false

        func fetchHistoricalRates() -> AnyPublisher<[BitcoinRate], Error> {
            fatalError("Not needed")
        }

        func fetchDetailRate(for date: Date) -> AnyPublisher<BitcoinDetailRate, Error> {
            if shouldFail {
                return Fail(error: URLError(.notConnectedToInternet)).eraseToAnyPublisher()
            }
            return Just(BitcoinDetailRate(eur: 27000, usd: 29000, gbp: 23000))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        func fetchTodayRate() -> AnyPublisher<Double, Error> {
            fatalError("Not needed")
        }
    }

    // Test successful fetch of detail rate
    func testFetchDetailRateSuccess() {
        let service = MockBitcoinService()
        let viewModel = BitcoinDetailViewModel(service: service)

        let expectation = XCTestExpectation(description: "Detail fetched")

        viewModel.fetchDetails(for: Date())
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertNotNil(viewModel.detail)
            XCTAssertNil(viewModel.error)
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertEqual(viewModel.detail?.eur, 27000)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    // Test fetch failure and error state
    func testFetchDetailRateFailure() {
        let service = MockBitcoinService()
        service.shouldFail = true
        let viewModel = BitcoinDetailViewModel(service: service)

        let expectation = XCTestExpectation(description: "Detail failed")

        viewModel.fetchDetails(for: Date())
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertNil(viewModel.detail)
            XCTAssertNotNil(viewModel.error)
            XCTAssertFalse(viewModel.isLoading)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}
