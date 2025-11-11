import Foundation

final class MetalViewModel {
    private let service = MetalService.shared
    var metals: [Metal] = []
    var onUpdate: (() -> Void)?

    func fetchMetals() {
        service.fetchMetals { [weak self] result in
            switch result {
            case .success(let metals):
                self?.metals = metals.sorted { $0.name < $1.name }
                self?.onUpdate?()
            case .failure(let error):
                print("Ошибка при загрузке металлов: \(error.localizedDescription)")
            }
        }
    }
}
