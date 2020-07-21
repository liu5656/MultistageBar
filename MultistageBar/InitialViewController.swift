//
//  InitialViewController.swift
//  MultistageBar
//
//  Created by x on 2020/4/30.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit


enum SegmentStyle: String, CaseIterable {
    static let allValues = SegmentStyle.allCases
    case onlyTitle = "DDLOnlyTitleViewController"
    case header = "DDLHeaderViewController"
    case multistage = "DDLMultistageViewController"
}

class InitialViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = table
    }
    lazy var table: UITableView = {
        let tab = UITableView.init(frame: UIScreen.main.bounds)
        tab.delegate = self
        tab.dataSource = self
        view.addSubview(tab)
        return tab
    }()
    
}

extension InitialViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SegmentStyle.allValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = SegmentStyle.allValues[indexPath.row].rawValue
        return cell!
    }
}

extension InitialViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let namespace = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String,
            let type = NSClassFromString(namespace + "." + SegmentStyle.allValues[indexPath.row].rawValue) as? UIViewController.Type else {return}
        let vc = type.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
