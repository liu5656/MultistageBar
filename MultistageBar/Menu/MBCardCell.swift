//
//  MBCardCell.swift
//  MultistageBar
//
//  Created by x on 2021/4/27.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBCardCell: UICollectionViewCell {
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = UIColor.lightGray
    }
    
    lazy var title: UILabel = {
        
        let lab = UILabel.init(frame: bounds)
        lab.textColor = UIColor.red
        lab.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lab.textAlignment = .center
        contentView.addSubview(lab)
        
        return lab
    }()
}
