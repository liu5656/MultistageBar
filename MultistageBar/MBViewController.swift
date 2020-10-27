//
//  MBViewController.swift
//  MultistageBar
//
//  Created by x on 2020/10/12.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class MBViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
    }
    deinit {
        MBLog("")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
