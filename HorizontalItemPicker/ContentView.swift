import SwiftUI

struct CardItem: Identifiable {
    let id: Int
}

struct ContentView: View {
    @State var selectedIndex: Int = 0
    let items: [CardItem] = [
        CardItem(id: 1),
        CardItem(id: 2),
        CardItem(id: 3),
        CardItem(id: 4),
        CardItem(id: 5),
        CardItem(id: 6)
    ]
    var body: some View {
        VStack {
            HorizontalItemPicker(
                selectedIndex: $selectedIndex,
                items: items,
                itemSize: CGSize(width: 100, height: 100),
                spacingMode: .fixed(spacing: 10),
                sideItemScale: 0.7,
                sideItemAlpha: 1
            ) { item in
                VStack {
                    Text("Item \(item.id)")
                        .padding(10)
                }
                .background(
                    RoundedRectangle(cornerSize: CGSize(width: 16, height: 16))
                        .fill(Color.gray.opacity(0.2))
                )
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color.gray.opacity(0.2))
        }
    }
}

#Preview {
    ContentView()
}
