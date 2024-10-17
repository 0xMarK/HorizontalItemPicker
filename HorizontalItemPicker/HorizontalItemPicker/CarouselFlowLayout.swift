import UIKit
import SwiftUI

protocol CarouselFlowLayoutDelegate: AnyObject {
    func carouselFlowLayout(_ carouselFlowLayout: CarouselFlowLayout, collectionView: UICollectionView, currentIndexPath indexPath: IndexPath)
}

enum CarouselFlowLayoutSpacingMode {
    case fixed(spacing: CGFloat)
    case overlap(visibleOffset: CGFloat)
}

class CarouselFlowLayout: UICollectionViewFlowLayout {
    
    weak var delegate: CarouselFlowLayoutDelegate?
    
    fileprivate struct LayoutState {
        
        var size: CGSize
        var direction: UICollectionView.ScrollDirection
        
        func isEqual(_ otherState: LayoutState) -> Bool {
            size.equalTo(otherState.size) && direction == otherState.direction
        }
    }
    
    var sideItemScale: CGFloat = 1
    var sideItemAlpha: CGFloat = 0.5
    var sideItemShift: CGFloat = 0
    
    var spacingMode = CarouselFlowLayoutSpacingMode.fixed(spacing: 10)
    
    private var currentIndex: Int?
    
    private var state = LayoutState(size: CGSize.zero, direction: .horizontal)
    
    override func prepare() {
        super.prepare()
        guard let collectionView else { return }
        
        let currentState = LayoutState(
            size: collectionView.bounds.size,
            direction: scrollDirection
        )
        
        if !state.isEqual(currentState) {
            setupCollectionView()
            updateLayout()
            state = currentState
        }
    }
    
    fileprivate func setupCollectionView() {
        guard let collectionView else { return }
        if collectionView.decelerationRate != UIScrollView.DecelerationRate.fast {
            collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        }
    }
    
    fileprivate func updateLayout() {
        guard let collectionView else { return }
        
        let collectionSize = collectionView.bounds.size
        let isHorizontal = scrollDirection == .horizontal
        
        let yInset = (collectionSize.height - itemSize.height) / 2
        let xInset = (collectionSize.width - itemSize.width) / 2
        self.sectionInset = UIEdgeInsets.init(top: yInset, left: xInset, bottom: yInset, right: xInset)
        
        let side = isHorizontal ? itemSize.width : itemSize.height
        let scaledItemOffset =  (side - side * sideItemScale) / 2
        
        switch spacingMode {
        case .fixed(let spacing):
            minimumLineSpacing = spacing - scaledItemOffset
        case .overlap(let visibleOffset):
            let fullSizeSideItemOverlap = visibleOffset + scaledItemOffset
            let inset = isHorizontal ? xInset : yInset
            minimumLineSpacing = inset - fullSizeSideItemOverlap
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect),
              let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
        else { return nil }
        return attributes.map({ self.transformLayoutAttributes($0) })
    }
    
    fileprivate func transformLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView else { return attributes }
        
        let isHorizontal = scrollDirection == .horizontal
        
        let collectionCenter = (isHorizontal ? collectionView.frame.size.width : collectionView.frame.size.height) / 2
        let offset = isHorizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y
        let normalizedCenter = (isHorizontal ? attributes.center.x : attributes.center.y) - offset
        
        let maxDistance = (isHorizontal ? itemSize.width : itemSize.height) + minimumLineSpacing
        let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
        let ratio = (maxDistance - distance) / maxDistance
        
        let alpha = ratio * (1 - sideItemAlpha) + sideItemAlpha
        let scale = ratio * (1 - sideItemScale) + sideItemScale
        let shift = (1 - ratio) * sideItemShift
        
        attributes.alpha = alpha
        attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        attributes.zIndex = Int(alpha * 10)
        
        if isHorizontal {
            attributes.center.y += shift
        } else {
            attributes.center.x += shift
        }
        
        if roundRatio(ratio) == 1, currentIndex != attributes.indexPath.row {
            delegate?.carouselFlowLayout(self, collectionView: collectionView, currentIndexPath: attributes.indexPath)
            currentIndex = attributes.indexPath.row
        }
        
        return attributes
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView, !collectionView.isPagingEnabled,
              let layoutAttributes = layoutAttributesForElements(in: collectionView.bounds) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        
        let isHorizontal = scrollDirection == .horizontal
        let midSide = (isHorizontal ? collectionView.bounds.size.width : collectionView.bounds.size.height) / 2
        let proposedContentOffsetCenterOrigin = (isHorizontal ? proposedContentOffset.x : proposedContentOffset.y) + midSide
        
        var targetContentOffset: CGPoint
        
        if isHorizontal {
            let closest = layoutAttributes.sorted { abs($0.center.x - proposedContentOffsetCenterOrigin) < abs($1.center.x - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
            targetContentOffset = CGPoint(x: floor(closest.center.x - midSide), y: proposedContentOffset.y)
        } else {
            let closest = layoutAttributes.sorted { abs($0.center.y - proposedContentOffsetCenterOrigin) < abs($1.center.y - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
            targetContentOffset = CGPoint(x: proposedContentOffset.x, y: floor(closest.center.y - midSide))
        }
        
        return targetContentOffset
    }
    
    private func roundRatio(_ ratio: Double) -> Int {
        ratio < 0.5 ? 0 : 1
    }
    
}
