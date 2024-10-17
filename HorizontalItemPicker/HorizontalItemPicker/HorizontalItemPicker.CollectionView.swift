import UIKit
import SwiftUI

extension HorizontalItemPicker {
    
    final class CollectionView<CollectionItem: Identifiable, CollectionContent: View>: UICollectionView, UICollectionViewDataSource {
        
        let flowLayout = CarouselFlowLayout()
        
        private let items: [CollectionItem]
        private let defaultPosition: Int
        private var content: ((CollectionItem) -> CollectionContent)
        private var setDefaultPosition = false
        
        private let cellReuseIdentifier = "CollectionViewCell"
        
        init(
            items: [CollectionItem],
            defaultPosition: Int,
            itemSize: CGSize,
            spacingMode: CarouselFlowLayoutSpacingMode,
            sideItemScale: CGFloat,
            sideItemAlpha: CGFloat,
            sideItemShift: CGFloat,
            @ViewBuilder content: @escaping (CollectionItem) -> CollectionContent
        ) {
            self.items = items
            self.defaultPosition = defaultPosition
            self.content = content
            
            flowLayout.scrollDirection = .horizontal
            flowLayout.itemSize = itemSize
            flowLayout.spacingMode = spacingMode
            flowLayout.sideItemScale = sideItemScale
            flowLayout.sideItemAlpha = sideItemAlpha
            flowLayout.sideItemShift = sideItemShift
            
            super.init(frame: .zero, collectionViewLayout: flowLayout)
            
            backgroundColor = .clear
            showsHorizontalScrollIndicator = false
            dataSource = self
            register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        }
        
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            if !setDefaultPosition {
                setDefaultPosition = true
                scrollToItem(
                    at: .init(row: defaultPosition, section: 0),
                    at: .centeredHorizontally,
                    animated: false
                )
            }
        }
        
        // MARK: - UICollectionViewDataSource
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            items.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
            guard let viewModel = item(at: indexPath.item) else {
                return .init()
            }
            cell.contentConfiguration = UIHostingConfiguration {
                content(viewModel)
            }
            return cell
        }
        
        func item(at index: Int) -> CollectionItem? {
            guard items.indices.contains(index) else { return nil }
            return items[index]
        }
        
    }
    
}
