import UIKit
import SwiftUI
import Combine

struct HorizontalItemPicker<Item: Identifiable, Content: View>: UIViewRepresentable {
    
    @Binding var selectedIndex: Int
    private let collectionView: CollectionView<Item, Content>
    private var content: ((Item) -> Content)
    private var preselected: Bool
    
    init(
        selectedIndex: Binding<Int>,
        items: [Item],
        itemSize: CGSize,
        spacingMode: CarouselFlowLayoutSpacingMode = .fixed(spacing: 10),
        sideItemScale: CGFloat = 1,
        sideItemAlpha: CGFloat = 0.5,
        sideItemShift: CGFloat = 0,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        _selectedIndex = selectedIndex
        self.preselected = selectedIndex.wrappedValue > 0
        self.collectionView = CollectionView(
            items: items,
            defaultPosition: selectedIndex.wrappedValue,
            itemSize: itemSize,
            spacingMode: spacingMode,
            sideItemScale: sideItemScale,
            sideItemAlpha: sideItemAlpha,
            sideItemShift: sideItemShift,
            content: content
        )
        self.content = content
    }
    
    func makeUIView(context: Context) -> CollectionView<Item, Content> {
        collectionView.delegate = context.coordinator
        collectionView.flowLayout.delegate = context.coordinator
        return collectionView
    }
    
    func updateUIView(_ collectionView: CollectionView<Item, Content>, context: Context) {
        guard context.coordinator.lastUpdatedIndexPath?.item != selectedIndex else { return }
        collectionView.scrollToItem(
            at: .init(row: selectedIndex, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICollectionViewDelegate, CarouselFlowLayoutDelegate {
        
        private(set) var lastUpdatedIndexPath: IndexPath? {
            didSet {
                if let index = lastUpdatedIndexPath?.item {
                    if parent.preselected {
                        parent.preselected = false
                    } else {
                        parent.selectedIndex = index
                    }
                }
            }
        }
        
        var parent: HorizontalItemPicker
        
        init(_ parent: HorizontalItemPicker) {
            self.parent = parent
            super.init()
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
        func carouselFlowLayout(_ carouselFlowLayout: CarouselFlowLayout, collectionView: UICollectionView, currentIndexPath indexPath: IndexPath) {
            lastUpdatedIndexPath = indexPath
        }
        
    }
    
}
