# HorizontalItemPicker

A convenient horizontal item picker with fast deceleration rate.

Usage example:

```swift
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
```
