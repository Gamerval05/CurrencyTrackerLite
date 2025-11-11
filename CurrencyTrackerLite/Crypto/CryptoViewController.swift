import UIKit

final class CryptoViewController: UIViewController, UITableViewDataSource {
    private let tableView = UITableView()
    private var cryptos: [Crypto] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Криптовалюты"
        view.backgroundColor = .systemBackground

        tableView.frame = view.bounds
        tableView.dataSource = self
        view.addSubview(tableView)

        fetchCrypto()
    }

    func fetchCrypto() {
        CryptoService.shared.fetchCrypto { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cryptos):
                    self?.cryptos = cryptos
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Ошибка крипты:", error)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cryptos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let crypto = cryptos[indexPath.row]

        let icons: [String: String] = [
            "BTC": "🟠",
            "ETH": "🟣",
            "DOGE": "🟡",
            "TRUMP": "🇺🇸"
        ]
        let emoji = icons[crypto.symbol.uppercased()] ?? "💰"
        cell.textLabel?.text = "\(emoji) \(crypto.name)"
        cell.detailTextLabel?.text = String(format: "%.2f ₽", crypto.price)
        return cell
    }
}
