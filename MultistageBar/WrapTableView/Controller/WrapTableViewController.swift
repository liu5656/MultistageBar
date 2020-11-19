//
//  WrapTableViewController.swift
//  MultistageBar
//
//  Created by x on 2020/11/19.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class WrapTableViewController<Model: NSObject & CellHeightProtocol & CellIdentifyProtocol>: MBViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        provider.datas = [Model(), Model()]
        let temp = Model.init()
        provider.consumeCells = [temp.identify: temp.cellClass]
        table.registerCellAction()
    }
    
    init(request: RequestProtocol) {
        provider = DataProvider<Model>.init(request: request)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var table: WrapTableView = {
        let tab = WrapTableView.init(frame: view.bounds)
        tab.operations = [.refresh, .noData]
        tab.tableFooterView = UIView.init()
        tab.dataProvider = provider
        view.addSubview(tab)
        return tab
    }()
    private let provider: DataProvider<Model>
}



class TempModel: NSObject, CellIdentifyProtocol, CellHeightProtocol {
    var height: CGFloat = 44
    var cellClass: AnyClass = UITableViewCell.classForCoder()
    var identify: String = NSStringFromClass(UITableViewCell.classForCoder())
}

class TempRequest: NSObject, RequestProtocol {
    
}
