//
//  DataProvider.swift
//  MultistageBar
//
//  Created by x on 2020/11/19.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class DataProvider<Model: NSObject & CellHeightProtocol & CellIdentifyProtocol>: NSObject, DataProviderProtocol {
    
    init(request: RequestProtocol) {
        self.request = request
    }
    deinit {
        MBLog("")
    }
    var datas: [NSObject & CellHeightProtocol & CellIdentifyProtocol] = []
    
    // data provider protocol
    weak var processor: ProcessorProtocol?
    
    var request: RequestProtocol?
    
    var consumeCells: [String : AnyClass] = [:]
    var registeredCells: [String: AnyClass] = [:]   
    
    // no data
    func noDataShow() -> UIView? {
        guard datas.count == 0 else {
            return nil
        }
        let content = UIView.init(frame: CGRect.init(x: (Screen.width - 300) * 0.5, y: 200, width: 300, height: 50))
        content.backgroundColor = UIColor.blue
        return content
    }
    func noDataTap(completion: @escaping refreshCompletion) {
        
    }
    
    // refresh data
    func refresh(type: RefreshType, completion: @escaping (Bool) -> Void) {
        #warning("1.0 todo 模拟网络请求")
//        DispatchQueue.global().asyncAfter(deadline: .now() + 5) { [unowned self] in
//            self.datas.append(contentsOf: [Model.init(), Model.init()])
//            for item in self.datas {
//                if self.registeredCells.keys.contains(item.identify) == false {
//                    consumeCells[item.identify] = item.cellClass
//                }
//            }
//            completion(true)
//        }
    }
    
    // datasource delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = datas[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: data.identify, for: indexPath)
        if let temp = cell as? CellContentProtocol {
            temp.config(model: data)
            temp.processor = processor
        }
        return cell
    }
    
    // tableview delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        processor?.action(type: .didSelected(index: indexPath))
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return datas[indexPath.row].height
    }
    
}
