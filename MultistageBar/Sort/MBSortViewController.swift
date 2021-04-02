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
    #warning("交换排序")
    // 快速排序
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
    // 冒泡排序
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
    #warning("插入排序")
    // 直接插入排序
    @IBAction func insertSort(_ sender: Any) {
        var data = [25,11,4,9,10,7]
        let origin = data
        var  temp: Int = 0
        for i in 1..<data.count {
            if data[i - 1] > data[i] {
                temp = data[i]
                for j in (0..<i).reversed() {
                    if data[j] > temp {
                        data[j + 1] = data[j]
                        if 0 == j {
                            data[j] = temp
                            break
                        }
                    }else{
                        data[j + 1] = temp
                        break
                    }
                }
            }
        }
        print("\(origin) -直接插入排序-> \(data)")
    }
    // 希尔排序
    @IBAction func hillSort(_ sender: Any) {
        var data = [12,5,45,13,30,25,29,26,17]
    }
    #warning("选择排序")
    // 直接选择排序
    @IBAction func chooseSort(_ sender: Any) {
        var data = [12,5,45,13,30,25,29,26,17]
        let origin = data
        var min = 0
        for i in 0..<data.count - 1 {
            min = i
            for j in (i+1)..<data.count {
                if data[j] < data[min] {
                    min = j
                }
            }
        }
    }
    // 堆排序
    @IBAction func heapSort(_ sender: Any) {
        var data = [12,5,45,13,30,25,29,26,17]
    }
    #warning("桶排序")
    // 基数排序
    @IBAction func countSort(_ sender: Any) {
        var data = [12,5,45,13,30,25,29,26,17]
    }
    // 基数排序
    @IBAction func cardinalNumberSort(_ sender: Any) {
        var data = [12,5,45,13,30,25,29,26,17]
    }
    
}
