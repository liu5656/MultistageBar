//
//  RTMPChunk.swift
//  swift-rtmp
//
//  Created by kPherox on 2020/05/15.
//  Copyright © 2020 kPherox. All rights reserved.
//

import Foundation
import CRTMP

public extension RTMP {

    struct Chunk {

        var headerSize: Int
        var chunkSize: Int
        var chunk: String
        var header: String // RTMP_MAX_HEADER_SIZE = 18

        var cValue: RTMPChunk {
            var cHeader: (Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

            for (i, char) in (self.header.cString(using: String.Encoding.utf8) ?? []).enumerated() {
                switch i {
                    case  0: cHeader.0 = char
                    case  1: cHeader.1 = char
                    case  2: cHeader.2 = char
                    case  3: cHeader.3 = char
                    case  4: cHeader.4 = char
                    case  5: cHeader.5 = char
                    case  6: cHeader.6 = char
                    case  7: cHeader.7 = char
                    case  8: cHeader.8 = char
                    case  9: cHeader.9 = char
                    case 10: cHeader.10 = char
                    case 11: cHeader.11 = char
                    case 12: cHeader.12 = char
                    case 13: cHeader.13 = char
                    case 14: cHeader.14 = char
                    case 15: cHeader.15 = char
                    case 16: cHeader.16 = char
                    case 17: cHeader.17 = char
                    default: break
                }
            }

            return RTMPChunk(c_headerSize: Int32(self.headerSize),
                             c_chunkSize: Int32(self.chunkSize),
                             c_chunk: self.chunk.toCString(),
                             c_header: cHeader)
        }

        init?(cValue: RTMPChunk) {
            self.headerSize = Int(cValue.c_headerSize)
            self.chunkSize = Int(cValue.c_chunkSize)
            self.chunk = String(cString: cValue.c_chunk)
            self.header = String(fromCCharTuple: cValue.c_header)
        }
    }
}
