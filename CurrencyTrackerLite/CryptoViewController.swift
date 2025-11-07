//
//  CryptoViewController.swift
//  CurrencyTrackerLite
//
//  Created by Валера on 07.11.2025.
//

import UIKit

struct CryptoResponse: Codable {
    let bitcoin: CryptoData?
    let ethereum: CryptoData?
    let dogecoin: CryptoData?
    let pepe: CryptoData?
    let trumpcoin: CryptoData?
}

struct CryptoData: Codable {
    let rub: Double
    let rub_24h_change: Double?
}

protocol CryptoServiceProtocol {
    func fetchCryptoRates(completion: @escaping (Result<[(String, CryptoData)], Error>) -> Void)
}

class CryptoService: CryptoServiceProtocol {
    private let apiURL = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,dogecoin,pepe,trumpcoin&vs_currencies=rub&include_24hr_change=true"

    func fetchCryptoRates(completion: @escaping (Result<[(String, CryptoData)], Error>) -> Void) {
        guard let url = URL(string: apiURL) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(CryptoResponse.self, from: data)
                var loaded: [(String, CryptoData)] = []
                if let btc = decoded.bitcoin { loaded.append(("bitcoin", btc)) }
                if let eth = decoded.ethereum { loaded.append(("ethereum", eth)) }
                if let doge = decoded.dogecoin { loaded.append(("dogecoin", doge)) }
                if let pepe = decoded.pepe { loaded.append(("pepe", pepe)) }
                if let trump = decoded.trumpcoin { loaded.append(("trumpcoin", trump)) }
                completion(.success(loaded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

class CryptoViewModel {
    private let service: CryptoServiceProtocol
    private(set) var cryptos: [(String, CryptoData)] = []
    var onUpdate: (() -> Void)?

    init(service: CryptoServiceProtocol = CryptoService()) {
        self.service = service
    }

    func fetchCryptoRates() {
        service.fetchCryptoRates { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.cryptos = data
                    self?.onUpdate?()
                }
            case .failure(let error):
                print("Ошибка загрузки криптовалют: \(error.localizedDescription)")
            }
        }
    }
}

class CryptoViewController: UIViewController, UITableViewDataSource {

    private let tableView = UITableView()
    private let viewModel = CryptoViewModel()

    private let cryptoLogos: [String: String] = [
        "bitcoin": "🟠",
        "ethereum": "💎",
        "dogecoin": "🐶",
        "pepe": "🐸",
        "trumpcoin": "🇺🇸"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Криптовалюты"
        view.backgroundColor = .systemBackground

        setupTableView()

        viewModel.onUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.fetchCryptoRates()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cryptos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let crypto = viewModel.cryptos[indexPath.row]
        let name = crypto.0
        let data = crypto.1

        let logo = cryptoLogos[name] ?? "💰"
        let price = String(format: "%.2f ₽", data.rub)
        let change = data.rub_24h_change ?? 0.0

        let trend = change > 0 ? "📈" : (change < 0 ? "📉" : "➖")
        let changeText = String(format: "%.2f%%", change)

        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        cell.textLabel?.text = "\(logo) \(name.capitalized) \(trend)\n1 \(name.capitalized) = \(price)  (\(changeText))"
        cell.backgroundColor = UIColor.systemGray6
        cell.layer.cornerRadius = 12
        cell.clipsToBounds = true

        return cell
    }
}
