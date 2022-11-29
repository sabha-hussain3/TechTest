import XCTest
@testable import MatchesFashion

final class MatchesFashionTests: XCTestCase {
    var mockProducts: Products!
    var mockDesigner: Designer!
    var price: Price!
    var mockProduct: Product!
    var thumbnail: Thumbnail!
    var primaryImageMap: PrimaryImageMap!
    var currency: Currency!
    
    var viewModel: ProductListCellViewModel!
    
    override func setUpWithError() throws {
        mockDesigner = .init(code: "designerCode", name: "designerName", url: "", designerCategoryCode: "")
        price = .init(formattedValue: "£200.00", value: 200.00)
        thumbnail = .init(url: "imageUrl")
        primaryImageMap = .init(thumbnail: thumbnail)
        mockProduct = .init(name: "productName", designer: mockDesigner, price: price, url: "urlForImage", primaryImageMap: primaryImageMap)
        currency = .init(rates: ["AED": 3673.928602, "USD": 1000, "AUD": 1482.58842])
        
        viewModel = ProductListCellViewModel(product: mockProduct)
    }
    
    override func tearDownWithError() throws {
        mockDesigner = nil
        price = nil
        thumbnail = nil
        primaryImageMap = nil
        mockProduct = nil
        currency = nil
    }
    
    func test_priceValue_convertsForCurrency_inAED() {
        guard let currencyForAED = currency.rates["AED"] else { return }
        let convertedPrice = viewModel.convertedPrice(for: mockProduct.price.value, currency: currencyForAED)
        XCTAssertEqual(convertedPrice, "734785.72")
    }
    
    func test_priceValue_convertsForCurrency_inUSD() {
        guard let currencyForUSD = currency.rates["USD"] else { return }
        let convertedPrice = viewModel.convertedPrice(for: mockProduct.price.value, currency: currencyForUSD)
        XCTAssertEqual(convertedPrice, "200000.00")
    }
    
    func test_priceValue_convertsForCurrency_inAUD() {
        guard let currencyForAUD = currency.rates["AUD"] else { return }
        let convertedPrice = viewModel.convertedPrice(for: mockProduct.price.value, currency: currencyForAUD)
        XCTAssertEqual(convertedPrice, "296517.68")
    }
    
    func test_priceValue_forMultipleProducts_currencyConversion_inAED() {
        let products = setupMultipleProducts()
        var priceArray: [String] = []
        products.results.forEach { item in
            guard let currencyForAED = currency.rates["AED"] else { return }
            let convertedPrice = viewModel.convertedPrice(for: item.price.value, currency: currencyForAED)
            priceArray.append(convertedPrice)
        }
        XCTAssertEqual(priceArray, ["1102178.58", "734785.72", "1285875.01"])
    }
    
    func test_priceValue_forMultipleProducts_currencyConversion_inUSD() {
        let products = setupMultipleProducts()
        var priceArray: [String] = []
        products.results.forEach { item in
            guard let currencyForUSD = currency.rates["AED"] else { return }
            let convertedPrice = viewModel.convertedPrice(for: item.price.value, currency: currencyForUSD)
            priceArray.append(convertedPrice)
        }
        XCTAssertEqual(priceArray, ["1102178.58", "734785.72", "1285875.01"])
    }
    
    func test_priceValue_forMultipleProducts_currencyConversion_inAUD() {
        let products = setupMultipleProducts()
        var priceArray: [String] = []
        products.results.forEach { item in
            guard let currencyForAUD = currency.rates["AUD"] else { return }
            let convertedPrice = viewModel.convertedPrice(for: item.price.value, currency: currencyForAUD)
            priceArray.append(convertedPrice)
        }
        XCTAssertEqual(priceArray, ["444776.53", "296517.68", "518905.95"])
    }
    
    func setupMultipleProducts() -> Products {
        let price: Price = .init(formattedValue: "£300.00", value: 300.00)
        let product: Product = .init(name: "productName", designer: mockDesigner, price: price, url: "urlForImage", primaryImageMap: primaryImageMap)
        let secondPrice: Price = .init(formattedValue: "£350.00", value: 350.00)
        let secondProduct: Product = .init(name: "productName", designer: mockDesigner, price: secondPrice, url: "urlForImage", primaryImageMap: primaryImageMap)
        return Products(results: [product, mockProduct, secondProduct])
    }
}
