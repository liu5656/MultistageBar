//
//  AES.swift
//  MultistageBar
//
//  Created by x on 2020/10/28.
//  Copyright © 2020 x. All rights reserved.
//

import Foundation
import CommonCrypto
/*
 http://tool.chacuo.net/cryptaes
 https://www.qtool.net/aes      // 测试地址
 AES,高级加密标准（英语：Advanced Encryption Standard，缩写：AES），在密码学中又称Rijndael加密法，是美国联邦政府采用的一种区块加密标准。
 这个标准用来替代原先的DES，已经被多方分析且广为全世界所使用。
 严格地说，AES和Rijndael加密法并不完全一样（虽然在实际应用中二者可以互换），因为Rijndael加密法可以支持更大范围的区块和密钥长度：AES的区块长度固定为128比特，密钥长度则可以是128，192或256比特；而Rijndael使用的密钥和区块长度可以是32位的整数倍，以128位为下限，256比特为上限。包括AES-ECB,AES-CBC,AES-CTR,AES-OFB,AES-CFB
 
 ECB（Electronic Code Book）：电子密码本模式。每一块数据，独立加密。
 最基本的加密模式，也就是通常理解的加密，相同的明文将永远加密成相同的密文，无初始向量，容易受到密码本重放攻击，一般情况下很少用。
 
 CBC（Cipher Block Chaining）：密码分组链接模式。使用一个密钥和一个初始化向量[IV]对数据执行加密。
 明文被加密前要与前面的密文进行异或运算后再加密，因此只要选择不同的初始向量，相同的密文加密后会形成不同的密文，这是目前应用最广泛的模式。CBC加密后的密文是上下文相关的，但明文的错误不会传递到后续分组，但如果一个分组丢失，后面的分组将全部作废(同步错误)。
 CBC可以有效的保证密文的完整性，如果一个数据块在传递是丢失或改变，后面的数据将无法正常解密。
 */
class AES {
    static func aes(operation: CCOperation = CCOperation(kCCEncrypt), str: String, key: String) -> String? {
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
        
        let dataOutAvailable = dataInLength + kCCBlockSizeAES128
        let dataOut = UnsafeMutablePointer<UInt8>.allocate(capacity: dataOutAvailable)
        
        let dataOutMoved = UnsafeMutablePointer<Int>.allocate(capacity: 1)  // 编解码操作后返回的数据长度指针
        dataOutMoved.initialize(to: 0)
        
        defer {
            dataOut.deallocate()
            dataOutMoved.deallocate()
        }
        
        let result = CCCrypt(operation,
                             CCAlgorithm(kCCAlgorithmAES),
                             CCOptions(kCCOptionECBMode | kCCOptionPKCS7Padding),   //  加密模式(默认CBC) | 补码方式,
                             keyPointer,
                             kCCKeySizeAES128,                                             // 秘钥长度
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
