//
//  TextGrid.swift
//  AxxessAssignment
//
//  Created by Sushant Alone on 02/08/20.
//  Copyright © 2020 Sushant Alone. All rights reserved.
//

import UIKit

class TextGrid: UICollectionViewCell {

    var lblText: UILabel = UILabel(frame: CGRect.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        contentView.addSubview(lblText)
        lblText.numberOfLines = 5
        lblText.textAlignment = .center
        lblText.contentMode = .scaleAspectFill
        lblText.clipsToBounds = true
        lblText.textColor = .white
        lblText.snp.makeConstraints { (make) in
            make.leading.top.equalTo(10)
            make.trailing.bottom.equalTo(-10)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension TextGrid : CellConfigurable {
    func setup(viewModel: RowViewModel) {
        
        guard let viewModel = (viewModel as? ItemDataModel) else {return}
        lblText.text = viewModel.data
    }
    
    func setupUI() {
        self.contentView.makeViewCornerRadiusWithRadi(radius: 5)
        self.contentView.dropShadow()
        if Helper.isDeviceIPad() {
            lblText.font = UIFont.systemFont(ofSize: 25)
        }
    }
}
