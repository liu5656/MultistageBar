//
//  MBDecoder.swift
//  MultistageBar
//
//  Created by x on 2020/11/10.
//  Copyright © 2020 x. All rights reserved.
//

import Foundation
import VideoToolbox

protocol MBDecoderDelegate: NSObjectProtocol {
    func decoded(sampleBuffer: CVImageBuffer)
}

class MBDecoder {
    func decode(nalu: Data) {
        decodeQueue.async { [weak self] in
            self?.parse(nalu: nalu)
        }
    }
    func stop() {
        if session != nil {
            VTDecompressionSessionInvalidate(session!)
            session = nil
        }
    }
    private func parse(nalu: Data) {
        let realLength = nalu.count - 4
        // 将NALU的开始码转为4字节大端NALU的长度信息
        var frame = [
            UInt8.init(truncatingIfNeeded: realLength >> 24),
            UInt8.init(truncatingIfNeeded: realLength >> 16),
            UInt8.init(truncatingIfNeeded: realLength >> 8),
            UInt8.init(truncatingIfNeeded: realLength)
        ]
        frame.append(contentsOf: nalu[4..<nalu.count])
        // 第5个字节是表示数据类型，转为10进制后，7是sps, 8是pps, 5是IDR（I帧）信息
        let type = Int(frame[4] & 0x1f)
        switch type {
        case 5:
            MBLog("I frame")
            if prepareDecompress() {
                decoded(frame: frame)
            }
        case 6:
            MBLog("additional info")
        case 7:
            sps = [UInt8](frame.suffix(from: 4))
            MBLog("sps frame")
        case 8:
            pps = [UInt8](frame.suffix(from: 4))
            MBLog("pps frame")
        default:
            if prepareDecompress() {
                decoded(frame: frame)
            }
            MBLog("common frame")
        }
    }
    private func prepareDecompress() -> Bool {
        guard session == nil else {
            return true
        }
        guard let sps = sps, let pps = pps else {
            return false
        }
        
        let parameterSet = [sps.withUnsafeBufferPointer{$0}.baseAddress!, pps.withUnsafeBufferPointer{$0}.baseAddress!]
        let sizes = [sps.count, pps.count]
        var status = CMVideoFormatDescriptionCreateFromH264ParameterSets(allocator: kCFAllocatorDefault,
                                                                         parameterSetCount: 2,
                                                                         parameterSetPointers: parameterSet,
                                                                         parameterSetSizes: sizes,
                                                                         nalUnitHeaderLength: 4,
                                                                         formatDescriptionOut: &format)
        guard status == noErr, let format = format else {
            MBLog("create format description failed")
            return false
        }
        
        var callback = VTDecompressionOutputCallbackRecord.init(decompressionOutputCallback: outputCallback, decompressionOutputRefCon: Unmanaged.passUnretained(self).toOpaque())
        let imageBufferAttributes: [AnyHashable: Any] = [
            kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
            kCVPixelBufferWidthKey: width,
            kCVPixelBufferHeightKey: height
        ]
        status = VTDecompressionSessionCreate(allocator: kCFAllocatorDefault,
                                              formatDescription: format,
                                              decoderSpecification: nil,
                                              imageBufferAttributes: imageBufferAttributes as CFDictionary,
                                              outputCallback: &callback,
                                              decompressionSessionOut: &session)
        guard status == noErr, let session = session else {
            MBLog("create decompress session failed")
            return false
        }
        VTSessionSetProperty(session, key: kVTDecompressionPropertyKey_RealTime, value: kCFBooleanTrue)
        return true
    }
    private func decoded(frame: [UInt8]) {
        var blockBuffer: CMBlockBuffer?
        var pointer = frame
        var status = CMBlockBufferCreateWithMemoryBlock(allocator: kCFAllocatorDefault,
                                                        memoryBlock: &pointer,
                                                        blockLength: pointer.count,
                                                        blockAllocator: kCFAllocatorNull,
                                                        customBlockSource: nil,
                                                        offsetToData: 0,
                                                        dataLength: pointer.count,
                                                        flags: 0,
                                                        blockBufferOut: &blockBuffer)
        guard status == noErr, blockBuffer != nil else {
            MBLog("create block buffer failed")
            return
        }
        var sampleSizeArray :[Int] = [frame.count]
        var sampleBuffer :CMSampleBuffer?
        status = CMSampleBufferCreateReady(allocator: kCFAllocatorDefault,
                                           dataBuffer: blockBuffer,
                                           formatDescription: format,
                                           sampleCount: CMItemCount.init(1),
                                           sampleTimingEntryCount: CMItemCount.init(),
                                           sampleTimingArray: nil,
                                           sampleSizeEntryCount: CMItemCount.init(1),
                                           sampleSizeArray: &sampleSizeArray,
                                           sampleBufferOut: &sampleBuffer)
        guard status == noErr, sampleBuffer != nil else {
            MBLog("create sample buffer failed")
            return
        }
        let sourceFrame:UnsafeMutableRawPointer? = nil
        var inforFlag = VTDecodeInfoFlags.asynchronous
        status = VTDecompressionSessionDecodeFrame(session!,
                                          sampleBuffer: sampleBuffer!,
                                          flags: VTDecodeFrameFlags._EnableAsynchronousDecompression,
                                          frameRefcon: sourceFrame, infoFlagsOut: &inforFlag)
        if status != noErr {
            MBLog("解码失败")
        }
    }
    
    
    
    var width = 480
    var height = 640
    var sps: [UInt8]?
    var pps: [UInt8]?
    weak var delegate: MBDecoderDelegate?
    var session: VTDecompressionSession?
    var format : CMVideoFormatDescription?
    let outputCallback: VTDecompressionOutputCallback = { pointer, framePointer, status, flags, imageBuffer, pts, dts in
        guard let pointer = pointer else {
            return
        }
        let decoder = Unmanaged<MBDecoder>.fromOpaque(pointer).takeUnretainedValue()
        guard let buffer = imageBuffer else {
            return
        }
        decoder.delegate?.decoded(sampleBuffer: buffer)
    }
    lazy var decodeQueue: DispatchQueue = {
        let queue = DispatchQueue.init(label: "decode.queue")
        return queue
    }()
}
