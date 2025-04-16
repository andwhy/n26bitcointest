
import SwiftUI

struct BitcoinListView: View {
    @StateObject var viewModel = BitcoinListViewModel()

    var body: some View {
            NavigationStack {
                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading...")
                    } else if let error = viewModel.error {
                        Text(error).foregroundColor(.red)
                    } else {
                        List(viewModel.rates) { rate in
                            NavigationLink(value: rate.date) {
                                HStack {
                                    Text(rate.date.formatted(date: .abbreviated, time: .omitted))
                                    Spacer()
                                    Text("€\(Int(rate.eur))")
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Bitcoin Rates")
                .navigationDestination(for: Date.self) { date in
                    BitcoinDetailView(date: date)
                        .onAppear {
                            viewModel.stopAutoUpdate()
                        }
                        .onDisappear {
                            viewModel.startAutoUpdate()
                        }
                }
            }
            .onAppear {
                viewModel.startAutoUpdate()
            }
        }
}
