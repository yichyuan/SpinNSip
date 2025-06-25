import Foundation

actor DrinkSelectorActor {
    private var cocktails: [Cocktail] = []

    func loadCocktails() async throws {
        guard let url = Bundle.main.url(forResource: "cocktails", withExtension: "json") else { return }
        let data = try Data(contentsOf: url)
        cocktails = try JSONDecoder().decode([Cocktail].self, from: data)
    }

    func randomCocktail() -> Cocktail? {
        cocktails.randomElement()
    }
    
    func specificCocktail(_ index: Int) -> Cocktail? {
        cocktails[index]
    }
}
