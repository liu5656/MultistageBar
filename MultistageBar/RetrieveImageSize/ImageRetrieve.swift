//
//  ImageRetrieve.swift
//  MultistageBar
//
//  Created by x on 2020/10/13.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

/*
 参考:
 https://gist.github.com/shpakovski/1744633
 https://medium.com/ios-os-x-development/prefetching-images-size-without-downloading-them-entirely-in-swift-5c2f8a6f82e9
 */

class ImageRetrieve: NSObject {
    static func size(url: URL) -> CGSize? {
        // with CGImageSource we avoid loading the whole image into memory
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }
        
        let propertiesOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, propertiesOptions) as? [CFString: Any] else {
            return nil
        }
        
        if let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
           let height = properties[kCGImagePropertyPixelHeight] as? CGFloat {
            return CGSize(width: width, height: height)
        } else {
            return nil
        }
    }
}
