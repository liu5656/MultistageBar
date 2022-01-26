//
//  AsyncViewController.swift
//  MultistageBar
//
//  Created by x on 2022/1/17.
//  Copyright © 2022 x. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class AsyncViewController: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        asyncTest()
        asyncTest2()
    }
    
    func asyncTest() {
        Task.init {
            try await processFromScratch()
        }
    }
    
    func asyncTest2() {
        Task{
            try await loadFromDatabase()
            try await loadSignature()
        }
    }
    
    var result: [String] = []
    
    // 异步绑定,被绑定的会立即开始执行
    func processFromScratch() async throws {
        async let database = loadFromDatabase()
        async let signature = loadSignature()
        print("async bind end")
        let string = try await database
        if let sig = try await signature {
            result.append(sig)
        }else{
//            throw NSExceptionName.init(rawValue: "throw a exception")
        }
        
    }
    
    func loadFromDatabase() async throws {
        print("load from database begin")
        sleep(3)
        print("load from database end")
    }
    
    func loadSignature() async throws -> String? {
        print("load signature begin")
        sleep(1)
        print("load signature end")
        return "123"
    }
    
    
    
    
}
