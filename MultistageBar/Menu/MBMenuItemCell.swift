//
//  MBMenuItemCell.swift
//  MultistageBar
//
//  Created by x on 2021/2/23.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBMenuItemCell: UICollectionViewCell {
    lazy var titleL: UILabel = {
        let lab = UILabel.init(frame: bounds)
        lab.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        lab.textAlignment = .center
        contentView.addSubview(lab)
        return lab
    }()
}
