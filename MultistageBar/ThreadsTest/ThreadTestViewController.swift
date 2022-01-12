//
//  ThreadTestViewController.swift
//  MultistageBar
//
//  Created by x on 2022/1/12.
//  Copyright © 2022 x. All rights reserved.
//

import UIKit

class ThreadTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /*
     队列：串行/并行，主队列是串行队列，全局队列是并行队列
     任务：
        异步任务添加到指定队列中,不做等待,直接执行,具有开辟新线程的能力，
        同步任务添加到指定队列中,在添加的任务执行完之前会一直等待,没有开辟线程的能力
     
     有四种组合：
     1、串行队列+同步任务
     2、串行队列+异步任务
     3、并行队列+同步任务
     4、并行队列+异步任务
     */
    
    // 串行队列+同步任务
    @IBAction func serialSync(_ sender: Any) {
        print("serial sync task begin:")
        let queue = DispatchQueue.init(label: "serial queue")   // 默认是串行队列
        
        queue.sync {
            for _ in 0..<2 {
                sleep(2)
                print("1: \(Thread.current)")
            }
        }
        
        queue.sync {
            for _ in 0..<2 {
                sleep(2)
                print("2: \(Thread.current)")
            }
        }
        
        queue.sync {
            for _ in 0..<2 {
                sleep(2)
                print("3: \(Thread.current)")
            }
        }
        
        print("serial sync task end: \n\n")
    }
    
    // 串行队列+异步任务
    @IBAction func serialAsync(_ sender: Any) {
        print("serial async task begin:")
        let queue = DispatchQueue.init(label: "serial queue")
        
        queue.async {
            for _ in 0..<2 {
                sleep(2)
                print("1: \(Thread.current)")
            }
        }
        
        queue.async {
            for _ in 0..<2 {
                sleep(2)
                print("2: \(Thread.current)")
            }
        }
        
        queue.async {
            for _ in 0..<2 {
                sleep(2)
                print("3: \(Thread.current)")
            }
        }
        
        print("serial async task end: \n\n")
    }
    
    // 并行队列+同步任务
    @IBAction func concurrentSync(_ sender: Any) {
        print("concurrent sync task begin:")
        let queue = DispatchQueue.init(label: "concurrent queue", attributes: DispatchQueue.Attributes.concurrent)
        
        queue.sync {
            for _ in 0..<2 {
                sleep(2)
                print("1: \(Thread.current)")
            }
        }
        
        queue.sync {
            for _ in 0..<2 {
                sleep(2)
                print("2: \(Thread.current)")
            }
        }
        
        queue.sync {
            for _ in 0..<2 {
                sleep(2)
                print("3: \(Thread.current)")
            }
        }
        
        print("concurrent sync task end: \n\n")
    }
    
    // 并行队列+异步任务
    @IBAction func concurrentAsync(_ sender: Any) {
        print("concurrent async task begin:")
        let queue = DispatchQueue.init(label: "concurrent queue", attributes: DispatchQueue.Attributes.concurrent)
        
        queue.async {
            for _ in 0..<2 {
                sleep(2)
                print("1: \(Thread.current)")
            }
        }
        
        queue.async {
            for _ in 0..<2 {
                sleep(2)
                print("2: \(Thread.current)")
            }
        }
        
        queue.async {
            for _ in 0..<2 {
                sleep(2)
                print("3: \(Thread.current)")
            }
        }
        
        print("concurrent async task end: \n\n")
    }
    // 主队列+异步,阻塞
    @IBAction func mainAsync(_ sender: Any) {
        print("main async task begin:")
        let queue = DispatchQueue.main
        
        queue.async {
            for _ in 0..<2 {
                sleep(2)
                print("1: \(Thread.current)")
            }
        }
        
        queue.async {
            for _ in 0..<2 {
                sleep(2)
                print("2: \(Thread.current)")
            }
        }
        
        queue.async {
            for _ in 0..<2 {
                sleep(2)
                print("3: \(Thread.current)")
            }
        }
        
        print("main async task end: \n\n")
    }
    
    // 主队列+同步任务,阻塞后导致崩溃
    @IBAction func mainSync(_ sender: Any) {
        print("main sync task begin:")
        let queue = DispatchQueue.main
        
        queue.sync {
            for _ in 0..<2 {
                sleep(2)
                print("1: \(Thread.current)")
            }
        }
        
        queue.sync {
            for _ in 0..<2 {
                sleep(2)
                print("2: \(Thread.current)")
            }
        }
        
        queue.sync {
            for _ in 0..<2 {
                sleep(2)
                print("3: \(Thread.current)")
            }
        }
        
        print("main sync task end: \n\n")
    }
    
    
}
