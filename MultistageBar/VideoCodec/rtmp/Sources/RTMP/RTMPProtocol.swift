//
//  RTMPProtocol.swift
//  swift-rtmp
//
//  Created by kPherox on 2019/02/24.
//  Copyright © 2019 kPherox. All rights reserved.
//

import Foundation
import CRTMP

public enum RTMPProtocol {

    case undefined
    case rtmp
    case rtmpe
    case rtmpt
    case rtmps
    case rtmpte
    case rtmpts
    case rtmfp

    var cValue: Int32 {
        switch self {
            case .undefined:    return RTMP_PROTOCOL_UNDEFINED  // -1
            case .rtmp:         return RTMP_PROTOCOL_RTMP       // 0
            case .rtmpe:        return RTMP_PROTOCOL_RTMPE      // RTMP_FEATURE_ENC     = 0x02
            case .rtmpt:        return RTMP_PROTOCOL_RTMPT      // RTMP_FEATURE_HTTP    = 0x01
            case .rtmps:        return RTMP_PROTOCOL_RTMPS      // RTMP_FEATURE_SSL     = 0x04
            case .rtmpte:       return RTMP_PROTOCOL_RTMPTE     // (RTMP_FEATURE_HTTP|RTMP_FEATURE_ENC)
            case .rtmpts:       return RTMP_PROTOCOL_RTMPTS     // (RTMP_FEATURE_HTTP|RTMP_FEATURE_SSL)
            case .rtmfp:        return RTMP_PROTOCOL_RTMFP      // RTMP_FEATURE_MFP     = 0x08 /* not yet supported */
        }
    }

    init?(cValue: Int32) {
        switch cValue {
            case RTMP_PROTOCOL_UNDEFINED:   self = .undefined
            case RTMP_PROTOCOL_RTMP:        self = .rtmp
            case RTMP_PROTOCOL_RTMPE:       self = .rtmpe
            case RTMP_PROTOCOL_RTMPT:       self = .rtmpt
            case RTMP_PROTOCOL_RTMPS:       self = .rtmps
            case RTMP_PROTOCOL_RTMPTE:      self = .rtmpte
            case RTMP_PROTOCOL_RTMPTS:      self = .rtmpts
            case RTMP_PROTOCOL_RTMFP:       self = .rtmfp
            default: fatalError("Invalid RTMP_PROTOCOL value: \(cValue)")
        }
    }
}
