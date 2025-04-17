import Foundation
import Combine

class BitcoinDetailViewModel: ObservableObject {
    @Published var detail: BitcoinDetailRate?
    @Published var isLoading = false
    @Published var error: String?

    private var cancellables = Set<AnyCancellable>()
    private let service: BitcoinServiceProtocol

    init(service: BitcoinServiceProtocol = BitcoinService()) {
        self.service = service
    }

    func fetchDetails(for date: Date) {
        isLoading = true
        service.fetchDetailRate(for: date)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.error = error.localizedDescription
                }
            }, receiveValue: { self.detail = $0 })
            .store(in: &cancellables)
    }
}
