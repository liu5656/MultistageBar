//
//  CodableEx.swift
//  MultistageBar
//
//  Created by x on 2020/9/22.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit


protocol DefaultValue {
    associatedtype Value: Codable
    static var defaultValue: Value { get }
}

extension String: DefaultValue {
    static var defaultValue = "liu"
}
extension PersonType: DefaultValue {
    static var defaultValue = PersonType.police
}

@propertyWrapper
struct Default<T: DefaultValue> {
    var wrappedValue: T.Value
}

extension Default: Codable {
    init(from decoder: Decoder) throws {
        let contain = try decoder.singleValueContainer()
        wrappedValue = (try? contain.decode(T.Value.self)) ?? T.defaultValue
    }
}

extension KeyedDecodingContainer {
    func decode<T>(_ type: Default<T>.Type, forKey key: Key) throws -> Default<T> where T: DefaultValue {
        try decodeIfPresent(type, forKey: key) ?? Default(wrappedValue: T.defaultValue)
    }
}



/*
    reference
 https://www.jianshu.com/p/febdd25ae525
 https://zhuanlan.zhihu.com/p/83816429
 https://blog.natanrolnik.me/codable-enums-associated-values
 https://www.jianshu.com/p/bdd9c012df15
 https://blog.csdn.net/sinat_35969632/article/details/109635022 // josn中不含有对应key或key对应的value不在值范围内
 */

// encode
public extension Encodable {
    func jsonString() -> String? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return String.init(data: data, encoding: .utf8)
    }
    func json() -> Any? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
    }
}

// decode
extension Decodable {
    static func deserialize(from json: Any?, path: String? = nil) -> Self? {
        guard let model = json,
            JSONSerialization.isValidJSONObject(model),
            var data = try? JSONSerialization.data(withJSONObject: model, options: []) else {
            return nil
        }
        if let temp = path, let partial = extract(from: data, path: temp) {
            data = partial
        }
        return try? JSONDecoder().decode(Self.self, from: data)
    }
    static func deserialize(from jsonStr: String?, path: String? = nil) -> Self? {
        guard let str = jsonStr, var data = str.data(using: .utf8) else {return nil}
        if let temp = path, let partial = extract(from: data, path: temp) {
            data = partial
        }
        do {
            let temp = try JSONDecoder().decode(Self.self, from: data)
            return temp
        } catch let e {
            MBLog(e)
            return nil
        }
    }
}

// 数组
extension Array where Element: Codable {
    static func  deserialize(from jsonStr: String?) -> [Element]? {
        guard let str = jsonStr, let data = str.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) else {return nil}
        return Array.deserialize(from: json)
    }
    static func deserialize(from jsonArr: [Any]?) -> [Element?]? {
        return jsonArr?.map { item -> Element? in
            return Element.deserialize(from: item)
        }
    }
}

// 枚举
protocol JsonEnum: RawRepresentable, Codable where RawValue: Codable {}

enum EnumError: Error {
    case invalidValue
}

extension JsonEnum {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let decoded = try container.decode(RawValue.self)
        if let temp = Self.init(rawValue: decoded){
            self = temp
        }else{
            throw EnumError.invalidValue
        }
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

// util
fileprivate func extract(from data: Data?, path: String?) -> Data? {
    guard let jsonData = data,
        let paths = path?.components(separatedBy: "."),
        paths.count > 0 else {
            return data
    }
    let json = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
    var result: Any? = json
    var abort = false
    var next = json as? [String: Any]
    paths.forEach({ (seg) in
        if seg.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" || abort {
            return
        }
        if let _next = next?[seg] {
            result = _next
            next = _next as? [String: Any]
        } else {
            abort = true
        }
    })
    //判断条件保证返回正确结果,保证没有流产,保证jsonObject转换成了Data类型
    guard abort == false,
        let resultJsonObject = result,
        let data = try? JSONSerialization.data(withJSONObject: resultJsonObject, options: []) else {
            return nil
    }
    return data
}
