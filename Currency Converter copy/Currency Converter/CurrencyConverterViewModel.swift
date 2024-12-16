import Foundation

class CurrencyConverterViewModel: ObservableObject {
    @Published var sourceCurrency: String = "USD"
    @Published var targetCurrency: String = "KZT"
    @Published var currencies: [String] = ["USD", "EUR", "GBP", "JPY", "AUD", "KZT"]
    @Published var amount: String = ""  // Add this property to hold the user's input amount

    func fetchExchangeRate(completion: @escaping (Double?) -> Void, onError: @escaping (String) -> Void) {
        guard let amountValue = Double(amount) else {
            onError("Invalid amount")
            return
        }

        let urlString = "https://api.exchangerate-api.com/v4/latest/\(sourceCurrency)"
        
        guard let url = URL(string: urlString) else {
            onError("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                onError(error.localizedDescription)
                return
            }

            guard let data = data else {
                onError("No data received")
                return
            }

            if let exchangeData = try? JSONDecoder().decode(ExchangeRateResponse.self, from: data) {
                let rate = exchangeData.rates[self.targetCurrency]
                completion(rate)
            } else {
                onError("Failed to decode exchange rate data")
            }
        }
        task.resume()
    }
}

struct ExchangeRateResponse: Decodable {
    let rates: [String: Double]
}
