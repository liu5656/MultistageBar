//
//  DataProviderProtocol.swift
//  MultistageBar
//
//  Created by x on 2020/11/19.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

protocol RequestProtocol: NSObjectProtocol {
    
}


protocol NoDataProtocol: NSObjectProtocol {
    func noDataShow() -> UIView?
    func noDataTap(completion: @escaping refreshCompletion)
}


typealias refreshCompletion = (Bool) -> Void
protocol RefreshProtocol: NSObjectProtocol {
    func refresh(type: RefreshType, completion: @escaping refreshCompletion)
}


protocol CellHeightProtocol: NSObjectProtocol {
    var height: CGFloat {get set}
}
protocol CellIdentifyProtocol: NSObjectProtocol {
    var identify: String {get set}
    var cellClass: AnyClass {get set}
}
protocol CellContentProtocol: NSObjectProtocol {
    var processor: ProcessorProtocol? {get set}
    func config(model: Any)
}


protocol ProcessorProtocol: NSObjectProtocol {
    func action(type: ProcessorType)
}
enum ProcessorType {
    case banner(index: Int)
    case didSelected(index: IndexPath)
}


protocol DataProviderProtocol: UITableViewDelegate, UITableViewDataSource, NoDataProtocol, RefreshProtocol {
    var request: RequestProtocol? {get set}
    var processor: ProcessorProtocol? {get set}
    var consumeCells: [String: AnyClass] {get set}  // 记录将要注册的cell
    var registeredCells: [String: AnyClass] {get set}   // 记录已经注册过的cell
}
