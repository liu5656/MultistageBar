//
//  L1Player.swift
//  MultistageBar
//
//  Created by x on 2021/3/11.
//  Copyright © 2021 x. All rights reserved.
//

import Foundation
import AVFoundation

enum PlayerChangeKey: String {
    case playbackLikelyToKeepUp         // 有足够的缓存用来播放
    case loadedTimeRanges               // 缓存进度
    case playbackBufferEmpty            // 缓存不足
    case status                         // 播放器状态改变
    case rate                           //
}

enum ManualHandle {
    case play
    case pause
}

class L1Player: NSObject {
    public func l1_seek(time: CMTime) {
        player.seek(to: time)
    }
    public func l1_play() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
        } catch let excp {
            MBLog("配置session失败-- \(excp)")
        }
        player.play()
        manual = .play
    }
    public func l1_pause() {
        player.pause()
        manual = .pause
    }
    public func l1_stop() {
        l1_pause()
        l1_removeObserver()
    }
    private func l1_playback(time: CMTime) {
        playTime = CMTimeGetSeconds(time)
        playback?(cacheTime, playTime, duration)
    }
    @objc private func l1_interrupt(noti: Notification) {
        guard let value = noti.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType.init(rawValue: value) else {return}
        switch type {
        case .began:
            player.pause()
        case .ended:
            player.play()
        @unknown default:
            break
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let key = keyPath, let type = PlayerChangeKey.init(rawValue: key) else {
            return
        }
        switch type {
        case .playbackLikelyToKeepUp:
            if manual == .play {
                player.play()
            }
            MBLog("缓存充足,继续播放......")
        case .loadedTimeRanges:
            guard let time = video.loadedTimeRanges.first?.timeRangeValue else {
                return
            }
            let start = CMTimeGetSeconds(time.start)
            let duration = CMTimeGetSeconds(time.duration)
            cacheTime = start + duration
//            MBLog("缓存进度: \(start) + \(duration)")
        case .playbackBufferEmpty:
            if manual != .pause {
                player.pause()
            }
            MBLog("缓存不够,暂停播放......")
        case .status:
            MBLog("播放器状态切换: \(video.status)")
            break
        case .rate:
            MBLog("播放器播放速率: \(change?[NSKeyValueChangeKey.newKey])")
            break
        }
    }

    private func l1_addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(l1_interrupt(noti:)), name: AVAudioSession.interruptionNotification, object: nil)
        player.addObserver(self, forKeyPath: PlayerChangeKey.rate.rawValue, options: .new, context: nil)
        video.addObserver(self, forKeyPath: PlayerChangeKey.playbackLikelyToKeepUp.rawValue, options: .new, context: nil)
        video.addObserver(self, forKeyPath: PlayerChangeKey.loadedTimeRanges.rawValue, options: .new, context: nil)
        video.addObserver(self, forKeyPath: PlayerChangeKey.playbackBufferEmpty.rawValue, options: .new, context: nil)
        video.addObserver(self, forKeyPath: PlayerChangeKey.status.rawValue, options: .new, context: nil)
    }
    private func l1_removeObserver() {
        NotificationCenter.default.removeObserver(self)
        player.removeObserver(self, forKeyPath: PlayerChangeKey.rate.rawValue)
        video.removeObserver(self, forKeyPath: PlayerChangeKey.playbackLikelyToKeepUp.rawValue)
        video.removeObserver(self, forKeyPath: PlayerChangeKey.playbackBufferEmpty.rawValue)
        video.removeObserver(self, forKeyPath: PlayerChangeKey.loadedTimeRanges.rawValue)
        video.removeObserver(self, forKeyPath: PlayerChangeKey.status.rawValue)
    }
    
    init(url: URL) {
        self.url = url
        super.init()
        l1_addObserver()
        DispatchQueue.global().async { [unowned self] in
            duration = CMTimeGetSeconds(video.asset.duration)
            MBLog("获的总的时间: \(duration)")
        }
    }
    deinit {
        l1_removeObserver()
        MBLog("")
    }
    
    private var url: URL
    private(set) var playTime: Double = 0
    private(set) var cacheTime: Double = 0
    private(set) var duration: Double = 0
    private(set) var manual: ManualHandle = .play
    var playback: ((Double, Double, Double) -> Void)?
    private(set) lazy var player: AVPlayer = {
        let temp = AVPlayer.init(playerItem: video)
        temp.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: DispatchQueue.main, using: l1_playback(time:))
        return temp
    }()
    private lazy var video: AVPlayerItem = {
        let item = AVPlayerItem.init(url: url)
        return item
    }()
}
