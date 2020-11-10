//
//  MBCapture.swift
//  MultistageBar
//
//  Created by x on 2020/11/9.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit
import AVFoundation

protocol MBCaptureDelegate: NSObjectProtocol {
    func mb_capture(sampleBuffer: CMSampleBuffer)
}

class MBCapture: NSObject {
    enum CameraPosition {
        case front
        case back
    }
    
    func prepareCapture() {
        addImageInput(position: defaultPosition)
        addVideoMetaDataOutput()
    }
    
    private func addImageInput(position: CameraPosition) {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        if let temp = imageInput {
            session.removeInput(temp)
        }
        guard let device = camera(position: position) else {
            return
        }
        guard let input = try? AVCaptureDeviceInput.init(device: device) else {
            return
        }
        guard session.canAddInput(input) else {
            return
        }
        
        session.addInput(input)
        imageInput = input
    }
    private func addVideoMetaDataOutput() {
        videoMetaDataOutput = AVCaptureVideoDataOutput.init()
        guard let imageOutput = videoMetaDataOutput,
            session.canAddOutput(imageOutput) else {
            return
        }
        session.addOutput(imageOutput)
        let connection = imageOutput.connection(with: .video)
        connection?.videoOrientation = .portrait
        imageOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())
    }
    func addPreviewLayer() -> AVCaptureVideoPreviewLayer {
        let preview = AVCaptureVideoPreviewLayer.init(session: session)
        return preview
    }
    private func takePhoto() {
        
    }
    private func camera(position: CameraPosition = .back) -> AVCaptureDevice? {
        let type = position == .front ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
        let discover = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: type)
        for device in discover.devices {
            if device.position == type {
                return device
            }
        }
        return nil
    }
    func runing() {
        session.startRunning()
    }
    func stop() {
        session.stopRunning()
    }
    
    var defaultPosition = CameraPosition.back
    var delegate: MBCaptureDelegate?
    private var imageInput: AVCaptureInput?
    private var videoMetaDataOutput: AVCaptureVideoDataOutput?
    private var audioMetaDataOutput: AVCaptureAudioDataOutput?
    private lazy var session: AVCaptureSession = {
        let temp = AVCaptureSession.init()
        temp.sessionPreset = AVCaptureSession.Preset.inputPriority
        return temp
    }()
}

extension MBCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.mb_capture(sampleBuffer: sampleBuffer)
    }
}
