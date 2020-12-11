//
//  IDFAViewController.swift
//  MultistageBar
//
//  Created by x on 2020/12/11.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit
import AdSupport
import AppTrackingTransparency

class IDFAViewController: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 14.0, *) {
            ss_retrieveIDFAAfter14()
        }else{
            ss_retrieveIDFABefore14()
        }
    }
    
    
    // iOS 14以前的获取idfa方法
    func ss_retrieveIDFABefore14() {
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            MBLog("idfa：\(idfa)")
        }else{
            MBLog("用户限制了广告追踪")
        }
    }
    // iOS 14以后获取idfa的方法
    @available (iOS 14.0, *)
    func ss_retrieveIDFAAfter14() {
        // 1、info.plist添加NSUserTrackingUsageDescription权限申请描述
        // 2、权限判断
        let status: ATTrackingManager.AuthorizationStatus  = ATTrackingManager.trackingAuthorizationStatus
        switch status {
        case .authorized:
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            MBLog("idfa：\(idfa)")
        case .denied:
            MBLog("拒绝授权")
        case .notDetermined:
            ss_requestTrackAuthorization()
        case .restricted:
            MBLog("限制授权")
        @unknown default:
            fatalError("系统增加了新的授权状态选项")
        }
    }
    @available (iOS 14, *)
    func ss_requestTrackAuthorization() {
        MBLog("用户未授权,请求授权")
        ATTrackingManager.requestTrackingAuthorization { (status) in
            MBLog("用户授权结果: \(status)")
        }
    }
}
