//
//  CaptureViewController.swift
//  MultistageBar
//
//  Created by x on 2020/9/25.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit
import AVFoundation

class CaptureViewController: UIViewController {
    
    enum CameraPosition {
        case front
        case back
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        prepareTakePhoto()
        _ = captureB
        _ = cameraPositionB
        _ = cancelB
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func prepareTakePhoto() {
        addImageInput(position: defaultPosition)
        addImageOutput()
        addPreviewLayer()
        runing()
    }
    
    // image
    func addImageInput(position: CameraPosition) {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        if let temp = imageInput {
            session.removeInput(temp)
            let subtype = position == .front ? CATransitionSubtype.fromLeft : CATransitionSubtype.fromRight
            preview?.add(flipAnimation(subType: subtype), forKey: "flip")
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
    func addImageOutput() {
        imageOutput = AVCapturePhotoOutput.init()
        guard let imageOutput = imageOutput,
            session.canAddOutput(imageOutput) else {
            return
        }
        session.addOutput(imageOutput)
    }
    func addPreviewLayer() {
        preview = AVCaptureVideoPreviewLayer.init(session: session)
        preview?.frame = view.bounds
        view.layer.addSublayer(preview!)
    }
    func takePhoto() {
        let config: AVCapturePhotoSettings
        if #available(iOS 11.0, *) {
            config = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        }else{
            config = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecJPEG])
        }
        imageOutput?.capturePhoto(with: config, delegate: self)
    }
    
    // common
    func flipAnimation(subType: CATransitionSubtype) -> CATransition {
        let temp = CATransition.init()
        temp.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
        temp.duration = 0.5
        temp.type = CATransitionType.init(rawValue: "oglFlip")
        temp.subtype = subType
        return temp
    }
    @objc func switchCamera(sender: UIButton) {
        if defaultPosition == .front {
            defaultPosition = .back
        }else{
            defaultPosition = .front
        }
        addImageInput(position: defaultPosition)
    }
    func camera(position: CameraPosition = .back) -> AVCaptureDevice? {
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
    func finish(obj: Any?) {
        completion?(obj)
        self.back()
    }
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    var defaultPosition = CameraPosition.front
    var imageInput: AVCaptureInput?
    var imageOutput: AVCapturePhotoOutput?
    var preview: AVCaptureVideoPreviewLayer?
    var completion: ((Any?) -> Void)?
    lazy var session: AVCaptureSession = {
        let temp = AVCaptureSession.init()
        temp.sessionPreset = AVCaptureSession.Preset.inputPriority
        return temp
    }()
    
    lazy var cancelB: UIButton = {
        let but = UIButton.init(type: .custom)
        but.frame = CGRect.init(x: 10, y: 20 + Screen.fakeSafeTop, width: 30, height: 30)
        but.setTitleColor(UIColor.black, for: .normal)
        but.setTitle("取消", for: .normal)
        view.addSubview(but)
        but.addTarget(self, action: #selector(back), for: .touchUpInside)
        return but
    }()
    lazy var captureB: UIButton = {
        let but = UIButton.init(type: .custom)
        but.backgroundColor = UIColor.white
        but.frame = CGRect.init(x: (UIScreen.main.bounds.width - 80) * 0.5, y: UIScreen.main.bounds.height - 160, width: 80, height: 80)
        but.layer.borderColor = UIColor.lightGray.cgColor
        but.layer.borderWidth = 2
        but.layer.cornerRadius = 40
        but.layer.masksToBounds = true
        but.addTarget(self, action: #selector(captureDown), for: .touchDown)
        but.addTarget(self, action: #selector(captureUpInside), for: .touchUpInside)
        view.addSubview(but)
        return but
    }()
    lazy var cameraPositionB: UIButton = {
        let but = UIButton.init(type: .custom)
        but.backgroundColor = UIColor.white
        but.frame = CGRect.init(x: UIScreen.main.bounds.width - 60, y: captureB.frame.midY - 20, width: 40, height: 40)
        but.layer.borderColor = UIColor.lightGray.cgColor
        but.layer.borderWidth = 2
        but.layer.cornerRadius = 8
        but.layer.masksToBounds = true
        but.addTarget(self, action: #selector(switchCamera(sender:)), for: .touchUpInside)
        view.addSubview(but)
        return but
    }()
    @objc func captureDown() {
        UIView.animate(withDuration: 0.2, animations: {[unowned self] in
            self.captureB.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        }) {[unowned self] (finish) in
            self.takePhoto()
        }
    }
    @objc func captureUpInside() {
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.captureB.transform = CGAffineTransform.identity
        }
    }
}

extension CaptureViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        self.stop()
        guard let data = photo.fileDataRepresentation(),
            let img = UIImage.init(data: data) else {
            return
        }
        self.finish(obj: img.fixOrientation())
    }
    
    @available(iOS 10.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?){
        self.stop()
        guard let buffer = photoSampleBuffer,
            let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:buffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer),
            let img = UIImage.init(data: data) else {
            return
        }
        self.finish(obj: img.fixOrientation())
    }
    
}


