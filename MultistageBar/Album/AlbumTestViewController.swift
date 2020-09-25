//
//  AlbumTestViewController.swift
//  MultistageBar
//
//  Created by x on 2020/9/25.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class AlbumTestViewController: UIViewController {

    @objc func albumAction() {
        let vc = AlbumViewController.init()
        vc.finishCallback = { asset in
            
        }
        let nav = UINavigationController.init(rootViewController: vc)
        nav.navigationBar.isTranslucent = false
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    @objc func takeAPhoto() {
        let vc = CaptureViewController.init()
        vc.completion = { result in
            if let temp = result as? UIImage {
                excuteInMainThread { [weak self] in
                    self?.previewIV.image = temp
                }
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.init()
        view.backgroundColor = UIColor.white
        _ = albumB
        _ = takePhotoB
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    lazy var albumB: UIButton = {
        let but = UIButton.init(type: .custom)
        but.frame = CGRect.init(x: 10, y: 30, width: 200, height: 50)
        but.setTitleColor(UIColor.black, for: .normal)
        but.setTitle("select form album", for: .normal)
        view.addSubview(but)
        but.addTarget(self, action: #selector(albumAction), for: .touchUpInside)
        return but
    }()
    
    lazy var takePhotoB: UIButton = {
        let but = UIButton.init(type: .custom)
        but.frame = CGRect.init(x: 10, y: 100, width: 200, height: 50)
        but.setTitleColor(UIColor.black, for: .normal)
        but.setTitle("take a photo", for: .normal)
        view.addSubview(but)
        but.addTarget(self, action: #selector(takeAPhoto), for: .touchUpInside)
        return but
    }()
    lazy var previewIV: UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: 10, y: 210, width: 200, height: 200))
        img.contentMode = .scaleAspectFill
        view.addSubview(img)
        return img
    }()

}
