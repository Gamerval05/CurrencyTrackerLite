import Foundation

final class MetalService {
    static let shared = MetalService()
    private init() {}

    private let apiKey = "5a36f44d73255dcf9c4f15821353de39"
    private let baseURL = "https://api.metalpriceapi.com/v1/latest?api_key=5a36f44d73255dcf9c4f15821353de39&base=USD"

    func fetchMetals(completion: @escaping (Result<[Metal], Error>) -> Void) {
        guard let url = URL(string: baseURL) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let response = try JSONDecoder().decode(MetalResponse.self, from: data)
                let filteredRates = response.rates.filter { key, _ in
                    key == "XAU" || key == "XAG" || key == "XPT" || key == "XPD"
                }

                let usdToRub = 92.0
                let ounceToGram = 31.1035
                var metals: [Metal] = []

                for (key, value) in filteredRates {
                    let name: String
                    switch key {
                    case "XAU": name = "Золото"
                    case "XAG": name = "Серебро"
                    case "XPT": name = "Платина"
                    case "XPD": name = "Палладий"
                    default: name = key
                    }

                    let rubPerGram = (1 / value) / ounceToGram * usdToRub
                    metals.append(Metal(name: name, price: rubPerGram))
                }

                completion(.success(metals))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

private struct MetalResponse: Codable {
    let success: Bool?
    let base: String?
    let timestamp: Int?
    let rates: [String: Double]
}

private struct ErrorResponse: Codable {
    let success: Bool
    let error: APIError?
}

private struct APIError: Codable {
    let code: Int
    let type: String
    let info: String?
}
