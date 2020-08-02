//
//  CellConfigurable.swift
//  Jaarx
//
//  Created by Sushant Alone on 03/07/20.
//  Copyright © 2020 Sushant Alone. All rights reserved.
//

import Foundation
protocol CellConfigurable {
    func setup(viewModel: RowViewModel) // Provide a generic function for table row set up
    func setupUI()
}
protocol RowViewModel {
    
}

