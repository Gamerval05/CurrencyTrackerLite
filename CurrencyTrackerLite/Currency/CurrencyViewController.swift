import UIKit

final class CurrencyViewController: UIViewController {
    private let viewModel = CurrencyViewModel()
    private let tableView = UITableView()
    private let currencyFlags: [String: String] = [
        "USD": "🇺🇸",
        "EUR": "🇪🇺",
        "GBP": "🇬🇧",
        "JPY": "🇯🇵",
        "CNY": "🇨🇳",
        "RUB": "🇷🇺",
        "AUD": "🇦🇺",
        "CAD": "🇨🇦",
        "CHF": "🇨🇭",
        "INR": "🇮🇳",
        "BRL": "🇧🇷",
        "ZAR": "🇿🇦",
        "KRW": "🇰🇷",
        "MXN": "🇲🇽",
        "TRY": "🇹🇷",
        "SEK": "🇸🇪",
        "NOK": "🇳🇴",
        "NZD": "🇳🇿"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Валюты мира"
        view.backgroundColor = .systemBackground
        setupTableView()
        bindViewModel()
        viewModel.fetchCurrencies()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension CurrencyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.currencies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let currency = viewModel.currencies[indexPath.row]
        let flag = currencyFlags[currency.code] ?? "🏳️"
        cell.textLabel?.text = "\(flag) \(currency.code): \(String(format: "%.2f ₽", currency.rate))"
        return cell
    }
}
