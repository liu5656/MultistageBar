//
//  AssetTools.swift
//  Voice
//
//  Created by lj on 2019/4/11.
//  Copyright © 2019 huofeng. All rights reserved.
//

import UIKit
import Photos

class AssetTools {
    static func getImageData(asset: AssetModel?, quality: CGFloat = 0, callback: @escaping (Data?) -> Void) {
        if let temp = asset?.localIdentifier, let asset = PHAsset.fetchAssets(withLocalIdentifiers: [temp], options: nil).firstObject {
            PHCachingImageManager.default().requestImageData(for: asset, options: nil, resultHandler: { (data, dataUTI, orientation, info) in
                guard let temp = data else {callback(nil); return}
                if quality > 0 {
                    callback(UIImage.init(data: temp)?.jpegData(compressionQuality: quality))
                }else{
                    callback(data)
                }
            })
        }
    }
}
