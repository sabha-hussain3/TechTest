import Foundation

struct Products: Decodable {
    let results: [Product]
}

struct Product: Decodable {
    let name: String
    let designer: Designer
    let price: Price
    let url: String
    let primaryImageMap: PrimaryImageMap
}

struct Designer: Decodable {
    let code: String?
    let name: String
    let url: String?
    let designerCategoryCode: String?
}

struct Price: Decodable {
    let formattedValue: String
    let value: Double
}

struct PrimaryImageMap: Decodable {
    let thumbnail: Thumbnail
}

struct Thumbnail: Decodable {
    let url: String
}
