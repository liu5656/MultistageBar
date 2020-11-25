//
//  AlbumImageCell.swift
//  WeexDemo
//
//  Created by lj on 2019/3/1.
//  Copyright © 2019 taobao. All rights reserved.
//

import UIKit
import Photos

protocol AlbumImageCellDelegate: class {
    func selectedAsset(model: AssetModel)
}

class AlbumImageCell: UICollectionViewCell {

    var model: AssetModel?
    weak var delegate: AlbumImageCellDelegate?
    let thumbnailSize = CGSize.init(width: 200, height: 200)

    override var isSelected: Bool {
        didSet{
            if isSelected {
                selectedB.isSelected = true
            }else{
                selectedB.isSelected = false
            }
        }
    }
    
    private lazy var imageIV: UIImageView = {
        let img = UIImageView.init(frame: bounds)
        img.contentMode = UIView.ContentMode.scaleAspectFill
        img.clipsToBounds = true
        contentView.addSubview(img)
        return img
    }()
    private lazy var selectedB: UIButton = {
        let but = UIButton.init(type: .custom)
        but.frame = CGRect.init(x: bounds.width - 30, y: 0, width: 30, height: 30)
        but.setImage(UIImage.init(named: "checkbox_circle"), for: .normal)
        but.setImage(UIImage.init(named: "checkbox_right"), for: .selected)
        but.isUserInteractionEnabled = false
        contentView.addSubview(but)
        return but
    }()
    private lazy var timeL: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 10, y: bounds.height - 20, width: bounds.width - 15, height: 16))
        lab.textColor = UIColor.white
        lab.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lab.textAlignment = .right
        contentView.addSubview(lab)
        return lab
    }()
}

extension AlbumImageCell {
    func lobo_config(model: AssetModel?, manager: PHImageManager) {
        self.model = model
        guard let photo = model else {return}
        if photo.localIdentifier == "1" {
            imageIV.image = UIImage.init(named: "")
            selectedB.isHidden = true
        }else{
            imageIV.image = nil
            selectedB.isHidden = false
            let asset = photo.asset
            selectedB.isSelected = photo.isSelected
            manager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { (image, _) in
                if photo.localIdentifier == asset.localIdentifier {
                    self.imageIV.image = image
                }
            }
            if asset.mediaType == .video, photo.localIdentifier != "1" {
                timeL.isHidden = false
                timeL.text = timeString(asset.duration)
            }else{
                timeL.isHidden = true
                timeL.text = nil
            }
        }
    }
    func timeString(_ num: TimeInterval)->String{
        if num.isNaN{
            return "00:00"
        }
        var Min = Int(num / 60)
        let Sec = Int(num.truncatingRemainder(dividingBy: 60))
        var Hour = 0
        if Min>=60 {
            Hour = Int(Min / 60)
            Min = Min - Hour*60
            return String(format: "%02d:%02d:%02d", Hour, Min, Sec)
        }
        return String(format: "%02d:%02d", Min, Sec)
    }
}
