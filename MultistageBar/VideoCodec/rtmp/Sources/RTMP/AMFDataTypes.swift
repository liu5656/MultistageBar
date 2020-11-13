//
//  AMFDataTypes.swift
//  swift-rtmp
//
//  Created by kPherox on 2020/05/15.
//  Copyright © 2020 kPherox. All rights reserved.
//

import Foundation
import CRTMP

public enum AMFDataTypes {

    case number
    case boolean
    case string
    case object
    case movieclip
    case null
    case undefined
    case reference
    case ecmaArray
    case objectEnd
    case strictArray
    case data
    case longString
    case unsupported
    case recordset
    case xmlDoc
    case typedObject
    case avmplus
    case invalid

    var cValue: AMFDataType {
        switch self {
            case .number: return AMF_NUMBER
            case .boolean: return AMF_BOOLEAN
            case .string: return AMF_STRING
            case .object: return AMF_OBJECT
            case .movieclip: return AMF_MOVIECLIP /* reserved, not used */
            case .null: return AMF_NULL
            case .undefined: return AMF_UNDEFINED
            case .reference: return AMF_REFERENCE
            case .ecmaArray: return AMF_ECMA_ARRAY
            case .objectEnd: return AMF_OBJECT_END
            case .strictArray: return AMF_STRICT_ARRAY
            case .data: return AMF_DATE
            case .longString: return AMF_LONG_STRING
            case .unsupported: return AMF_UNSUPPORTED
            case .recordset: return AMF_RECORDSET /* reserved, not used */
            case .xmlDoc: return AMF_XML_DOC
            case .typedObject: return AMF_TYPED_OBJECT
            case .avmplus: return AMF_AVMPLUS /* switch to AMF3 */
            case .invalid: return AMF_INVALID
        }
    }

    init?(cValue: AMFDataType) {
        switch cValue {
            case AMF_NUMBER: self = .number
            case AMF_BOOLEAN: self = .boolean
            case AMF_STRING: self = .string
            case AMF_OBJECT: self = .object
            case AMF_MOVIECLIP: self = .movieclip /* reserved, not used */
            case AMF_NULL: self = .null
            case AMF_UNDEFINED: self = .undefined
            case AMF_REFERENCE: self = .reference
            case AMF_ECMA_ARRAY: self = .ecmaArray
            case AMF_OBJECT_END: self = .objectEnd
            case AMF_STRICT_ARRAY: self = .strictArray
            case AMF_DATE: self = .data
            case AMF_LONG_STRING: self = .longString
            case AMF_UNSUPPORTED: self = .unsupported
            case AMF_RECORDSET: self = .recordset /* reserved, not used */
            case AMF_XML_DOC: self = .xmlDoc
            case AMF_TYPED_OBJECT: self = .typedObject
            case AMF_AVMPLUS: self = .avmplus /* switch to AMF3 */
            case AMF_INVALID: self = .invalid
            default: fatalError("Invalid AMFDataType value: \(cValue)")
        }
    }
}

