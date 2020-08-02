//
//  CustomLayout.swift
//  AxxessAssignment
//
//  Created by Sushant Alone on 02/08/20.
//  Copyright © 2020 Sushant Alone. All rights reserved.
//

import UIKit

protocol CustomLayoutDelegate: AnyObject {
  func collectionView(_ collectionView: UICollectionView,
    heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class CustomLayout: UICollectionViewLayout {
    
    weak var delegate: CustomLayoutDelegate?

    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 6

    private var cache0: [UICollectionViewLayoutAttributes] = []
    private var cache1: [UICollectionViewLayoutAttributes] = []

    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
      guard let collectionView = collectionView else {
        return 0
      }
      let insets = collectionView.contentInset
      return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
        
      return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
      guard
        cache0.isEmpty,
        cache1.isEmpty,
        let collectionView = collectionView
        else {
          return
      }

      let columnWidth = contentWidth / CGFloat(numberOfColumns)
      var xOffset: [CGFloat] = []
      for column in 0..<numberOfColumns {
        xOffset.append(CGFloat(column) * columnWidth)
      }
      var column = 0
      var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
            for item in 0..<collectionView.numberOfItems(inSection: 0) {
              let indexPath = IndexPath(item: item, section: 0)
                
              let photoHeight = delegate?.collectionView(
                collectionView,
                heightForPhotoAtIndexPath: indexPath) ?? 180
              let height = cellPadding * 2 + photoHeight
              let frame = CGRect(x: xOffset[column],
                                 y: yOffset[column],
                                 width: columnWidth,
                                 height: height)
//                print("frame : \(frame)")
              let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                
              let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
              attributes.frame = insetFrame
              cache0.append(attributes)

              contentHeight = max(contentHeight, frame.maxY)
              yOffset[column] = yOffset[column] + height
//              print("column y offset : \(yOffset[column]), column : \(column)")
                column = column < (numberOfColumns - 1) ? (column + 1) : 0
                
            }
        
        for item in 0..<collectionView.numberOfItems(inSection: 1) {
            let indexPath = IndexPath(item: item, section: 1)
            
            let photoHeight = delegate?.collectionView(
                collectionView,
                heightForPhotoAtIndexPath: indexPath) ?? 180
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: 0,
                               y: yOffset[column],
                               width: collectionView.frame.width,
                               height: height)
            //                print("frame : \(frame)")
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache1.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            //              print("column y offset : \(yOffset[column]), column : \(column)")
            
            
        }
            
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {
            var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
            
            // Loop through the cache and look for items in the rect
            for attributes in cache0 {
                if attributes.frame.intersects(rect) {
                    visibleLayoutAttributes.append(attributes)
                }
            }
            
            for attributes in cache1 {
                if attributes.frame.intersects(rect) {
                    visibleLayoutAttributes.append(attributes)
                }
            }
            return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath)
        -> UICollectionViewLayoutAttributes? {
            return indexPath.section == 0 ? cache0[indexPath.item] : cache1[indexPath.item]
    }
}
