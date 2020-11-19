//
//  WrapTableView.swift
//  MultistageBar
//
//  Created by x on 2020/11/19.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class WrapTableView: UITableView {
    
    enum Operation: CaseIterable {
        static let allValues = Operation.allCases
        case refresh
        case loadMore
        case noData
    }
    
    var operations: [Operation] = Operation.allValues
    weak var dataProvider: DataProviderProtocol? {
        didSet {
            delegate = dataProvider
            dataSource = dataProvider
        }
    }
    
    private lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(noDataTap))
        return tap
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configOperation()
    }
    deinit {
        MBLog("")
    }
    func registerCellAction() {
        guard let temp = dataProvider?.consumeCells else {
            return
        }
        for key in temp.keys {
            if let value = temp[key] {
                register(value, forCellReuseIdentifier: key as String)
                dataProvider?.registeredCells[key] = value
            }
        }
    }
    
    // config operations
    private func configOperation() {
        if operations.contains(.refresh), refreshHeader == nil {
            refreshHeader { [unowned self] in
                self.dataProvider?.refresh(type: .refresh, completion: self.endRefresh(more:))
            }
            beginHeaderRefreshing() // Automatically triggers drop-down refresh
        }
        if operations.contains(.loadMore), refreshFooter == nil {
            refreshFooter { [unowned self] in
                self.dataProvider?.refresh(type: .loadMore, completion: self.endRefresh(more:))
            }
        }
        registerCellAction()
    }
     private func endRefresh(more: Bool) {
        DispatchQueue.main.async { [unowned self] in
            self.endHeaderRefreshing()
            self.endFooterRefreshing(hasMoreData: more)
            checkNoData()
            registerCellAction()
            reloadData()
        }
    }
    
    // no data
    private func checkNoData() {
        guard operations.contains(.noData) else {return}
        if let temp = self.dataProvider?.noDataShow() {
            backgroundView = temp
        }else{
            clearNoDataTip()
        }
    }
    
    public func clearNoDataTip() {
        guard let temp = backgroundView else {
            return
        }
        temp.isHidden = true
        temp.removeFromSuperview()
        backgroundView = nil
    }
    
    @objc private func noDataTap() {
        self.dataProvider?.noDataTap(completion: self.endRefresh(more:))
    }
}
