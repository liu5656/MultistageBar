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
    let index: Int
    var localIdentifier: String = ""
    init(asset: PHAsset, index: Int) {
        self.asset = asset
        self.index = index
    }
    required init() {
        fatalError("init() has not been implemented")
    }
}
