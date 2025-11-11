import Foundation

final class CurrencyViewModel {
    private let service = CurrencyService.shared
    var currencies: [Currency] = []
    var onUpdate: (() -> Void)?

    func fetchCurrencies() {
        service.fetchRates { [weak self] result in
            switch result {
            case .success(let currencies):
                self?.currencies = currencies.sorted { $0.code < $1.code }
                self?.onUpdate?()
            case .failure(let error):
                print("Ошибка при загрузке валют: \(error.localizedDescription)")
            }
        }
    }
}
