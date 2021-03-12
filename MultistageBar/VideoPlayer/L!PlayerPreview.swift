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
    
    public func l1_stop() {
        video?.l1_stop()
        video = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        preview.frame = bounds
        _ = tap
        progress.ss_setup(progress: 0, background: 0)
        _ = indicator
    }
    deinit {
        MBLog("")
    }
    var video: L1Player? {
        didSet{
            preview.player = video?.player
            video?.playback = l1_playback(cache:time:duration:)
            video?.statusBlock = l1_statusChange(status:)
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
        timeL.text = "\(time.time())|\(duration.time())"
//        MBLog("\(time) - duration: \(duration)")
    }
    private func l1_statusChange(status: PlayerStatus) {
        switch status {
        case .readToPlay:
            break
        case .playing:
            indicator.stopAnimating()
            indicator.isHidden = true
        case .cacheing:
            indicator.startAnimating()
            indicator.isHidden = false
        case .pausing:
            break
        case .error:
            break
        }
    }
    @objc private func l1_fullScreen(sender: UIButton) {
        let app = UIApplication.shared.delegate as? AppDelegate
        var tempFrame: CGRect
        if Util.interfaceOrientation() == .portrait {
            originalFrame = frame
            tempFrame = CGRect.init(x: 0, y: 0, width: Screen.height, height: Screen.width)
            app?.blockRotation = .landscapeRight
        }else{
            app?.blockRotation = .portrait
            tempFrame = originalFrame
        }
        UIView.animate(withDuration: 0.3) { [unowned self] in
            frame = tempFrame
            timeL.frame = CGRect.init(x: 8, y: tempFrame.size.height - 24, width: 80, height: 16)
            fullB.frame = CGRect.init(x: tempFrame.size.width - 38, y: timeL.frame.midY - 15, width: 30, height: 30)
            progress.frame = CGRect.init(x: timeL.frame.maxX + 10, y: timeL.frame.midY - 2, width: fullB.frame.minX - timeL.frame.maxX - 16, height: 4)
            indicator.center = CGPoint.init(x: tempFrame.width * 0.5, y: tempFrame.height * 0.5)
        }
    }
    
    @objc private func l1_tap() {
        if video?.manual == .play {
            video?.l1_pause()
        }else if video?.manual == .pause {
            video?.l1_play()
        }
    }
    
    private var originalFrame: CGRect = .zero
    private var duration: CGFloat = 0
    private lazy var indicator: UIActivityIndicatorView = {
        let acView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        acView.center = CGPoint.init(x: bounds.width * 0.5, y: bounds.height * 0.5)
        if #available(iOS 13.0, *) {
            acView.style = .large
        } else {
            acView.style = .gray
        }
        acView.startAnimating()
        addSubview(acView)
        return acView
    }()
    private lazy var tap: UITapGestureRecognizer = {
        let temp = UITapGestureRecognizer.init(target: self, action: #selector(l1_tap))
        addGestureRecognizer(temp)
        return temp
    }()
    private lazy var preview: AVPlayerLayer = {
        let temp = AVPlayerLayer.init(player: video?.player)
        temp.frame = bounds
        layer.addSublayer(temp)
        return temp
    }()
    private lazy var timeL: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 8, y: bounds.height - 24, width: 80, height: 16))
        lab.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        lab.layer.cornerRadius = 8
        lab.layer.masksToBounds = true
        lab.textColor = UIColor.gray
        lab.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lab.textAlignment = .center
        addSubview(lab)
        return lab
    }()
    private lazy var fullB: UIButton = {
        let but = UIButton.init(type: .custom)
        but.frame = CGRect.init(x: bounds.width - 38, y: timeL.frame.midY - 15, width: 30, height: 30)
        but.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        but.setTitle("全屏", for: .normal)
        but.addTarget(self, action: #selector(l1_fullScreen(sender:)), for: .touchUpInside)
        addSubview(but)
        return but
    }()
    private lazy var progress: SliderProgress = {
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: 0, y: 2))
        path.addLine(to: CGPoint.init(x: fullB.frame.minX - timeL.frame.maxX - 16, y: 2))
        let temp = SliderProgress.init(frame: CGRect.init(x: timeL.frame.maxX + 10, y: timeL.frame.midY - 2, width: fullB.frame.minX - timeL.frame.maxX - 16, height: 4), path: path, lineWidth: 4)
        
        temp.backgroundColor = UIColor.green
        temp.backColor = UIColor.red
        temp.strokeColor = UIColor.blue
        temp.layer.cornerRadius = 2
        
//        temp.sliderCallback = l1_slider(ratio:)       // 写法会造成循环引用
        temp.sliderCallback = { [weak self] ratio in
            self?.l1_slider(ratio: ratio)
        }
        
        addSubview(temp)
        return temp
    }()
}
