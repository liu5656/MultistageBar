//
//  RoundedUtil.swift
//  MultistageBar
//
//  Created by x on 2020/10/9.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

extension UIImage {
    // radius 单位像素
    func corner(radius r: Int) -> UIImage {
        let w = Int(size.width)
        let h = Int(size.height)
        let size = w * h
        
        guard let data = cgImage?.dataProvider?.data else {
            return self
        }
        let pointer: UnsafePointer<UInt8>? = CFDataGetBytePtr(data)
        let temp2 = UnsafeRawPointer.init(pointer)?.bindMemory(to: Int32.self, capacity: size)
        guard let buffer = UnsafeMutablePointer<Int32>.init(mutating: temp2) else {
            return self
        }
        trimCorner(radius: r, width: w, height: h, buffer: buffer)
        
        let releaseData: CGDataProviderReleaseDataCallback = { info, data, length in }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo = [CGBitmapInfo.init(rawValue: CGImageAlphaInfo.last.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)]
        guard let provider = CGDataProvider.init(dataInfo: nil,
                                           data: buffer,
                                           size: size * 4,
                                           releaseData: releaseData) else {
            return self
        }

        guard let tempCGImage = CGImage.init(width: w,
                                             height: h,
                                             bitsPerComponent: 8,
                                             bitsPerPixel: 32,
                                             bytesPerRow: w * 4,
                                             space: colorSpace,
                                             bitmapInfo: bitmapInfo,
                                             provider: provider,
                                             decode: nil,
                                             shouldInterpolate: true,
                                             intent: .defaultIntent) else {
            return self
        }
        let img = UIImage.init(cgImage: tempCGImage)
        return img
    }
    private func trimCorner(radius r: Int, width w: Int, height h: Int, buffer: UnsafeMutablePointer<Int32>) {
        // 左上
        for y in 0..<r {
            for x in 0..<(r - y) {
                if circle(centerX: r, centerY: r, radius: r, pointX: x, pointY: y) == false {
                    buffer.advanced(by: y * w + x).pointee = 0
                }
            }
        }
        // 左下
        for y in (h-r)..<h {
            for x in 0..<r {
                if circle(centerX: r, centerY: h - r, radius: r, pointX: x, pointY: y) == false {
                    buffer.advanced(by: y * w + x).pointee = 0
                }
            }
        }
        // 右上
        for y in 0..<r {
            for x in (w-r)..<w {
                if circle(centerX: w - r, centerY: r, radius: r, pointX: x, pointY: y) == false {
                    buffer.advanced(by: y * w + x).pointee = 0
                }
            }
        }
        // 右下
        for y in (h-r)..<h {
            for x in (w - r)..<w {
                if circle(centerX: w - r, centerY: h - r, radius: r, pointX: x, pointY: y) == false {
                    buffer.advanced(by: y * w + x).pointee = 0
                }
            }
        }
    }
    
    private func circle(centerX cx: Int, centerY cy: Int, radius r: Int, pointX px: Int, pointY py: Int ) -> Bool {
        return (cx - px) * (cx - px) + (cy - py) * (cy - py) <= (r * r)  // 勾股定理
    }
}


