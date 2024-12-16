import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CurrencyConverterViewModel()
    @State private var conversionResult: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter amount", text: $viewModel.amount)
                    .keyboardType(.decimalPad)
                                        .padding()
                                        .padding(.horizontal, 20)
                                        .background(Color.gray.opacity(0.2))  // Background for the text field
                                        .cornerRadius(12)  // Rounded corners
                                        .padding(.horizontal, 20)

                HStack {
                    Picker("From", selection: $viewModel.sourceCurrency) {
                        ForEach(viewModel.currencies, id: \.self) { currency in
                            Text(currency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    Button(action: swapCurrencies) {
                        Image(systemName: "arrow.swap")
                            .font(.title2)
                    }

                    Picker("To", selection: $viewModel.targetCurrency) {
                        ForEach(viewModel.currencies, id: \.self) { currency in
                            Text(currency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding()

                Button(action: convertCurrency) {
                    Text("Convert")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else {
                    Text(conversionResult)
                        .font(.headline)
                        .padding()
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Currency Converter")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func convertCurrency() {
        guard let amountValue = Double(viewModel.amount.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            alertMessage = "Invalid amount"
            showAlert = true
            return
        }

        isLoading = true
        viewModel.fetchExchangeRate { rate in
            isLoading = false
            if let rate = rate {
                let result = amountValue * rate
                conversionResult = "\(String(format: "%.2f", result)) \(viewModel.targetCurrency)"
            }
        } onError: { error in
            isLoading = false
            alertMessage = error
            showAlert = true
        }
    }

    private func swapCurrencies() {
        let temp = viewModel.sourceCurrency
        viewModel.sourceCurrency = viewModel.targetCurrency
        viewModel.targetCurrency = temp
    }
}
