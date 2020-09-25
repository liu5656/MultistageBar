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
    @IBOutlet weak var leftTopIV: UIImageView!
    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var timeL: UILabel!
    @IBOutlet weak var selectedB: UIButton!
    var model: AssetModel?
    weak var delegate: AlbumImageCellDelegate?
    let thumbnailSize = CGSize.init(width: 200, height: 200)
    @IBAction func selectedAction(_ sender: UIButton) {
        if let model = model {
            delegate?.selectedAsset(model: model)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension AlbumImageCell {
    func lobo_config(model: AssetModel?, manager: PHImageManager) {
        self.model = model
        guard let photo = model else {return}
        if photo.localIdentifier == "1" {
            imageIV.image = UIImage.init(named: "")
            selectedB.isHidden = true
        }else{
            selectedB.isHidden = false
            let asset = photo.asset
            selectedB.isSelected = photo.isSelected
            imageIV.image = nil
            manager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { (image, _) in
                if photo.localIdentifier == asset.localIdentifier {
                    self.imageIV.image = image
                }
            }
            timeL.text = nil
            if asset.mediaType == .video, photo.localIdentifier != "1" {
                timeL.isHidden = false
                timeL.text = timeString(asset.duration)
            }else{
                timeL.isHidden = true
            }
        }
    }
    func lobo_canDelete() {
        selectedB.setImage(UIImage.init(named: "icon_close"), for: .selected)
        imageIV.layer.cornerRadius = 5
        imageIV.layer.masksToBounds = true
        if self.model?.asset.mediaType == .video {
            leftTopIV.isHidden = false
        }else{
            leftTopIV.isHidden = true
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
