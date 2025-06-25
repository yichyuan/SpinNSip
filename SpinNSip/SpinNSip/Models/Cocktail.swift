import Foundation

struct Cocktail: Codable {
    let name: String
    let ingredients: [String]
    let instructions: String
    let imageUrl: String?
    let tags: [String]
}
