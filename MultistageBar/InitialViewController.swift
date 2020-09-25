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
    case signInApple = "SignInAppleViewController"
    case jsonMap = "JSONViewController"
    case progress = "ProgressViewController"
    case alum = "AlbumTestViewController"
}




//首先定义一个结构体Person用来表示数据Model
struct Person: Codable {
    var name: String?
    var age: Int?
    var sex: String?
}
 




class InitialViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        _ = table
        table.beginHeaderRefreshing()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    lazy var table: UITableView = {
        let tab = UITableView.init(frame: CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64))
//        tab.contentInset = UIEdgeInsets.init(top: -10, left: 0, bottom: 0, right: 10)
        tab.delegate = self
        tab.dataSource = self
        tab.tableFooterView = UIView.init()
        view.addSubview(tab)
        tab.refreshHeader {
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
                DispatchQueue.main.async {
                    tab.endHeaderRefreshing()
                }
            }
        }
        tab.refreshFooter {
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
                DispatchQueue.main.async {
                    tab.endFooterRefreshing(hasMoreData: true)
                }
            }
        }
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
