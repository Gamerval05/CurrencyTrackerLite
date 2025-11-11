import Foundation

final class CurrencyService {
    static let shared = CurrencyService()
    private init() {}

    private let apiKey = "fca_live_efKRwZCU3giztDIrBtCUyzH8MiqPjxrkWBzaln7q"
    private let baseURL = "https://api.freecurrencyapi.com/v1/latest"

    func fetchRates(completion: @escaping (Result<[Currency], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)?apikey=\(apiKey)&base_currency=USD") else { return }

        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let response = try JSONDecoder().decode(CurrencyResponse.self, from: data)
                let data = response.data
                
                let needed = ["USD", "RUB", "EUR", "GBP", "JPY", "CNY"]
                
                guard let rubRate = data["RUB"] else {
                    completion(.failure(NSError(domain: "CurrencyService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Нет курса RUB в ответе API"])))
                    return
                }
                
                var result: [Currency] = []
                
                for code in needed {
                    let rateInRub: Double
                    
                    if code == "USD" {
                        rateInRub = rubRate
                    } else if code == "RUB" {
                        rateInRub = 1.0
                    } else if let value = data[code] {
                        rateInRub = rubRate / value
                    } else {
                        continue
                    }
                    
                    result.append(Currency(code: code, rate: rateInRub))
                }
                
                completion(.success(result))
            } catch {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Currency API raw response: \(jsonString)")
                }
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

private struct CurrencyResponse: Codable {
    let data: [String: Double]
}
