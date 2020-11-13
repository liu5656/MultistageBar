//
//  AMF3DataTypes.swift
//  swift-rtmp
//
//  Created by kPherox on 2020/05/15.
//  Copyright © 2020 kPherox. All rights reserved.
//

import Foundation
import CRTMP

public enum AMF3DataTypes {

    case undefined
    case null
    case `false`
    case `true`
    case integer
    case double
    case string
    case xmlDoc
    case data
    case array
    case object
    case xml
    case byteArray

    var cValue: AMF3DataType {
        switch self {
            case .undefined: return AMF3_UNDEFINED
            case .null: return AMF3_NULL
            case .false: return AMF3_FALSE
            case .true: return AMF3_TRUE
            case .integer: return AMF3_INTEGER
            case .double: return AMF3_DOUBLE
            case .string: return AMF3_STRING
            case .xmlDoc: return AMF3_XML_DOC
            case .data: return AMF3_DATE
            case .array: return AMF3_ARRAY
            case .object: return AMF3_OBJECT
            case .xml: return AMF3_XML
            case .byteArray: return AMF3_BYTE_ARRAY
        }
    }

    init?(cValue: AMF3DataType) {
        switch cValue {
            case AMF3_UNDEFINED: self = .undefined
            case AMF3_NULL: self = .null
            case AMF3_FALSE: self = .false
            case AMF3_TRUE: self = .true
            case AMF3_INTEGER: self = .integer
            case AMF3_DOUBLE: self = .double
            case AMF3_STRING: self = .string
            case AMF3_XML_DOC: self = .xmlDoc
            case AMF3_DATE: self = .data
            case AMF3_ARRAY: self = .array
            case AMF3_OBJECT: self = .object
            case AMF3_XML: self = .xml
            case AMF3_BYTE_ARRAY: self = .byteArray
            default: fatalError("Invalid AMF3DataType value: \(cValue)")
        }
    }
}

