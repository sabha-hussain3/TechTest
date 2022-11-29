
import Combine
import UIKit

class ProductListViewController: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var currencyButton: UIButton!

    private let screenSize = UIScreen.main.bounds
    private var cellSize: CGSize!
    
    private var products = [Products]()
    private var currency = [Currency]()
    
    private var selectedCurrencyRate: Double? = 0.0
    private var shouldConvertCurrency = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        configureProductCellSize()
        getProductsList()
        getCurrencyRates()
        populateCurrencyButton()
        self.collectionView.reloadData()
    }
    
    private func configureProductCellSize() {
        let width = ((screenSize.width-32)/2) * 0.9
        let height = width * 2.0
        cellSize = CGSize(width: width, height: height)
    }

    private func populateCurrencyButton() {
        let closure = {(action: UIAction) in
            let key = action.title
            self.currency.map {
                let rate = $0.rates[key]
                self.selectedCurrencyRate = rate
                self.shouldConvertCurrency = true
                self.collectionView.reloadData()
            }
        }
        currencyButton.menu = UIMenu(children: [
            UIAction(title: "GBP", state: .on, handler: closure),
            UIAction(title: "AED", state: .on, handler: closure),
            UIAction(title: "AUD", state: .on, handler: closure),
            UIAction(title: "USD", state: .on, handler: closure)])
        
        currencyButton.showsMenuAsPrimaryAction = true
        currencyButton.changesSelectionAsPrimaryAction = true
        
        currencyButton.layer.cornerRadius = 5
        currencyButton.layer.borderColor = UIColor.black.cgColor
        currencyButton.layer.borderWidth = 2
        
    }
}

extension ProductListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("section \(indexPath.section) for row: \(indexPath.row)")
    }
}

extension ProductListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products[section].results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ProductListCollectionViewCell
        let product = products[indexPath.section].results[indexPath.item]
        let productListCellViewModel = ProductListCellViewModel(product: product)
        cell.configureCell(with: productListCellViewModel)
        cell.delegate = self
        
        if shouldConvertCurrency {
            guard let selectedCurrencyRate else { return cell }
            cell.priceLabel.text = productListCellViewModel.convertedPrice(for: product.price.value, currency: selectedCurrencyRate)
            print(productListCellViewModel.convertedPrice(for: product.price.value, currency: selectedCurrencyRate))
            shouldConvertCurrency = false
            self.collectionView.reloadData()
        }
        return cell
    }
}

extension ProductListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}

extension ProductListViewController: ProductListCellProtocol {
    func didTapCell(for cell: ProductListCollectionViewCell) {
        let productDetailsViewController = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController
        
        if let tapIndexPath = self.collectionView.indexPath(for: cell) {
            let product = products[tapIndexPath.section].results[tapIndexPath.row]
            productDetailsViewController?.productName = product.name
            productDetailsViewController?.designerName = product.designer.name
            productDetailsViewController?.productPrice = product.price.formattedValue
            productDetailsViewController?.url = product.url
//            productDetailsViewController?.productUrl = product.primaryImageMap.thumbnail.url
        }
        self.navigationController?.pushViewController(productDetailsViewController!, animated: true)
    }
}

extension Dictionary where Value: Equatable {
    func findKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

extension ProductListViewController {
    private func getProductsList() {
        let url = URL(string: "https://www.matchesfashion.com/womens/shop?format=json")
        
        guard let url else { fatalError() }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let products = try decoder.decode(Products.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.products.append(products)
                        self.collectionView?.reloadData()
                        self.collectionView.refreshControl?.endRefreshing()
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
        }
        task.resume()
    }
    
    private func getCurrencyRates() {
        let url = URL(string: "https://api.exchangerate.host/latest?base=USD&amount=1000")
        
        guard let url else { fatalError() }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let currency = try decoder.decode(Currency.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.currency.append(currency)
                    }
                } catch {
                    print("Failed: \(error)")
                }
            }
        }
        task.resume()
    }
}
