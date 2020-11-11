//
//  MBEncoder.swift
//  MultistageBar
//
//  Created by x on 2020/11/9.
//  Copyright © 2020 x. All rights reserved.
//

import Foundation
import VideoToolbox
import CoreFoundation


/*
    参考网址:
    https://www.cnblogs.com/duzhaoquan/p/13534775.html
 
    测试h.264文件是否正常,可以通过mediainfo(通过homebrew安装)或者ffplay(通过homebrew安装)
    方法一:mediainfo path.h264
    方法二:ffplay  path.h264
 */
protocol MBEncoderDelegate: NSObjectProtocol {
    func encoded(nalu: Data)
//    func encoded(sps: Data, pps: Data)
}

class MBEncoder {
    func prepareCompress() {
                let status = VTCompressionSessionCreate(allocator: nil,
                                                        width: width,
                                                        height: height,
                                                        codecType: kCMVideoCodecType_H264,
                                                        encoderSpecification: nil,
                                                        imageBufferAttributes: nil,
                                                        compressedDataAllocator: nil,
                                                        outputCallback: outputCallback,
                                                        refcon: Unmanaged.passUnretained(self).toOpaque(),
                                                        compressionSessionOut: &session)
        
        if status == noErr, let session = session {
            VTSessionSetProperties(session, propertyDictionary: properties as CFDictionary)
            VTCompressionSessionPrepareToEncodeFrames(session)
        }else{
            print("initial compression session failed")
        }
    }
    
    func compress(sampleBuffer: CMSampleBuffer) {
        guard let session = session else {
            print("compression session nil")
            return
        }
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer)  else {
            print("retrieve fail from CMSampleBuffer")
            return
        }
        encodeQueue.async { [weak self] in
            // 加frameID后会很模糊,不知
//            self.frameID += 1
//            let pts = CMTime.init(value: self.frameID, timescale: 1000)
            let pts = CMTime.init(value: 0, timescale: 1000)
            let dts = CMTime.invalid
//            var flags = VTEncodeInfoFlags.init()
            let status = VTCompressionSessionEncodeFrame(session, imageBuffer: buffer, presentationTimeStamp: pts, duration: dts, frameProperties: nil, sourceFrameRefcon: nil, infoFlagsOut: nil)
            if status != noErr {
                self?.stop()
                print("encode filed sampleBuffer\(sampleBuffer)")
            }
        }
    }
    private func videoFrame(sampleBuffer: CMSampleBuffer) {
        // 方法一
//        let dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer)
//        var dataPointer: UnsafeMutablePointer<Int8>?  = nil
//        var totalLength :Int = 0
//        let blockState = CMBlockBufferGetDataPointer(dataBuffer!, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &totalLength, dataPointerOut: &dataPointer)
//        if blockState != 0{
//            print("获取data失败\(blockState)")
//        }
//
//        //NALU
//        var offset :UInt32 = 0
//        //返回的nalu数据前四个字节不是0001的startcode(不是系统端的0001)，而是大端模式的帧长度length
//        let lengthInfoSize = 4
//        //循环写入nalu数据
//        while offset < totalLength - lengthInfoSize {
//            //获取nalu 数据长度
//            var naluDataLength:UInt32 = 0
//            memcpy(&naluDataLength, dataPointer! + UnsafeMutablePointer<Int8>.Stride(offset), lengthInfoSize)
//            //大端转系统端
//            naluDataLength = CFSwapInt32BigToHost(naluDataLength)
//            //获取到编码好的视频数据
//            var data = Data(capacity: Int(naluDataLength) + lengthInfoSize)
//            data.append([0,0,0,1], count: 4)
//            //转化pointer；UnsafeMutablePointer<Int8> -> UnsafePointer<UInt8>
//            let naluUnsafePoint = unsafeBitCast(dataPointer, to: UnsafePointer<UInt8>.self)
//
//            data.append(naluUnsafePoint + UnsafePointer<UInt8>.Stride(offset + UInt32(lengthInfoSize)) , count: Int(naluDataLength))
//
//            file?.write(data)
//            print("writed nalu.count \(data.count)")
//            offset += (naluDataLength + UInt32(lengthInfoSize))
//        }

        // 方法二
        guard let dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
            print("output data buffer failed")
            return
        }
        var totalLength: Int = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        let status = CMBlockBufferGetDataPointer(dataBuffer,
                                    atOffset: 0,
                                    lengthAtOffsetOut: nil,
                                    totalLengthOut: &totalLength,
                                    dataPointerOut: &dataPointer)
        if status == noErr, let dataPointer = dataPointer {
            var offset = 0;
            let lengthInfoSize = 4
            while offset < totalLength - lengthInfoSize {
                var naluLength: UInt32 = 0
                memcpy(&naluLength, dataPointer + offset, lengthInfoSize)
                naluLength = CFSwapInt32BigToHost(naluLength)
                // 一个nalu
                var data = Data.init()
                data.append([0,0,0,1], count: 4)
                let start = unsafeBitCast(dataPointer, to: UnsafePointer<UInt8>.self)
                let location = start + UnsafePointer<UInt8>.Stride(offset + lengthInfoSize)
                data.append(location, count: Int(naluLength))
                delegate?.encoded(nalu: data)
                offset += (lengthInfoSize + Int(naluLength))
            }
        }
    }
    
    // 关键帧 sps/pps
    private func keyFrame(format: CMFormatDescription) {
        // 方法一
//        var spsSize: Int = 0, spsCount: Int = 0
//        var ppsSize: Int = 0, ppsCount: Int = 0
//
//        var spsDataPointer: UnsafePointer<UInt8>? = UnsafePointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 0))
//        var ppsDataPointer: UnsafePointer<UInt8>? = UnsafePointer<UInt8>(bitPattern: 0)
//        let spsstatus = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, parameterSetIndex: 0, parameterSetPointerOut: &spsDataPointer, parameterSetSizeOut: &spsSize, parameterSetCountOut: &spsCount, nalUnitHeaderLengthOut: nil)
//        if spsstatus != 0{
//            print("sps失败")
//        }
//
//        let ppsStatus = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, parameterSetIndex: 1, parameterSetPointerOut: &ppsDataPointer, parameterSetSizeOut: &ppsSize, parameterSetCountOut: &ppsCount, nalUnitHeaderLengthOut: nil)
//        if ppsStatus != 0 {
//            print("pps失败")
//        }
//
//        let startCode: [UInt8] = [0,0,0,1]
//        if let spsData = spsDataPointer, let ppsData = ppsDataPointer{
//            var spsDataValue = Data(capacity: 4 + spsSize)
//            spsDataValue.append(startCode, count: 4)
//            spsDataValue.append(spsData, count: spsSize)
//            file?.write(spsDataValue)
//
//            var ppsDataValue = Data(capacity: 4 + ppsSize)
//            ppsDataValue.append(startCode, count: 4)
//            ppsDataValue.append(ppsData, count: ppsSize)
//            file?.write(ppsDataValue)
//        }
        
        // 方法二
        var spsPointer = UnsafePointer<UInt8>.init(bitPattern: 0)
        var spsSize = 0
        var spsCount = 0
        CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, parameterSetIndex: 0, parameterSetPointerOut: &spsPointer, parameterSetSizeOut: &spsSize, parameterSetCountOut: &spsCount, nalUnitHeaderLengthOut: nil)

        var ppsPointer = UnsafePointer<UInt8>.init(bitPattern: 0)
        var ppsSize = 0
        var ppsCount = 0
        CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, parameterSetIndex: 1, parameterSetPointerOut: &ppsPointer, parameterSetSizeOut: &ppsSize, parameterSetCountOut: &ppsCount, nalUnitHeaderLengthOut: nil)
        if let spsPointer = spsPointer, let ppsPointer = ppsPointer {
            let naluStart:[UInt8] = [0,0,0,1]
            var sps = Data.init()
            sps.append(naluStart, count: 4)
            sps.append(spsPointer, count: spsSize)
            
            var pps = Data.init()
            pps.append(naluStart, count: 4)
            pps.append(ppsPointer, count: ppsSize)
            delegate?.encoded(nalu: sps)
            delegate?.encoded(nalu: pps)
        }
    }
    
    func stop() {
        guard let session = session else { return }
        VTCompressionSessionCompleteFrames(session, untilPresentationTimeStamp: .invalid)
        VTCompressionSessionInvalidate(session)
        self.session = nil
    }
    
    
    private let outputCallback: VTCompressionOutputCallback = { pointer, framePointer, status, flags, buffer in
        guard status == noErr,
              let buffer = buffer else {
            print("encoder callback sampleBuffer nil or status \(status)")
            return
        }
        guard let pointer = pointer else {
            print("no more operations")
            return
        }
        guard let attachments = CMSampleBufferGetSampleAttachmentsArray(buffer, createIfNecessary: true),
              let attachment = CFArrayGetValueAtIndex(attachments, 0) else {
            return
        }
        let encoder = Unmanaged<MBEncoder>.fromOpaque(pointer).takeUnretainedValue()
        let dict = unsafeBitCast(attachment, to: CFDictionary.self)
        let key = unsafeBitCast(kCMSampleAttachmentKey_NotSync, to: UnsafeRawPointer.self)
        if CFDictionaryContainsKey(dict, key) == false, let format = CMSampleBufferGetFormatDescription(buffer) {
            encoder.keyFrame(format: format)
        }
        encoder.videoFrame(sampleBuffer: buffer)
    }
    
    var frameID:Int64 = 0
    var width: Int32 = 480 // in pixel
    var height: Int32 = 640
    weak var delegate: MBEncoderDelegate?
    private var session: VTCompressionSession?
    private lazy var encodeQueue: DispatchQueue = {
        let queue = DispatchQueue.init(label: "encode.queue")
        return queue
    }()
    private var properties:[AnyHashable: Any] {
        let properties:[AnyHashable: Any] = [
            kVTCompressionPropertyKey_RealTime: kCFBooleanTrue as Any,
            kVTCompressionPropertyKey_ProfileLevel: kVTProfileLevel_H264_Baseline_AutoLevel,
            kVTCompressionPropertyKey_AllowFrameReordering: kCFBooleanFalse as Any,
            kVTCompressionPropertyKey_MaxKeyFrameInterval: 10,
            kVTCompressionPropertyKey_ExpectedFrameRate: 30,
            kVTCompressionPropertyKey_AverageBitRate: Int(width * height * 3 * 4)
        ]
        return properties
    }
    
}
