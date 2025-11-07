import UIKit

protocol MetalServiceProtocol {
    func fetchMetals(completion: @escaping (Result<[(String, Double)], Error>) -> Void)
}

class MetalService: MetalServiceProtocol {
    private let apiKey = "5a36f44d73255dcf9c4f15821353de39"
    private let usdToRubRate = 90.0
    private let ounceToGram = 31.1035

    func fetchMetals(completion: @escaping (Result<[(String, Double)], Error>) -> Void) {
        let urlString = "https://api.metalpriceapi.com/v1/latest?api_key=\(apiKey)&base=USD&currencies=XAU,XAG,XPT,XPD"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(MetalPriceResponse.self, from: data)
                guard decoded.success else {
                    completion(.failure(NSError(domain: "APIError", code: 1)))
                    return
                }

                let filteredRates = decoded.rates.filter { ["XAU", "XAG", "XPT", "XPD"].contains($0.key) }
                let metalsArray = filteredRates.map { (symbol, pricePerOunceUSD) -> (String, Double) in
                    let usdPerOunce = 1 / pricePerOunceUSD
                    let usdPerGram = usdPerOunce / self.ounceToGram
                    let rubPerGram = usdPerGram * self.usdToRubRate
                    return (symbol, rubPerGram)
                }

                completion(.success(metalsArray))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

class MetalsViewModel {
    private let service: MetalServiceProtocol
    private(set) var metals: [(String, Double)] = []
    var onUpdate: (() -> Void)?

    init(service: MetalServiceProtocol = MetalService()) {
        self.service = service
    }

    func fetchMetals() {
        service.fetchMetals { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.metals = data
                    self?.onUpdate?()
                }
            case .failure(let error):
                print("Ошибка загрузки металлов: \(error.localizedDescription)")
            }
        }
    }
}

struct MetalPriceResponse: Codable {
    let success: Bool
    let rates: [String: Double]
}

class MetalsViewController: UIViewController, UITableViewDataSource {
    private let tableView = UITableView()
    private let viewModel = MetalsViewModel()

    private let metalIcons: [String: String] = [
        "xau": "🥇", // золото
        "xag": "🥈", // серебро
        "xpt": "💎", // платина
        "xpd": "⚪️"  // палладий
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Драгоценные металлы"
        view.backgroundColor = .systemBackground
        setupTableView()
        viewModel.onUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.fetchMetals()
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
        viewModel.metals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let metal = viewModel.metals[indexPath.row]
        let symbol = metal.0
        let price = metal.1
        let icon = metalIcons[symbol.lowercased()] ?? "💰"

        let name: String
        switch symbol.lowercased() {
        case "xau", "gold": name = "Золото"
        case "xag", "silver": name = "Серебро"
        case "xpt", "platinum": name = "Платина"
        case "xpd", "palladium": name = "Палладий"
        default: name = symbol.uppercased()
        }

        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        cell.textLabel?.text = "\(icon) \(name)\n1 г = \(String(format: "%.2f ₽", price))"
        cell.backgroundColor = UIColor.systemGray6
        cell.layer.cornerRadius = 12
        cell.clipsToBounds = true

        return cell
    }
}
