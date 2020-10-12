//
//  AuthorizationTools.swift
//  MultistageBar
//
//  Created by x on 2020/9/28.
//  Copyright © 2020 x. All rights reserved.
//

import Foundation
import Photos
import MapKit


enum AuthorizationType: Int {
    case notDetermined
    case authorized
    case denied
}

class AuthorizationTools {
    static func requestAlbumAuthorize() {
        PHPhotoLibrary.requestAuthorization { (result) in
            
        }
    }
    static func albumAuthorize() -> AuthorizationType {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            return AuthorizationType.notDetermined
        case .authorized:
            return AuthorizationType.authorized
        default:
            return AuthorizationType.denied
        }
    }
    static func requestMicrophoneAuthorize() {
        AVCaptureDevice.requestAccess(for: AVMediaType.audio) { (result) in
            
        }
    }
    static func microphoneAuthorize() -> AuthorizationType {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        switch status {
        case .notDetermined:
            return AuthorizationType.notDetermined
        case .authorized:
            return AuthorizationType.authorized
        default:
            return AuthorizationType.denied
        }
    }
    
    static func requestCameraAuthorize() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (result) in
            
        }
    }
    static func cameraAuthorize() -> AuthorizationType {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .notDetermined:
            return AuthorizationType.notDetermined
        case .authorized:
            return AuthorizationType.authorized
        default:
            return AuthorizationType.denied
        }
    }

}
