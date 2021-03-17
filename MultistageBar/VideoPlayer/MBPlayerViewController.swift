//
//  MBPlayerViewController.swift
//  MultistageBar
//
//  Created by x on 2021/3/11.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class MBPlayerViewController: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL.init(string: "http://static.yunzhanxinxi.com/video_shop_0611.mp4")!
        player = L1Player.init(url: url)
        player.l1_play()

        preview.video = player
    
        // 进入后台控制播放
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    // 进入后台控制播放
    @objc func enterBackground() {
        updateLockScreenInfo()
        remoteControl()
        preview.l1_clear()
    }
    @objc func enterForeground() {
        preview.video = player
    }
    func updateLockScreenInfo() {
        var playingInfo: [String: Any] = [:]
        playingInfo[MPMediaItemPropertyTitle] = "歌曲1.2"
        playingInfo[MPMediaItemPropertyAlbumTitle] = "专辑:飞牛"
        playingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork.init(boundsSize: CGSize.init(width: 200, height: 200), requestHandler: { (size) -> UIImage in
            return UIImage.init(named: "1")!
        })
        playingInfo[MPMediaItemPropertyPlaybackDuration] = 60
        playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 15
        playingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
        MPNowPlayingInfoCenter.default().nowPlayingInfo = playingInfo
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    @objc func remotePause() -> MPRemoteCommandHandlerStatus {
        player.l1_pause()
        MBLog("")
        return MPRemoteCommandHandlerStatus.success
    }
    @objc func remotePlay() -> MPRemoteCommandHandlerStatus {
        player.l1_play()
        MBLog("")
        return MPRemoteCommandHandlerStatus.success
    }
    @objc func remoteNext() -> MPRemoteCommandHandlerStatus {
        MBLog("")
        return MPRemoteCommandHandlerStatus.success
    }
    @objc func remotePrevious() -> MPRemoteCommandHandlerStatus {
        MBLog("")
        return MPRemoteCommandHandlerStatus.success
    }
    @objc func remoteSeek(time: CMTime) -> MPRemoteCommandHandlerStatus {
        MBLog(time)
        return MPRemoteCommandHandlerStatus.success
    }
    func remoteControl() {
        let center = MPRemoteCommandCenter.shared()
        
        let pause = center.pauseCommand
        pause.isEnabled = true
        pause.addTarget(self, action: #selector(remotePause))
        
        let play = center.playCommand
        play.isEnabled = true
        play.addTarget(self, action: #selector(remotePlay))
        
        let next = center.nextTrackCommand
        next.isEnabled = true
        next.addTarget(self, action: #selector(remoteNext))
        
        let previous = center.previousTrackCommand
        previous.isEnabled = true
        previous.addTarget(self, action: #selector(remotePrevious))
        
        let position = center.changePlaybackPositionCommand
        position.isEnabled = true
        position.addTarget(self, action: #selector(remoteSeek(time:)))
    }
    
    deinit {
        preview.l1_stop()
    }
    
    var player: L1Player!
    
    lazy var preview: L1PlayerPreview = {
        let temp = L1PlayerPreview.init(frame: CGRect.init(x: 0, y: 100, width: Screen.width, height: 260))
//        let temp = L1PlayerPreview.init()
        temp.backgroundColor = UIColor.black
        view.addSubview(temp)
        return temp
    }()
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
//    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if UIApplication.shared.statusBarOrientation.isLandscape {
            let app = UIApplication.shared.delegate as? AppDelegate
            app?.blockRotation = .portrait
        }
    }
    
}
