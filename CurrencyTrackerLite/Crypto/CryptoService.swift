import Foundation

final class CryptoService {
    static let shared = CryptoService()
    private init() {}

    private let baseURL = "https://api.coingecko.com/api/v3/simple/price"

    func fetchCrypto(completion: @escaping (Result<[Crypto], Error>) -> Void) {
        let ids = "bitcoin,ethereum,dogecoin,trumpcoin"
        let urlString = "\(baseURL)?ids=\(ids)&vs_currencies=rub"
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode([String: [String: Double]].self, from: data)
                let cryptos = decoded.map { key, value in
                    Crypto(name: key.capitalized, symbol: key.uppercased(), price: value["rub"] ?? 0.0)
                }
                completion(.success(cryptos))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
