//
//  MBNet.swift
//  MultistageBar
//
//  Created by x on 2021/6/8.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit




/* 参考
 https://blog.csdn.net/u012138272/article/details/76714099          iOS NSURLSession Https请求
 https://www.jianshu.com/p/3ff885ec989e                             iOS Https证书验证问题全解
 https://www.jianshu.com/p/6dbe8bd7782c                             iOS Swift 适配HTTPS（单向验证）
 https://blog.csdn.net/weixin_39642925/article/details/107099184    [iOS] [Swift] HTTPS Client Certificate / Server Certificate
 https://blog.csdn.net/ZZB_Bin/article/details/73135506             IOS Swift Https单向认证
 https://blog.csdn.net/duanbokan/article/details/50847612           Https单向认证和双向认证
 */
class MBNet: NSObject {
    
    lazy var session: URLSession = {
        let queue = OperationQueue.init()
        let config = URLSessionConfiguration.default
        let ses = URLSession.init(configuration: config, delegate: self, delegateQueue: queue)
        return ses
    }()
    
    func request(url urlStr: String, method: String) {
        guard let url = URL.init(string: urlStr) else {
            return
        }
        
        var req = URLRequest.init(url: url)
        req.httpMethod = method
        let task = session.dataTask(with: req) { (data, res, err) in
            
            MBLog("data: \(String.init(data: data ?? Data(), encoding: .utf8)) \nres: \(res?.description) \nerr: \(err.debugDescription)")
        }
        task.resume()
    }
    // 不验证服务端,直接全部信任
    func trustRemoteAlways(challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        let disposition = URLSession.AuthChallengeDisposition.useCredential
        var cre: URLCredential?
        if let trust = challenge.protectionSpace.serverTrust {
            cre = URLCredential.init(trust: trust)
        }
        return (disposition, cre)
    }
    // 对服务器发过来的证书进行验证
    func verifyRemoteWithCer(challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard let remotePackage = challenge.protectionSpace.serverTrust,
              let remoteCerti = SecTrustGetCertificateAtIndex(remotePackage, 0),
              let localPath = Bundle.main.path(forResource: "server", ofType: "cer") else {
            return (URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        }
        let remoteCertiData = SecCertificateCopyData(remoteCerti) as Data
        let localUrl = URL.init(fileURLWithPath: localPath)
        let localCertiData = try? Data.init(contentsOf: localUrl)
        let disposition: URLSession.AuthChallengeDisposition
        var credential: URLCredential? = nil
        if remoteCertiData == localCertiData {
            disposition = URLSession.AuthChallengeDisposition.useCredential
            credential = URLCredential.init(trust: remotePackage)
        }else{
            disposition = URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge
        }
        return (disposition, credential)
    }
    // 获取本地p12文件以供远端校验
    func retrieveLocalCredential() -> URLCredential? {
        let certificationName = "client.p12"
        let certificationPassword = "123456"
        guard let localPath = Bundle.main.path(forResource: certificationName, ofType: nil) else {
            return nil
        }
        
        let localUrl = URL.init(fileURLWithPath: localPath)
        
        guard let pkcs12 = try? Data.init(contentsOf: localUrl) as CFData else {
            return nil
        }
        
        let options = [kSecImportExportPassphrase: certificationPassword] as CFDictionary
        var items: CFArray?
        let result = SecPKCS12Import(pkcs12, options, &items)
        
        guard result == errSecSuccess,
              let info = (items! as Array).first as? [String: Any] else {
            return nil
        }
        
        let identify = info["identity"] as! SecIdentity
        let certificates = info["chain"] as? [Any]
        let type = URLCredential.Persistence.forSession
        
        return URLCredential.init(identity: identify, certificates: certificates, persistence: type)
    }
}

extension MBNet: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let result: (URLSession.AuthChallengeDisposition, URLCredential?)
        let method = challenge.protectionSpace.authenticationMethod
        switch method {
        case NSURLAuthenticationMethodServerTrust:
            result = verifyRemoteWithCer(challenge: challenge)      // 本地校验远端证书
//        result = trustRemoteAlways(challenge: challenge)          // 本地无条件信任远端
        case NSURLAuthenticationMethodClientCertificate:            // 返回本地证书给远端校验
            result = (URLSession.AuthChallengeDisposition.useCredential, retrieveLocalCredential())
        default:
            result = (URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        }
        completionHandler(result.0, result.1)
    }
}
