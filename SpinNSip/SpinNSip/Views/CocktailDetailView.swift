import SwiftUI

struct CocktailDetailView: View {
    let cocktail: Cocktail
    @State private var isTried = false
    @State private var isFavorite = false


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(cocktail.name)
                    .font(.largeTitle)
                    .bold()

                if let imageUrl = cocktail.imageUrl, let url = URL(
                    string: imageUrl
                ) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                            .cornerRadius(12)
                    } placeholder: {
                        ProgressView()
                    }
                }

                // 標籤
                if !cocktail.tags.isEmpty {
                    HStack {
                        ForEach(cocktail.tags, id: \ .self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(6)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }

                // 材料
                Text("材料")
                    .font(.headline)
                ForEach(cocktail.ingredients, id: \ .self) { item in
                    Text("• \(item)")
                }

                // 做法
                Text("製作方法")
                    .font(.headline)
                Text(cocktail.instructions)

                // 動作區
                HStack(spacing: 20) {
                    Button(action: { isTried.toggle() }) {
                        Label(
                            isTried ? "已嘗試" : "我喝過了",
                            systemImage: isTried ? "checkmark.circle.fill" : "checkmark.circle"
                        )
                        .foregroundColor(isTried ? .green : .primary)
                    }

                    Button(action: { isFavorite.toggle() }) {
                        Label(
                            isFavorite ? "已收藏" : "加入收藏",
                            systemImage: isFavorite ? "heart.fill" : "heart"
                        )
                        .foregroundColor(isFavorite ? .red : .primary)
                    }

                    ShareLink(item: cocktail.name) {
                        Label("分享", systemImage: "square.and.arrow.up")
                    }
                }
                .padding(.top)
            }
            .padding()
        }
    }

}
