//
//  Hash.swift
//  MultistageBar
//
//  Created by x on 2020/10/27.
//  Copyright © 2020 x. All rights reserved.
//

import Foundation
import CommonCrypto

class Hash {
    typealias shaFunc = (_ data: UnsafeRawPointer?, _ len: CC_LONG, _ md: UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<UInt8>?
    enum Style {
        case sha1
        case sha256
        case sha512
        var digestLength: UInt32 {
            switch self {
            case .sha1:
                return UInt32(CC_SHA1_DIGEST_LENGTH)
            case .sha256:
                return UInt32(CC_SHA256_DIGEST_LENGTH)
            case .sha512:
                return UInt32(CC_SHA512_DIGEST_LENGTH)
            }
        }
        var SHA: shaFunc {
            switch self {
            case .sha1:
                return CC_SHA1
            case .sha256:
                return CC_SHA256
            case .sha512:
                return CC_SHA512
            }
        }
        var HMACAlgorithm: CCHmacAlgorithm {
            let result: Int
            switch self {
            case .sha1:
                result = kCCHmacAlgSHA1
            case .sha256:
                result = kCCHmacAlgSHA256
            case .sha512:
                result = kCCHmacAlgSHA512
            }
            return CCHmacAlgorithm.init(result)
        }
    }
    static func sha(str: String, type: Hash.Style) -> String? {
        guard let temp = str.data(using: .utf8, allowLossyConversion: true) else {return nil}
        return sha(data: temp, type: type)
    }
    static func sha(data: Data, type: Hash.Style) -> String? {
        let desLength = Int(type.digestLength)
        let resultPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: desLength)
        defer {
            resultPointer.deallocate()
        }
        _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            type.SHA(bytes.baseAddress, CC_LONG(data.count), resultPointer)
        }
        var result: String = ""
        for i in 0..<desLength {
            let temp = String.init(format: "%02x", resultPointer[i])
            result += temp
        }
        return result
    }
    static func hmacSha(str: String, key: String, type: Hash.Style) -> String? {
        let desLength = Int(type.digestLength)
        let resultPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: desLength)
        defer {
            resultPointer.deallocate()
        }
        let keyPointer = key.cString(using: String.Encoding.utf8)!
        let keyLength = key.lengthOfBytes(using: String.Encoding.utf8)
                
        let strPointer = str.cString(using: .utf8)!
        let strLength = str.lengthOfBytes(using: .utf8)
        
        CCHmac(type.HMACAlgorithm, keyPointer, keyLength, strPointer, strLength, resultPointer)
        var result: String = ""
        for i in 0..<desLength {
            let temp = String.init(format: "%02x", resultPointer[i])
            result += temp
        }
        return result
    }
    
}
