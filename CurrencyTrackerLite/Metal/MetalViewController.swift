import UIKit

final class MetalViewController: UIViewController, UITableViewDataSource {
    private let tableView = UITableView()
    private var metals: [Metal] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Драгметаллы"
        view.backgroundColor = .systemBackground

        tableView.frame = view.bounds
        tableView.dataSource = self
        view.addSubview(tableView)

        fetchMetals()
    }

    func fetchMetals() {
        MetalService.shared.fetchMetals { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let metals):
                    self?.metals = metals
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Ошибка металлов:", error)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        metals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let metal = metals[indexPath.row]

        let icons = [
            "Золото": "🥇",
            "Серебро": "🥈",
            "Платина": "⚪️",
            "Палладий": "🔘"
        ]
        let emoji = icons[metal.name] ?? "💎"

        cell.textLabel?.text = "\(emoji) \(metal.name)"
        cell.detailTextLabel?.text = String(format: "%.2f ₽/г", metal.price)
        return cell
    }
}
