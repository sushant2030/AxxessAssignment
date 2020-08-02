//
//  ImageGrid.swift
//  AxxessAssignment
//
//  Created by Sushant Alone on 02/08/20.
//  Copyright © 2020 Sushant Alone. All rights reserved.
//

import UIKit
import Kingfisher

class ImageGrid: UICollectionViewCell,RowViewModel {

    var gridImageView: UIImageView = UIImageView(frame: CGRect.zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        contentView.addSubview(gridImageView)
        
        gridImageView.clipsToBounds = true
        gridImageView.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.top.equalToSuperview()
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ImageGrid : CellConfigurable {
    func setup(viewModel: RowViewModel) {
        
        guard let viewModel = (viewModel as? ItemDataModel) else {return}
        
        let cache = ImageCache.default
        if cache.isCached(forKey: viewModel.data!){
            viewModel.cachedImage { (image) in
                self.gridImageView.image = image
                if (image?.size.width)! < self.contentView.frame.width{
                    self.gridImageView.contentMode = .center
                }else{
                    self.gridImageView.contentMode = .scaleAspectFill
                }
            }
        }else{
            self.gridImageView.image = defaultImage
            self.gridImageView.contentMode = .scaleAspectFill
        }
    }
    
    func setupUI() {
        self.contentView.makeViewCornerRadiusWithRadi(radius: 5)
        self.contentView.dropShadow()
    }
    
}
