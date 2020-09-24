//
//  CodableEx.swift
//  MultistageBar
//
//  Created by x on 2020/9/22.
//  Copyright © 2020 x. All rights reserved.
//

import Foundation

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
        return try? JSONDecoder().decode(Self.self, from: data)
    }
}

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
