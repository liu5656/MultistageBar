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
        tab.dataSource = self
        tab.delegate = self
        addSubview(tab)
        return tab
    }()
    let rightIdentify = "rightIdentify"
    lazy var right: UITableView = {
        let temp = CGRect.init(x: left.frame.maxX + 10, y: 0, width: Screen.width - left.frame.maxX - 20, height: bounds.height)
        let tab = UITableView.init(frame: temp, style: .plain)
        tab.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: rightIdentify)
        tab.isScrollEnabled = false
        tab.dataSource = self
        tab.delegate = self
        addSubview(tab)
        return tab
    }()
    lazy var sectionHeader: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 44))
        lab.textColor = UIColor.red
        lab.backgroundColor = UIColor.green
        lab.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lab.text = "热门精选"
        return lab
    }()
    let evenColo = UIColor.gray
    let oddColo = UIColor.lightGray
}

extension MBLinkageTableV2: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if left == tableView {
            return 20
        }else{
            return 30
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
        cell.backgroundColor = (indexPath.row % 2 == 0) ? evenColo : oddColo
        return cell
    }
}
extension MBLinkageTableV2: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == left {
            // 切换数据,刷新界面
            sectionHeader.text = "热门精选\(indexPath.row)"
            right.contentOffset = CGPoint.zero
            right.reloadData()
        }else{
            // 业务逻辑
        }
        MBLog(indexPath)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == right {
            return sectionHeader
        }else{
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == right {
            return 44
        }else{
            return 0
        }
    }
}
