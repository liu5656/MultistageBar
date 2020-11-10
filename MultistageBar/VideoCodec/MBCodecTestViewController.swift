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
        preview.frame = view.bounds
        view.layer.addSublayer(preview)
        capture.runing()
    }
        
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        capture.stop()
        encoder.stop()
    }
    
    lazy var encoder: MBEncoder = {
        let temp = MBEncoder.init()
        temp.prepareCompress()
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

}

extension MBCodecTestViewController: MBCaptureDelegate {
    func mb_capture(sampleBuffer: CMSampleBuffer) {
        encoder.compress(sampleBuffer: sampleBuffer)
    }
}

extension MBCodecTestViewController: MBEncoderDelegate {
    func encoded(nalu: Data) {
        file?.write(nalu)
    }
    func encoded(sps: Data, pps: Data) {
        var temp = sps
        temp.append(pps)
        file?.write(temp)
    }
}
