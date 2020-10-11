//
//  MBCornerImageViewController.swift
//  MultistageBar
//
//  Created by x on 2020/10/10.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class MBCornerImageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        _ = originalIV
        print(UIImage.init(named: "lena")?.corner(radius: 50).size)
    }
    
    lazy var originalIV: UIImageView = {
        let iv = UIImageView.init(frame: CGRect.init(x: 50, y: 100, width: 200, height: 200))
        iv.image = UIImage.init(named: "lena")
        view.addSubview(iv)
        return iv
    }()
    lazy var cornerIV: UIImageView = {
        let iv = UIImageView.init(frame: CGRect.init(x: 50, y: 350, width: 200, height: 200))
        view.addSubview(iv)
        return iv
    }()
    
}