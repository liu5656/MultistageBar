//
//  MBFeedback.swift
//  MultistageBar
//
//  Created by x on 2022/1/18.
//  Copyright © 2022 x. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 13.0, *)
open class MBFeedback {
    
    public enum ImpactStyle: Int {
        typealias OriginalType = UIImpactFeedbackGenerator.FeedbackStyle
        case light, medium, heavy, soft, rigid
        var change: OriginalType {
            OriginalType.init(rawValue: self.rawValue) ?? .light
        }
    }
    public static func impact(style: ImpactStyle = .light) {
        let feedback = UIImpactFeedbackGenerator.init(style: style.change)
        feedback.prepare()
        feedback.impactOccurred()
    }
    
    public static func selection() {
        let selection = UISelectionFeedbackGenerator.init()
        selection.selectionChanged()
        selection.prepare()
    }

    public enum NotificationStyle: Int {
        typealias OriginalType = UINotificationFeedbackGenerator.FeedbackType
        case success, warning, error
        var change: OriginalType {
            OriginalType.init(rawValue: self.rawValue) ?? .success
        }
    }
    
    public static func notification(style: NotificationStyle = .success) {
        let notification = UINotificationFeedbackGenerator.init()
        notification.prepare()
        notification.notificationOccurred(style.change)
    }
}

