//
//  DictionaryEx.swift
//  MultistageBar
//
//  Created by x on 2021/3/22.
//  Copyright © 2021 x. All rights reserved.
//

import Foundation

extension Dictionary {
    func jsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else {return nil}
        return String.init(data: data, encoding: .utf8)
    }
}
