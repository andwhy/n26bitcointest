
import SwiftUI

struct BitcoinDetailView: View {
    let date: Date
    @StateObject var viewModel = BitcoinDetailViewModel()

    var body: some View {
        VStack(spacing: 16) {
            if let detail = viewModel.detail {
                Text("Date: \(date.formatted(date: .abbreviated, time: .omitted))")
                Text("EUR: €\(Int(detail.eur))")
                Text("USD: $\(Int(detail.usd))")
                Text("GBP: £\(Int(detail.gbp))")
            } else if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                Text(error).foregroundColor(.red)
            }
        }
        .onAppear { viewModel.fetchDetails(for: date) }
        .navigationTitle("Detail")
    }
}
