import Foundation
import Combine

class BitcoinListViewModel: ObservableObject {
    @Published var rates: [BitcoinRate] = []
    @Published var isLoading = false
    @Published var error: String?

    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?
    private let service: BitcoinServiceProtocol

    init(service: BitcoinServiceProtocol = BitcoinService()) {
        self.service = service
        fetchRates()
    }

    func fetchRates() {
        isLoading = true

        service.fetchHistoricalRates()
            // Filter: One rate per day (latest for each date)
            .map { rawRates in
                let grouped = Dictionary(grouping: rawRates) { $0.date.utcStartOfDay() }

                let averaged = grouped.compactMap { (date, group) -> BitcoinRate? in
                    guard !group.isEmpty else { return nil }
                    let avg = group.map(\.eur).reduce(0, +) / Double(group.count)
                    return BitcoinRate(date: date, eur: avg)
                }

                return averaged
                    .sorted { $0.date > $1.date }
                    .prefix(14)
            }
            .map { Array($0) } // convert prefix result to Array
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.error = error.localizedDescription
                }
            }, receiveValue: { rates in
                self.rates = rates
            })
            .store(in: &cancellables)
    }

    func startAutoUpdate() {
        if (timerCancellable != nil) {
            stopAutoUpdate()
        }
        
        timerCancellable = Timer.publish(every: 60, on: .main, in: .common)
             .autoconnect()
             .sink { [weak self] _ in
                 self?.fetchRates()
             }
    }
    
    func stopAutoUpdate() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}
