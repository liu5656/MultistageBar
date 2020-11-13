//
//  Rtmp.swift
//  swift-rtmp
//
//  Created by kPherox on 2019/02/23.
//  Copyright © 2019 kPherox. All rights reserved.
//

import Foundation
import CRTMP

public final class Rtmp {

    let rtmp: UnsafeMutablePointer<RTMP>

    init(_ rtmp: UnsafeMutablePointer<RTMP>) {
        self.rtmp = rtmp
        RTMP_Init(self.rtmp)
    }

    public convenience init() {
        self.init(RTMP_Alloc())
    }

    public func parseUrl(_ url: String) -> (result: Bool, proto: RTMPProtocol, host: String, port: Int, playpath: String, appName: String) {
        var parsedHost: AVal = AVal()
        var parsedPlaypath: AVal = AVal()
        var parsedApp: AVal = AVal()
        var parsedProtocol: Int32 = RTMPProtocol.undefined.cValue
        var parsedPort: UInt32 = 0
        let result: Int32 = RTMP_ParseURL(url.toCString(), &parsedProtocol, &parsedHost, &parsedPort, &parsedPlaypath, &parsedApp)

        return (result != 0, RTMPProtocol(cValue: parsedProtocol) ?? RTMPProtocol.undefined, String(cString: parsedHost.av_val), Int(parsedPort), String(cString: parsedPlaypath.av_val), String(cString: parsedApp.av_val))
    }

    public func setBuffer(milliSeconds size: Int32) {
        RTMP_SetBufferMS(self.rtmp, size)
    }

    public func updateBufferMilliSeconds() {
        RTMP_UpdateBufferMS(self.rtmp)
    }

    public func setOption(kind: String, value: String) -> Bool {
        var avOption: AVal = kind.toAVal()
        var avValue: AVal = value.toAVal()
        let result: Int32 = RTMP_SetOpt(self.rtmp, &avOption, &avValue)

        return result != 0
    }

    public func setupUrl(_ url: String) -> Bool {
        let result: Int32 = RTMP_SetupURL(self.rtmp, url.toCString())

        return result != 0
    }

    public func setupStream(proto: RTMPProtocol, host: String, port: Int, socketHost: String, playpath: String, tcUrl: String, swfUrl: String, pageUrl: String, appName: String, auth: String, swfSHA256Hash: String, swfSize: Int, flashVer: String, subscribepath: String, usherToken: String, dStart: Int, dStop: Int, bLiveStream: Int, timeout: Int) {
        var avHost: AVal = host.toAVal()
        var avSocketHost: AVal = socketHost.toAVal()
        var avPlaypath: AVal = playpath.toAVal()
        var avTcUrl: AVal = tcUrl.toAVal()
        var avSwfUrl: AVal = swfUrl.toAVal()
        var avPageUrl: AVal = pageUrl.toAVal()
        var avAppName: AVal = appName.toAVal()
        var avAuth: AVal = auth.toAVal()
        var avSwfSHA256Hash: AVal = swfSHA256Hash.toAVal()
        var avFlashVer: AVal = flashVer.toAVal()
        var avSubscribepath: AVal = subscribepath.toAVal()
        var avUsherToken: AVal = usherToken.toAVal()

        RTMP_SetupStream(self.rtmp, proto.cValue, &avHost, UInt32(port), &avSocketHost, &avPlaypath, &avTcUrl, &avSwfUrl, &avPageUrl, &avAppName, &avAuth, &avSwfSHA256Hash, UInt32(swfSize), &avFlashVer, &avSubscribepath, &avUsherToken, Int32(dStart), Int32(dStop), Int32(bLiveStream), timeout)
    }
    
    // ...
    func connect() {
        RTMP_Connect(self.rtmp, nil)
        RTMP_ConnectStream(self.rtmp, 0)
    }
    func read() {
        var buf: [Int8] = []
        let size: Int32 = 0
        let result = RTMP_Read(self.rtmp, &buf, size)
        
        
//        RTMP_ReadPacket(<#T##r: UnsafeMutablePointer<RTMP>!##UnsafeMutablePointer<RTMP>!#>, <#T##packet: UnsafeMutablePointer<RTMPPacket>!##UnsafeMutablePointer<RTMPPacket>!#>)
    }
}
