import Foundation

@objc protocol ProductListCellProtocol {
    func didTapCell(for cell: ProductListCollectionViewCell)
}

class ProductListCellViewModel {
    let product: Product
    
    init(product: Product) {
        self.product = product
    }
    
    var productName: String {
        return product.name
    }
    
    var designerName: String {
        return product.designer.name
    }
    
    var price: String {
        product.price.formattedValue
    }
    
    func convertedPrice(for price: Double, currency: Double) -> String {
        let convertedPrice = price * currency
        let roundedPrice = String(format: "%.2f", convertedPrice)
        return "\(roundedPrice)"
    }
}
