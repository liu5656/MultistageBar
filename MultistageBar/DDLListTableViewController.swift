//
//  DDLListTableViewController.swift
//  MultistageBar
//
//  Created by x on 2020/4/27.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class DDLListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            DispatchQueue.main.async {
                self.datasource = ["bbbb"]
                self.tableView.reloadData()
            }
        }
    }
    deinit {
        print("DDLListTableViewController deinit")
    }
    
    var datasource: [String] = ["aaaa"]

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var  cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "reuseIdentifier")
        }
        cell!.textLabel?.text = "\(datasource.first!) \(indexPath.row)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did selected \(indexPath.row)")
    }
    
    
    
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: view.bounds, style: .plain)
        table.contentInsetAdjustmentBehavior = .never
        table.delegate = self
        table.dataSource = self
        view.addSubview(table)
        return table
    }()

}

extension DDLListTableViewController: DDLSegmentContentItemProtocol {
    func ddl_view() -> UIView {
        return self.tableView
    }
}
