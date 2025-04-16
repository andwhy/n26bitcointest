
import SwiftUI

struct BitcoinListView: View {
    @StateObject var viewModel = BitcoinListViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.rates) { rate in
                NavigationLink(destination: BitcoinDetailView(date: rate.date)) {
                    HStack {
                        Text(rate.date.formatted(date: .abbreviated, time: .omitted))
                        Spacer()
                        Text("€\(Int(rate.eur))")
                    }
                }
            }
            .navigationTitle("Bitcoin Rates")
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let error = viewModel.error {
                    Text(error).foregroundColor(.red)
                }
            }
        }
    }
}
