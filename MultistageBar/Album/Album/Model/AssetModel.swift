//
//  AssetModel.swift
//  Voice
//
//  Created by lj on 2019/3/15.
//  Copyright © 2019 huofeng. All rights reserved.
//

import Foundation
import Photos

class AssetModel {
    var isSelected: Bool = false
    var asset: PHAsset
    var localIdentifier: String = ""
    init(asset: PHAsset) {
        self.asset = asset
    }
    required init() {
        fatalError("init() has not been implemented")
    }
}
