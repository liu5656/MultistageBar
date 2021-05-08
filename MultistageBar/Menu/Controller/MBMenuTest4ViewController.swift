//
//  MBMenuTest4ViewController.swift
//  MultistageBar
//
//  Created by x on 2021/5/7.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBMenuTest4ViewController: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = table
        _ = pan
    }
    
    @objc func gesture(pan: UIPanGestureRecognizer) {
        let point = pan.translation(in: view)
        let velocity = pan.velocity(in: view)
        MBLog("\(velocity) ---- \(point)")
        switch pan.state {
        case .began:
            break
        case .changed:
            verticalHandler(detal: point.y)
            break
        case .ended:
            break
        default:
            break
        }
        pan.setTranslation(CGPoint.zero, in: view)
    }
    func verticalHandler(detal: CGFloat) {
        if table.contentOffset.y >= maxY {
            
        }
    }
    
    
    let maxY: CGFloat = 220
    let identify = "cell"
    lazy var table: UITableView = {
        let tab = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: Screen.height - Screen.fakeNavBarHeight))
        tab.tableFooterView = footer
        tab.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: identify)
        tab.isScrollEnabled = false
        tab.dataSource = self
        view.addSubview(tab)
        return tab
    }()
    lazy var footer: MBLinkageTableV2 = {
        let foo = MBLinkageTableV2.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: 880 ))
        return foo
    }()
    
    lazy var pan: UIPanGestureRecognizer = {
        let ges = UIPanGestureRecognizer.init(target: self, action: #selector(gesture(pan:)))
        view.addGestureRecognizer(ges)
        return ges
    }()

}

extension MBMenuTest4ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identify, for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}
