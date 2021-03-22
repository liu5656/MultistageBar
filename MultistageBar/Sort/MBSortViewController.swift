//
//  MBSortViewController.swift
//  MultistageBar
//
//  Created by x on 2021/3/19.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBSortViewController: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func button(_ sender: Any) {
        
    }
    
    @IBAction func qukickSelect(_ sender: Any) {
        var data = [4,3,7,5,2,1]
        let origin = data
        for i in 0..<(data.count - 1) {
            for j in (i+1)..<data.count {
                if data[i] < data[j] {
                    let temp = data[j]
                    data[j] = data[i]
                    data[i] = temp
                }
            }
        }
        print("\(origin) -快排-> \(data)")
    }
    
    @IBAction func bubbling(_ sender: Any) {
        var data = [24,23,27,15,22,11]
        let origin = data
        for i in 0..<(data.count - 1) {
            for j in 0..<(data.count - i - 1) {
                if data[j] < data[j + 1] {
                    let temp = data[j + 1]
                    data[j + 1] = data[j]
                    data[j] = temp
                }
            }
        }
        print("\(origin) -冒泡-> \(data)")
    }
}
