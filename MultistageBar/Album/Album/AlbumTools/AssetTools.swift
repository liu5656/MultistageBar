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
    static func image(asset: AssetModel?,
                      size: CGSize,
                      mode: PHImageContentMode = .default,
                      callback: @escaping (UIImage?, Bool, NSError?) -> Void) {
        if let temp = asset?.localIdentifier,
           let asset = PHAsset.fetchAssets(withLocalIdentifiers: [temp], options: nil).firstObject {
            
            let option = PHImageRequestOptions.init()
            option.isNetworkAccessAllowed = true
            PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: mode, options: option) { (img, info) in
                if let value = info?[PHImageErrorKey] as? NSError {
                    callback(nil, false, value)
                    // 81 超时
                    // 82 飞行模式
                    // 1005 存储空间不足
                }else if let value = info?[PHImageCancelledKey] as? Bool, value == true {
                    callback(nil, false, NSError.init())
//                    MBLog("操作已取消!")
                }else if let value = info?[PHImageResultIsDegradedKey] as? Bool, value == true {
                    callback(img, false, nil)
//                    MBLog("获取到缩略图!")
                }else if let temp = img {
                    callback(temp, true, nil)
//                    MBLog("获取到原图!")
                }else{
                    callback(nil, false, NSError.init())
//                    MBLog("操作错误")
                }
            }
            
            
        }
    }
}
