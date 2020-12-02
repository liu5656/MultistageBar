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
    case student
}


//首先定义一个结构体Person用来表示数据Model
class Person: Codable {
    var name: String?
    var age: Int?
    var sex: String?
    
    @Default<PersonType>        // json存在key,但key对应的value不在范围内
    var type: PersonType
    
    @Default<String>
    var nickname: String        // json不存在对应的key
}
class Student: Person {
    var score: Int = 0
}


class JSONViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        // 自定义结构体
        //1.jsonString中获取数据封装成Model
        let p1String = "{\"name\":\"walden\",\"age\":30,\"sex\":\"man\",\"type\":\"5\"}"
        let p1 = Person.deserialize(from: p1String)

        //2.jsonString中获取数据封装成Array
        let personString = "{\"haha\":[{\"name\":\"walden\",\"age\":30,\"sex\":\"man\",\"type\":\"doctor\"},{\"name\":\"healer\",\"age\":20,\"sex\":\"female\",\"type\":\"police\"}]}"

        let persons = [Person].deserialize(from: personString, path: "haha")

        //3.对象转jsonString
        let jsonString = p1?.jsonString()

        //4.对象转jsonObject
        let jsonObject = p1?.json()

        // 自定义类
        let oneStu = "{\"name\":\"walden\",\"score\":30,\"age\":30}"
        var oneType: Codable.Type = Student.self
        let stu = oneType.deserialize(from: oneStu)

        let manyStu = "{\"haha\":[{\"name\":\"walden\",\"score\":30},{\"name\":\"healer\",\"score\":20}]}"
        oneType = [Student].self
        let stus = oneType.deserialize(from: manyStu, path: "haha")


        let arrStu = [["name": "fasd", "score": 30, "grade": 2], ["name": "fasd", "score": 30, "grade": 3], ["name": "fasd", "score": 30, "grade": 4]]
        let arrStus = oneType.deserialize(from: arrStu)
        
        MBLog("")
    }

}
