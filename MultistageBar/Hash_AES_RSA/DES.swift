//
//  DES.swift
//  MultistageBar
//
//  Created by x on 2020/10/28.
//  Copyright © 2020 x. All rights reserved.
//

import Foundation
import CommonCrypto
/*
 DES是对称性加密里面常见一种，全称为Data Encryption Standard，即数据加密标准，是一种使用密钥加密的块算法。
 密钥长度是64位(8字节)，超过位数密钥被忽略。
 所谓对称性加密，加密和解密密钥相同。
 对称性加密一般会按照固定长度，把待加密字符串分成块。不足一整块或者刚好最后有特殊填充字符。
 往往跨语言做DES加密解密出问题。
    往往是填充方式('pkcs5','pkcs7','iso10126','ansix923','zero')不对、
    或者编码不一致(utf8,gb2312...)、
    或者选择加密解密模式(ECB,CBC,CTR,OFB,CFB,NCFB,NOFB)没有对应上造成。
 */

class DES {
    static func des(operation: CCOperation = CCOperation(kCCEncrypt), str: String, key: String) -> String? {
        guard let keyPointer = key.cString(using: .utf8) else {return nil}
        
        let dataIn: Data
        if operation == CCOperation(kCCEncrypt), let temp = str.data(using: .utf8) {
            dataIn = temp
        }else if operation == CCOperation(kCCDecrypt), let temp = Data.init(base64Encoded: str, options: .ignoreUnknownCharacters) {
            dataIn = temp
        }else{
            return nil
        }
        let dataInLength = dataIn.count
        
        let dataOutAvailable = dataInLength + kCCBlockSizeDES
        let dataOut = UnsafeMutablePointer<UInt8>.allocate(capacity: dataOutAvailable)
        
        let dataOutMoved = UnsafeMutablePointer<Int>.allocate(capacity: 1)  // 编解码操作后返回的数据长度指针
        dataOutMoved.initialize(to: 0)
        
        defer {
            dataOut.deallocate()
            dataOutMoved.deallocate()
        }
        
        let result = CCCrypt(operation,
                             CCAlgorithm(kCCAlgorithmDES),
                             CCOptions(kCCOptionECBMode | kCCOptionPKCS7Padding),   //  加密模式(默认CBC) | 补码方式,
                             keyPointer,
                             kCCKeySizeDES,                                             // 秘钥长度
                             nil,                                                   //  不传默认16位0,ECB模式不用添加秘钥偏移向量
                             [UInt8](dataIn),
                             dataInLength,
                             dataOut,
                             dataOutAvailable,
                             dataOutMoved)
        if result == CCCryptorStatus(kCCSuccess) {
            let data = Data.init(bytesNoCopy: dataOut, count: dataOutMoved.pointee, deallocator: .none)
            if operation == CCOperation(kCCEncrypt) {
                return data.base64EncodedString(options: .lineLength64Characters)
            }else{
                return String.init(data: data, encoding: .utf8)
            }
        }else{
            print("DES \(operation) failed: \(result)")
            return nil
        }
    }
}
