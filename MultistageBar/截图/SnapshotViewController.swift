//
//  SnapshotViewController.swift
//  MultistageBar
//
//  Created by x on 2022/1/26.
//  Copyright © 2022 x. All rights reserved.
//

import UIKit

class SnapshotViewController: MBViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = table
        _ = rightB
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    @objc func snapshot() {
        let img = table.capture(targetSize: view.bounds.size)
        print(img?.size)
    }
    
    lazy var table: UITableView = {
        let tab = UITableView.init()
        tab.dataSource = self
        tab.estimatedRowHeight = 44
        tab.estimatedSectionHeaderHeight = 0
        tab.estimatedSectionFooterHeight = 0
        view.addSubview(tab)
        return tab
    }()
    
    lazy var rightB: UIBarButtonItem = {
            let but = UIBarButtonItem.init(title: "截图", style: .done, target: self, action: #selector(snapshot))
            navigationItem.rightBarButtonItem = but
        return but
    }()
}

extension SnapshotViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = "index \(indexPath.row + 1)"
        return cell!
    }
}
