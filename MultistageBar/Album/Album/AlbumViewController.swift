//
//  AlbumViewController.swift
//  WeexDemo
//
//  Created by lj on 2019/3/1.
//  Copyright © 2019 taobao. All rights reserved.
//

import UIKit
import Photos

class AlbumViewController: UIViewController {
    @objc func certainAction() {
        if allowCrop, let asset = selectedAssets.first {
            let size = CGSize.init(width: 960, height: 960)
            AssetTools.image(asset: asset, size: size) { (img, isOriginal, err) in
                if isOriginal, let temp = img {
                    let vc = CropViewController.init(img: temp)
                    vc.completion = { [unowned self] img in
                        self.cropResult?(img)
                        self.dismiss(animated: true, completion: nil)
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if let temp = err {
                    if temp.code == 81 {
                        MBLog("请求超时!")
                    }else if 82 == temp.code {
                        MBLog("网络错误,请求检查网络")
                    }else if 1005 == temp.code {
                        MBLog("磁盘可用空间不足,无法获取此照片的更高质量版本,您可以在设置中管理存储空间")
                    }else{
                        MBLog("其他错误: \(temp.description)")
                    }
                }
            }
        }else{
            if selectedAssets.count > 0, let callback = finishCallback {
                callback(selectedAssets)
            }
            backAction()
        }
    }
    @objc func backAction() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "相册"
        certainB.isEnabled = false
        _ = backB
        view.addSubview(gridCV)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    var allowCrop: Bool = false
    var maxNumber: Int = 9
    var finishCallback: (([AssetModel]) -> Void)?
    var cropResult: ((UIImage?) -> Void)?
    var selectedAssets: [AssetModel] = []
    let assetManager = PHCachingImageManager.default()
    let photoCellIdentify = "photoCellIdentify"
    lazy var photos: [AssetModel] = {
        var arr: [AssetModel] = []
        for i in 0..<self.fetchResults.count {
            let asset = fetchResults.object(at: i)
            if asset.mediaType == .image {
                let photo = AssetModel.init(asset: asset, index: arr.count)
                photo.localIdentifier = asset.localIdentifier
                photo.asset = asset
                if selectedAssets.contains(where: {$0.localIdentifier == asset.localIdentifier}){
                    photo.isSelected = true
                }
                arr.append(photo)
            }
        }
        return arr
    }()
    lazy var fetchResults: PHFetchResult<PHAsset> = {
        let option = PHFetchOptions.init()
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResults = PHAsset.fetchAssets(with: option)
        return fetchResults
    }()
    lazy var certainB: UIButton = {
        let b = UIButton.init(type: .custom)
        b.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        b.setTitle("确定", for: .normal)
        b.setTitleColor(UIColor.lightGray, for: .disabled)
        b.setTitleColor(UIColor.black, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        b.addTarget(self, action: #selector(certainAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: b)
        return b
    }()
    lazy var backB: UIButton = {
        let b = UIButton.init(type: .custom)
        b.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        b.setTitle("取消", for: .normal)
        b.setTitleColor(UIColor.black, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        b.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: b)
        return b
    }()
    lazy var gridCV: UICollectionView = {
        let lineSpacing = 3.0
        let numPerRow = 3.0
        let itemW = ((Double(UIScreen.main.bounds.width) - (numPerRow - 1) * lineSpacing) / Double(numPerRow))
        
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        layout.itemSize = CGSize.init(width: itemW, height: itemW)
        
        let navBarHeight =  UIApplication.shared.statusBarFrame.height + 44
        let height = UIScreen.main.bounds.height - navBarHeight
        let cv = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height), collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(AlbumImageCell.classForCoder(), forCellWithReuseIdentifier: photoCellIdentify)
        return cv
    }()
}

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        if selectedAssets.count < maxNumber || photo.isSelected {
            selectedAsset(model: photo)
        }else{
            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentify, for: indexPath) as? AlbumImageCell else {return UICollectionViewCell()}
        cell.delegate = self
        cell.lobo_config(model: photos[indexPath.row], manager: assetManager)
        return cell
    }
}

extension AlbumViewController: AlbumImageCellDelegate {
    func selectedAsset(model: AssetModel) {
        if model.asset.mediaType == .image{
            var indexs: [IndexPath] = [IndexPath.init(row: model.index, section: 0)]
            if model.isSelected {   // 取消选中
                model.isSelected = false
                selectedAssets = selectedAssets.filter({$0.localIdentifier != model.localIdentifier})
            }else if maxNumber == 1 {
                if let temp = selectedAssets.first {
                    temp.isSelected = false
                    indexs.append(IndexPath.init(row: temp.index, section: 0))
                }
                model.isSelected = true
                selectedAssets = [model]
            }else if maxNumber > 1, selectedAssets.count < maxNumber {
                model.isSelected = true
                selectedAssets.append(model)
            }else{
                indexs = []
                MBLog(" --- --- --- --- --- 超出选择数量")
            }
            gridCV.reloadItems(at: indexs)
            certainB.isEnabled = selectedAssets.count == 0 ? false : true
        }
    }
}
