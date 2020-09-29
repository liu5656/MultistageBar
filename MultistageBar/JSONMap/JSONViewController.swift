//
//  JSONViewController.swift
//  MultistageBar
//
//  Created by x on 2020/9/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

enum PersonType: Int, JsonEnum {
    case police
    case soldier
    case doctor
}


//首先定义一个结构体Person用来表示数据Model
struct Person: Codable {
    var name: String?
    var age: Int?
    var sex: String?
    var type: PersonType!
}


class JSONViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        //1.jsonString中获取数据封装成Model
        let p1String = "{\"name\":\"walden\",\"age\":30,\"sex\":\"man\",\"type\":1}"
        let p1 = Person.deserialize(from: p1String)
         
        //2.jsonString中获取数据封装成Array
        let personString = "{\"haha\":[{\"name\":\"walden\",\"age\":30,\"sex\":\"man\",\"type\":\"doctor\"},{\"name\":\"healer\",\"age\":20,\"sex\":\"female\",\"type\":\"police\"}]}"
        
        let persons = [Person].deserialize(from: personString, path: "haha")
         
        //3.对象转jsonString
        let jsonString = p1?.jsonString()
         
        //4.对象转jsonObject
        let jsonObject = p1?.json()
    }

}
