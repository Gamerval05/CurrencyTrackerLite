import UIKit

//Модель данных
struct CurrencyRate: Codable {
    let data: [String: Double]
}

protocol CurrencyServiceProtocol {
    func fetchRates(completion: @escaping (Result<[(String, Double)], Error>) -> Void)
}

class CurrencyService: CurrencyServiceProtocol {
    private let apiURL = "https://api.freecurrencyapi.com/v1/latest?apikey=fca_live_efKRwZCU3giztDIrBtCUyzH8MiqPjxrkWBzaln7q&currencies=USD,EUR,GBP,JPY,CNY,AUD,CAD,CHF,INR&base_currency=RUB"

    func fetchRates(completion: @escaping (Result<[(String, Double)], Error>) -> Void) {
        guard let url = URL(string: apiURL) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(CurrencyRate.self, from: data)
                let sortedRates = decoded.data.sorted(by: { $0.key < $1.key })
                completion(.success(sortedRates))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

class CurrencyViewModel {
    private let service: CurrencyServiceProtocol
    private(set) var rates: [(String, Double)] = []
    private(set) var lastRates: [String: Double] = [:]

    var onUpdate: (() -> Void)?

    init(service: CurrencyServiceProtocol = CurrencyService()) {
        self.service = service
    }

    func fetchRates() {
        service.fetchRates { [weak self] result in
            switch result {
            case .success(let newRates):
                DispatchQueue.main.async {
                    self?.lastRates = Dictionary(uniqueKeysWithValues: self?.rates ?? [])
                    self?.rates = newRates
                    self?.onUpdate?()
                }
            case .failure(let error):
                print("Ошибка загрузки: \(error.localizedDescription)")
            }
        }
    }
}

//Главный экран
class ViewController: UIViewController, UITableViewDataSource {

    private let tableView = UITableView()
    private let viewModel = CurrencyViewModel()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Валюты мира"
        l.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let cryptoButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Криптовалюты 💎", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        b.backgroundColor = .systemBlue
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 12
        b.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let metalsButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Металлы 🪙", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        b.backgroundColor = .systemYellow
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 12
        b.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    //Флаги популярных валют
    private let currencyFlags: [String: String] = [
        "USD": "🇺🇸",
        "EUR": "🇪🇺",
        "GBP": "🇬🇧",
        "JPY": "🇯🇵",
        "CNY": "🇨🇳",
        "AUD": "🇦🇺",
        "CAD": "🇨🇦",
        "CHF": "🇨🇭",
        "INR": "🇮🇳"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Курс валют"
        view.backgroundColor = .systemBackground

        setupTableView()
        view.addSubview(titleLabel)
        view.addSubview(cryptoButton)
        view.addSubview(metalsButton)
        cryptoButton.addTarget(self, action: #selector(openCrypto), for: .touchUpInside)
        metalsButton.addTarget(self, action: #selector(openMetals), for: .touchUpInside)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            cryptoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            cryptoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cryptoButton.trailingAnchor.constraint(equalTo: metalsButton.leadingAnchor, constant: -12),
            cryptoButton.widthAnchor.constraint(equalTo: metalsButton.widthAnchor),

            metalsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            metalsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: cryptoButton.topAnchor, constant: -12)
        ])

        viewModel.onUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.fetchRates()
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.viewModel.fetchRates()
        }
    }

    //Настройка таблицы
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        view.addSubview(tableView)
    }

    //Таблица
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let rate = viewModel.rates[indexPath.row]

        //Проверяем флаг
        guard let flag = currencyFlags[rate.0] else { return cell }

        //Тренд
        let oldRate = viewModel.lastRates[rate.0] ?? rate.1
        let trendSymbol: String
        if rate.1 < oldRate {
            trendSymbol = "📉" //курс валюты упал
        } else if rate.1 > oldRate {
            trendSymbol = "📈" //курс валюты вырос
        } else {
            trendSymbol = "➖"
        }

        //Конвертация
        let rublesPerUnit = 1.0 / rate.1
        let formatted = String(format: "%.2f ₽", rublesPerUnit)

        //Оформление ячейки
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        cell.textLabel?.text = "\(flag) \(rate.0)\n\(trendSymbol) 1 \(rate.0) = \(formatted)"
        cell.backgroundColor = UIColor.systemGray6
        cell.layer.cornerRadius = 12
        cell.clipsToBounds = true

        return cell
    }

    @objc private func openCrypto() {
        let vc = CryptoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openMetals() {
        let vc = MetalsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
