import Foundation

final class CryptoViewModel {
    private let service = CryptoService.shared
    var cryptos: [Crypto] = []
    var onUpdate: (() -> Void)?

    func fetchCryptos() {
        service.fetchCrypto { [weak self] result in
            switch result {
            case .success(let cryptos):
                self?.cryptos = cryptos.sorted { $0.name < $1.name }
                self?.onUpdate?()
            case .failure(let error):
                print("Ошибка при загрузке криптовалют: \(error.localizedDescription)")
            }
        }
    }
}
