import UIKit

class ProductListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var productNameLabel: UILabel!
    @IBOutlet private var designerNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    weak var delegate: ProductListCellProtocol?
    var viewModel: ProductListCellViewModel!
    
    func bind(viewModel: ProductListCellViewModel) {
        self.viewModel = viewModel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        priceLabel.text = ""
    }
    
    func configureCell(with viewModel: ProductListCellViewModel) {
        productNameLabel.text = viewModel.productName
        designerNameLabel.text = viewModel.designerName
        priceLabel.text = viewModel.price
        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
        
//        getProductsImage(with: viewModel.product.url)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.delegate?.didTapCell(for: self)
    }
    
    func getProductsImage(with url: String) {
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
                        self.imageView.image = UIImage(data: data)
                        
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
        }
        task.resume()
    }
}
