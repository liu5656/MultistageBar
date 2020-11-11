//
//  MBCodecTestViewController.swift
//  MultistageBar
//
//  Created by x on 2020/11/9.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit
import VideoToolbox

class MBCodecTestViewController: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let preview = capture.addPreviewLayer()
        preview.frame = CGRect.init(x: 4, y: 80, width: 200, height: 300)
        view.layer.addSublayer(preview)
        capture.runing()
        _ = player
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        capture.stop()
        encoder.stop()
        decoder.stop()
    }
    
    lazy var encoder: MBEncoder = {
        let temp = MBEncoder.init()
        temp.prepareCompress()
        temp.delegate = self
        return temp
    }()
    lazy var decoder: MBDecoder = {
        let temp = MBDecoder.init()
        temp.delegate = self
        return temp
    }()
    lazy var capture: MBCapture = {
        let temp = MBCapture.init()
        temp.delegate = self
        temp.prepareCapture()
        return temp
    }()
    lazy var file: FileHandle? = {
        let path = NSHomeDirectory() + "/Documents/demo.h264"
        let url = URL.init(fileURLWithPath: path)
        if FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(at: url)
        }
        FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        return try? FileHandle.init(forWritingTo: url)
    }()
    lazy var player: AAPLEAGLLayer = {
        let temp = AAPLEAGLLayer.init(frame: CGRect.init(x: 210, y: 80, width: 200, height: 300))!
        view.layer.addSublayer(temp)
        return temp
    }()
}

extension MBCodecTestViewController: MBCaptureDelegate {
    func mb_capture(sampleBuffer: CMSampleBuffer) {
        encoder.compress(sampleBuffer: sampleBuffer)
    }
}

extension MBCodecTestViewController: MBEncoderDelegate {
    func encoded(nalu: Data) {  // 编码回调,返回普通nalu/sps/pps
        // 方法一, 保存h264文件
        file?.write(nalu)
        // 方法二, 实时解码
        decoder.decode(nalu: nalu)
    }
}

extension MBCodecTestViewController: MBDecoderDelegate {
    func decoded(sampleBuffer: CVImageBuffer) {
        self.player.pixelBuffer = sampleBuffer
    }
}
