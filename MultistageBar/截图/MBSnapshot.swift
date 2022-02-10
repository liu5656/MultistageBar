//
//  MBSnapshot.swift
//  MultistageBar
//
//  Created by x on 2022/1/26.
//  Copyright © 2022 x. All rights reserved.
//

import Foundation


// 截图
public protocol SnapshotDelegate {
    // 截取整个视图
    func capture() -> UIImage?
    // 截取可视视图的部分
    func capture(rect: CGRect) -> UIImage?
}

extension UIView: SnapshotDelegate {
    @objc public func capture(rect: CGRect) -> UIImage? {
        let scale = UIScreen.main.scale
        
        UIGraphicsBeginImageContextWithOptions(frame.size, true, scale)
        
        self.drawHierarchy(in: bounds, afterScreenUpdates: true)
//        self.snapshotView(afterScreenUpdates: true)
//        guard let context = UIGraphicsGetCurrentContext() else {
//            return nil
//        }
//        self.layer.render(in: context)
        
        let fullImg = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        guard rect != bounds else { return fullImg }
        
        let scope = rect.applying(CGAffineTransform.init(scaleX: scale, y: scale))
        
        guard let cropData = fullImg?.cgImage?.cropping(to: scope) else { return nil }
        
        let result = UIImage.init(cgImage: cropData, scale: scale, orientation: UIImage.Orientation.up)
        
        return result
    }
    
    @objc public func capture() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        layer.render(in: context)
        let img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        return img
    }
}

// 截取UIScrollView系列的长图
extension UIScrollView {
    public override func capture() -> UIImage? {
         
        let savedContentOffset = contentOffset
        
        let imageCount = Int(ceil(contentSize.height / frame.height))
        
        UIGraphicsBeginImageContextWithOptions(contentSize, true, UIScreen.main.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        self.contentOffset = .zero
        
        (0..<imageCount).forEach { [unowned self] index in
            contentOffset = CGPoint.init(x: 0, y: CGFloat(index) * frame.height)
            layer.render(in: context)
        }

                
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        self.contentOffset = savedContentOffset
        
        return img
    }
}
