//
//  MBPlayerViewController.swift
//  MultistageBar
//
//  Created by x on 2021/3/11.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit
import AVFoundation

class MBPlayerViewController: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL.init(string: "http://static.yunzhanxinxi.com/video_shop_0611.mp4")!
        player = L1Player.init(url: url)
        player.l1_play()

        preview.video = player
//        preview.video = nil
    }
    deinit {
//        player.player.pause()
        preview.l1_stop()
        MBLog("player view controller deinit")
    }
    
    var player: L1Player!
    
    lazy var preview: L1PlayerPreview = {
        let temp = L1PlayerPreview.init(frame: CGRect.init(x: 0, y: 100, width: Screen.width, height: 260))
        temp.backgroundColor = UIColor.black
        view.addSubview(temp)
        return temp
    }()
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if UIApplication.shared.statusBarOrientation.isLandscape {
            let app = UIApplication.shared.delegate as? AppDelegate
            app?.blockRotation = .portrait
        }
    }
    
}
