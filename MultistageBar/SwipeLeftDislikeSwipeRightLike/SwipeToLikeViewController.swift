//
//  SwipeToLikeViewController.swift
//  MultistageBar
//
//  Created by x on 2021/2/5.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class SwipeToLikeViewController: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = swipe
    }
    var data = ["0","1","2","3","4","5","6","7","8","9"]
    lazy var swipe: MBDragingContainer = {
        let swp = MBDragingContainer.init()
        swp.frame = CGRect.init(x: 0, y: 0, width: Screen.width, height: 400)
        swp.delegate = self
        swp.backgroundColor = UIColor.blue
        view.addSubview(swp)
        return swp
    }()
    lazy var dislikeB: UIButton = {
        let but = UIButton.init(type: .custom)
        but.frame = CGRect.init(x: 50, y: swipe.frame.maxY + 20, width: 60, height: 30)
        but.backgroundColor = UIColor.black
        but.setTitleColor(UIColor.white, for: .normal)
        but.setTitle("dislike", for: .normal)
        view.addSubview(but)
        return but
    }()
    lazy var likeB: UIButton = {
        let but = UIButton.init(type: .custom)
        but.frame = CGRect.init(x: 50, y: swipe.frame.maxY + 20, width: 60, height: 30)
        but.backgroundColor = UIColor.black
        but.setTitleColor(UIColor.white, for: .normal)
        but.setTitle("dislike", for: .normal)
        view.addSubview(but)
        return but
    }()
    
    deinit {
        MBLog("")
    }
}

extension SwipeToLikeViewController: MBDragingCardDelegate {
    func numberOfCard() -> Int {
        return data.count
    }
    func cellForCard(index: Int, container: MBDragingContainer) -> MBDragingItem {
        let cell = container.retrieveItemFromReusablePool(index: index)
        cell.titleL.text = data[index]
        return cell
    }
    
    func didSlippedOut(index: Int, direction: MBDragingContainer.SlidingDirection) {
        MBLog("\(index) -- \(direction)")
        if (data.count - index) <= 1 {
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 2) {
                excuteInMainThread {
                    let temp = self.data.count
                    for i in temp..<(temp + 10) {
                        self.data.append("\(i)")
                    }
                    self.swipe.preparePreview()
                    MBLog("新增10条数据: \(self.data)")
                }
            }
        }
    }
    func didSelected(index: Int) {
        MBLog(index)
    }
    
    
}
