//
//  L!PlayerPreview.swift
//  MultistageBar
//
//  Created by x on 2021/3/11.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit
import AVFoundation

class L1PlayerPreview: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        preview.frame = bounds
        _ = tap
        progress.ss_setup(progress: 0, background: 0)
    }
    
    var video: L1Player? {
        didSet{
            preview.player = video?.player
            video?.playback = l1_playback(cache:time:duration:)
        }
    }
    
    private func l1_slider(ratio: CGFloat) {
        guard let temp = video else {
            return
        }
        let time = CMTime.init(value: CMTimeValue.init(temp.duration * Double(ratio)), timescale: 1)
        video?.l1_seek(time: time)
        MBLog(ratio)
    }
    private func l1_playback(cache: Double, time: Double, duration: Double) {
        let playRatio = time / duration
        let cacheRatio = cache / duration
        progress.ss_setup(progress: CGFloat(playRatio), background: CGFloat(cacheRatio))
        MBLog("\(time) - duration: \(duration)")
    }
    
    
    @objc func l1_tap() {
        if video?.manual == .play {
            video?.l1_pause()
        }else if video?.manual == .pause {
            video?.l1_play()
        }
    }
    
    var duration: CGFloat = 0
    lazy var tap: UITapGestureRecognizer = {
        let temp = UITapGestureRecognizer.init(target: self, action: #selector(l1_tap))
        addGestureRecognizer(temp)
        return temp
    }()
    lazy var preview: AVPlayerLayer = {
        let temp = AVPlayerLayer.init(player: video?.player)
        temp.frame = bounds
        layer.addSublayer(temp)
        return temp
    }()
    lazy var progress: SliderProgress = {
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: 0, y: 4))
        path.addLine(to: CGPoint.init(x: bounds.width - 20, y: 4))
        let temp = SliderProgress.init(frame: CGRect.init(x: 10, y: bounds.height - 10, width: bounds.width - 20, height: 8), path: path, lineWidth: 8)
        
        temp.backgroundColor = UIColor.green
        temp.backColor = UIColor.red
        temp.strokeColor = UIColor.blue
        
        temp.sliderCallback = l1_slider(ratio:)
        addSubview(temp)
        return temp
    }()
}
