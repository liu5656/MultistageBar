//
//  SavePhoto.swift
//  MultistageBar
//
//  Created by x on 2021/3/15.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit
import Photos

class SavePhoto {
    typealias callback = (Bool, Error?) -> Void
    public static func save(imgs: [UIImage], callback: @escaping callback) {
        let type = PHPhotoLibrary.authorizationStatus()
        switch type {
        case .notDetermined:
            if #available(iOS 14.0, *) {
                PHPhotoLibrary.requestAuthorization(for: PHAccessLevel.readWrite) { (status) in
                    SavePhoto.save(imgs: imgs, callback: callback)
                }
            }else{
                PHPhotoLibrary.requestAuthorization { (status) in
                    SavePhoto.save(imgs: imgs, callback: callback)
                }
            }
        case .authorized, .limited:
            beginAction(imgs: imgs, callback: callback)
        default:
            callback(false, nil)
            break
        }
    }
    private static func beginAction(imgs: [UIImage], callback: @escaping callback) {
        retrieveAlbum { (changer) in
            save(imgs: imgs, toAlbum: changer, callback: callback)
        }
    }
    private static func wrapImgs(_ imgs: [UIImage]) -> [PHObjectPlaceholder] {
        var ids: [PHObjectPlaceholder] = []
        imgs.forEach({ (image) in
            if let asset = PHAssetChangeRequest.creationRequestForAsset(from: image).placeholderForCreatedAsset {
                ids.append(asset)
            }
        })
        return ids
    }
    private static func retrieveAlbum(callback: @escaping (PHAssetCollectionChangeRequest?) -> Void) {
        let albumName = "目天"
        let albums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: .albumRegular, options: nil)
        var changer: PHAssetCollectionChangeRequest?
        for index in 0..<albums.count {
            let collection = albums[index]
            if collection.localizedTitle == albumName {
                PHPhotoLibrary.shared().performChanges({
                    changer = PHAssetCollectionChangeRequest.init(for: collection)
                }) { (result, err) in
                    callback(changer)
                }
                return
            }
        }
        PHPhotoLibrary.shared().performChanges {
            changer = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
        } completionHandler: { (res, err) in
            callback(changer)
        }
    }
    private static func save(imgs: [UIImage], toAlbum changer: PHAssetCollectionChangeRequest?, callback: @escaping callback) {
        guard let changer = changer else {
            callback(false, nil)
            return
        }
        PHPhotoLibrary.shared().performChanges({
            MBLog(changer.title)
            let ids = wrapImgs(imgs)
            changer.addAssets(ids as NSArray)
        }, completionHandler: callback)
    }
}

