//
//  SwizzleViewController.swift
//  MultistageBar
//
//  Created by x on 2022/1/5.
//  Copyright © 2022 x. All rights reserved.
//

import UIKit

class SwizzleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        var res = SwizzleViewController.swizzleMethod(#selector(ddl_viewWillAppear(_:)), withMethod: #selector(viewWillAppear(_:)))
        debugPrint("swizzle result is \(res)")
        
        res = SwizzleViewController.swizzleMethod(#selector(ddl_methodOne), withMethod: #selector(ddl_methodTwo))
        
        debugPrint("swizzle result is \(res)")
        
        //        ddl_methodTwo()           // 立马调用会没有效果
        perform(#selector(ddl_methodOne), with: nil, afterDelay: 1)
    }
    
    @objc func ddl_methodOne() {
        debugPrint("method one")
    }
    
    @objc func ddl_methodTwo() {
        debugPrint("method two")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugPrint("view will appear")
    }
    
    @objc func ddl_viewWillAppear(_ animated: Bool) {
        debugPrint("ddl view will appear")
    }

}
