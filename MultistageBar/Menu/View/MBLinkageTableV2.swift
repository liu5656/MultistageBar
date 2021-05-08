//
//  MBLinkageTableV2.swift
//  MultistageBar
//
//  Created by x on 2021/5/7.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBLinkageTableV2: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = left
        _ = right
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateRightOffset(_ value: CGPoint) {
        right.setContentOffset(value, animated: true)
    }

    let leftIdentify = "leftIdentify"
    lazy var left: UITableView = {
        let tab = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: bounds.height))
        tab.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: leftIdentify)
        tab.isScrollEnabled = false
        tab.dataSource = self
        addSubview(tab)
        return tab
    }()
    let rightIdentify = "rightIdentify"
    lazy var right: UITableView = {
        let tab = UITableView.init(frame: CGRect.init(x: left.frame.maxX + 10, y: 0, width: Screen.width - left.frame.maxX - 20, height: bounds.height))
        tab.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: rightIdentify)
        tab.isScrollEnabled = false
        tab.dataSource = self
        addSubview(tab)
        return tab
    }()

}

extension MBLinkageTableV2: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if left == tableView {
            return 20
        }else{
            return 100
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if left == tableView {
            cell = tableView.dequeueReusableCell(withIdentifier: leftIdentify, for: indexPath)
            cell.textLabel?.text = "left:\(indexPath.row)"
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: rightIdentify, for: indexPath)
            cell.textLabel?.text = "right:\(indexPath.row)"
        }
        return cell
    }
}
