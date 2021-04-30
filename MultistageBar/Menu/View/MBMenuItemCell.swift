//
//  MBMenuItemCell.swift
//  MultistageBar
//
//  Created by x on 2021/2/23.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBMenuItemCell: UICollectionViewCell, CellContentProtocol {
    
    weak var processor: ProcessorProtocol?
    func config(model: Any) {
        if let temp = model as? MBLinkage {
            titleL.text = temp.title
        }else if let temp = model as? MBSubLinkage {
            titleL.text = temp.title
        }else{
            titleL.text = nil
        }
    }
    
    lazy var titleL: UILabel = {
        let lab = UILabel.init(frame: bounds)
        lab.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        lab.textAlignment = .center
        contentView.addSubview(lab)
        return lab
    }()
    override func select(_ sender: Any?) {
        MBLog(sender)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = bgV
        _ = selBGV
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bgV: UIView = {
        let temp = UIView.init(frame: bounds)
        temp.backgroundColor = UIColor.green
        backgroundView = temp
        return temp
    }()
    lazy var selBGV: UIView = {
        let temp = UIView.init(frame: bounds)
        temp.backgroundColor = UIColor.red
        selectedBackgroundView = temp
        return temp
    }()
    
    
}
