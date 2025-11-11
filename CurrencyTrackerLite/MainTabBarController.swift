import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let currencyVC = UINavigationController(rootViewController: CurrencyViewController())
        currencyVC.tabBarItem = UITabBarItem(title: "Валюты", image: UIImage(systemName: "dollarsign.circle"), tag: 0)

        let cryptoVC = UINavigationController(rootViewController: CryptoViewController())
        cryptoVC.tabBarItem = UITabBarItem(title: "Крипта", image: UIImage(systemName: "bitcoinsign.circle"), tag: 1)

        let metalsVC = UINavigationController(rootViewController: MetalViewController())
        metalsVC.tabBarItem = UITabBarItem(title: "Металлы", image: UIImage(systemName: "diamond.circle"), tag: 2)

        viewControllers = [currencyVC, cryptoVC, metalsVC]
    }
}
