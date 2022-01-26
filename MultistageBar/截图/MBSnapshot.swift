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
    func capture(targetSize: CGSize) -> UIImage?
}

extension UIView: SnapshotDelegate {
    @objc public func capture(targetSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(targetSize, true, UIScreen.main.scale)
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
    public override func capture(targetSize: CGSize) -> UIImage? {
         
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
