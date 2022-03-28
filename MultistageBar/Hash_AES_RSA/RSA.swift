//
//  RSA.swift
//  MultistageBar
//
//  Created by x on 2020/10/30.
//  Copyright © 2020 x. All rights reserved.
//

import Foundation
import CommonCrypto

/*
 RSA原理
 1.随机不等质数p和q
 2.n = p * q
 3.Φ(n)欧拉函数
 4.随机整数e，1<e<Φ(n)，e与Φ(n)互质
 5.e对于Φ(n)的模反元素d
 6.公钥(n,e)，私钥(n,d)      // 实际过程中公钥和私钥数据都是采用ASN.1格式表达的
 */

// 单片加解密,明文需要小于秘钥长度,
class RSA {
    static func secKey(key: String, isPublic: Bool) -> SecKey? {
        let tempKey = String(key.filter { !" \n\t\r".contains($0) })
        let components = tempKey.components(separatedBy: "-----")
        guard components.count == 5, let keyData = Data.init(base64Encoded: components[2]) else {
            return nil
        }
        let keyLength = keyData.count * 8
        let attributes: [CFString: Any] = [kSecAttrKeyType: kSecAttrKeyTypeRSA,
                          kSecAttrKeyClass: isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate,
                          kSecAttrKeySizeInBits: keyLength]
        return SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, nil)
    }
    
    static func encrypt(plaintext: String, key: SecKey) -> String? {
        guard let data = plaintext.data(using: .utf8) else {
            return nil
        }
        let blockSize = SecKeyGetBlockSize(key) - 11
        let dataLength = data.count
        var resultData: Data = Data.init()
        var index = 0
        while index < dataLength {
            let tempData = data[index..<min(index + blockSize, dataLength)]
            guard let result = SecKeyCreateEncryptedData(key, .rsaEncryptionPKCS1, tempData as CFData, nil) else {
                return nil
            }
            resultData.append(result as Data)
            index += blockSize
        }
        return resultData.base64EncodedString()
    }
    static func decrypt(encoded text: String, key: SecKey) -> String? {
        guard let data = Data.init(base64Encoded: text) else {
            return nil
        }
        let blockSize = SecKeyGetBlockSize(key)
        let dataLength = data.count
        var resultData: Data = Data.init()
        var index = 0
        while index < dataLength {
            let tempData = data[index..<min((index + blockSize), dataLength)]
            guard let result = SecKeyCreateDecryptedData(key, .rsaEncryptionPKCS1, tempData as CFData, nil) else {
                return nil
            }
            resultData.append(result as Data)
            index += blockSize
        }
        return String.init(data: (resultData as Data), encoding: .utf8)
    }
    static func sign(text: String, key: SecKey) -> String? {
        guard let data = text.data(using: .utf8) else {
            return nil
        }
        guard let result = SecKeyCreateSignature(key, .rsaSignatureMessagePKCS1v15SHA512, data as CFData, nil) else {
            return nil
        }
        return (result as Data).base64EncodedString()
    }
    static func verify(signature: String, originalStr: String, key: SecKey) -> Bool {
        guard let signedData = Data.init(base64Encoded: signature) else {
            return false
        }
        guard let originalData = originalStr.data(using: .utf8) else {
            return false
        }
        return SecKeyVerifySignature(key, .rsaSignatureMessagePKCS1v15SHA512, originalData as CFData, signedData as CFData, nil)
    }
}
