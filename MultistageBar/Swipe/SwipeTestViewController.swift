//
//  SwipeTestViewController.swift
//  MultistageBar
//
//  Created by x on 2020/9/29.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class SwipeTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        swipeTV.delegate = self
        swipeTV.datasource = self
        swipeTV.headerView = headerView
        swipeTV.headerBar = headerBar
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func swipe(_ swipe: SwipeTableView, column: Int) -> UIScrollView {
        if column % 2 == 0 {
            let table = UITableView.init(frame: swipe.bounds)
            table.delegate = swipe
            table.dataSource = swipe
            table.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: cellIdentify)
            return table
        }else{
            let layout = UICollectionViewFlowLayout.init()
            let width = (Screen.width - 12 * 3) * 0.5
            layout.itemSize = CGSize.init(width: width, height: width * 1.18)
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 12
            layout.minimumInteritemSpacing = 12
            
            let col = UICollectionView.init(frame: swipe.bounds, collectionViewLayout: layout)
            col.contentInset = UIEdgeInsets.init(top: 13, left: 12, bottom: 12, right: 12)
            col.delegate = swipe
            col.dataSource = swipe
            col.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: cellIdentify)
            return col
        }
    }
    
    let cellIdentify = "cellIdentify"
    private lazy var headerView: UIView = {
        let bgV = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: 80))
        bgV.backgroundColor = UIColor.red
        return bgV
    }()
    private lazy var headerBar: UIView = {
        let bar = UIView.init(frame: CGRect.init(x: 0, y: headerView.frame.maxY, width: Screen.width, height: 80))
        bar.backgroundColor = UIColor.blue;
        return bar
    }()
    lazy var swipeTV: SwipeTableView = {
        let v = SwipeTableView.init(frame: Screen.bounds)
        v.barTopInset = 60
        view.addSubview(v)
        return v
    }()
}

extension SwipeTestViewController: SwipeTableViewDelegate {
    func swipeTableView(_ tableView: UITableView, column: Int, heightForRowAt index: IndexPath) -> CGFloat {
        return 44
    }
}

extension SwipeTestViewController: SwipeTableViewDataSource {
    func swipeTableView(_ swipeTableView: SwipeTableView, mainColumnInSection section: Int) -> Int {
        return 7
    }
    func swipeTableView(_ swipeTableView: SwipeTableView, columnIndexPath index: IndexPath) -> UIView {
        return swipe(swipeTableView, column: index.row)
    }
    
    func swipeTableView(_ tableView: UITableView, column: Int, numberOfCellInSection section: Int) -> Int {
        return 100
    }
    func swipeTableView(_ tableView: UITableView, column: Int, rowAtIndexPath index: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentify, for: index)
        cell.textLabel?.text = "table \(index.row)"
        return cell
    }
    
    func swipeTableView(_ collectionView: UICollectionView, column: Int, numberOfItemInSection section: Int) -> Int {
        return 30
    }
    func swipeTableView(_ collectionView: UICollectionView, column: Int, itemAtIndexPath index: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentify, for: index)
        cell.backgroundColor = UIColor.purple
        return cell
    }
    
}
