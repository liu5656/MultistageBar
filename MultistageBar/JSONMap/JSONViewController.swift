//
//  JSONViewController.swift
//  MultistageBar
//
//  Created by x on 2020/9/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class JSONViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        //1.jsonString中获取数据封装成Model
        let p1String = "{\"name\":\"walden\",\"age\":30,\"sex\":\"man\"}"
        let p1 = Person.deserialize(from: p1String)
         
        //2.jsonString中获取数据封装成Array
        let personString = "{\"haha\":[{\"name\":\"walden\",\"age\":30,\"sex\":\"man\"},{\"name\":\"healer\",\"age\":20,\"sex\":\"female\"}]}"
        
        let persons = [Person].deserialize(from: personString, path: "haha")
         
        //3.对象转jsonString
        let jsonString = p1?.jsonString()
         
        //4.对象转jsonObject
        let jsonObject = p1?.json()
    }

}
