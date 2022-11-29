import UIKit

class ProductDetailsViewController: UIViewController {

    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var designerLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var urlTextView: UITextView!
    @IBOutlet private var productImageView: UIImageView!
    
    var productName = ""
    var designerName = ""
    var productPrice = ""
    var url = ""
    var productUrl = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        configureProductDetails()
    }
    
    func configureProductDetails() {
        nameLabel.text = productName
        designerLabel.text = designerName
        priceLabel.text = productPrice
        urlTextView.text = url
        urlTextView.isEditable = false
//        getProductsImage(with: productUrl)
    }
    
    private func getProductsImage(with url: String) {
        let url = URL(string: "http://\(url)")
        
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
                    DispatchQueue.main.async {
                        self.productImageView.image = UIImage(data: data)
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
        }
        task.resume()
    }
}
