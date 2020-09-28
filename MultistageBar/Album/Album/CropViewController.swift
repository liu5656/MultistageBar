//
//  CropViewController.swift
//  MultistageBar
//
//  Created by x on 2020/9/27.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class CropViewController: UIViewController {
    
    private func cropImage() -> UIImage? {
        let zoomScale = originalImg.size.width / imgIV.frame.size.width

        let leftTopP = CGPoint.init(x: scrollView.contentInset.left, y: scrollView.contentInset.top)
        let rightBottomP = CGPoint.init(x: Screen.width - scrollView.contentInset.left, y: Screen.height - scrollView.contentInset.bottom)

        let imgLeftTopP = self.view.convert(leftTopP, to: coordinationV)
        let imgRightBottomP = self.view.convert(rightBottomP, to: coordinationV)
        
        let cropFrame = CGRect.init(origin: CGPoint.init(x: imgLeftTopP.x * zoomScale,
                                                         y: imgLeftTopP.y * zoomScale),
                                    size: CGSize.init(width: (imgRightBottomP.x - imgLeftTopP.x) * zoomScale,
                                                      height: (imgRightBottomP.y - imgLeftTopP.y) * zoomScale))
        
        guard let cropedImg = originalImg.cgImage?.cropping(to: cropFrame) else {return nil}
        let temp = UIImage.init(cgImage: cropedImg)
        return temp
    }
    private func firstGlance() {
        let imgSize: CGSize
        if cropRatio > originalRatio {
            imgSize = CGSize.init(width: cropSize.width, height: cropSize.width / originalRatio)
        }else{
            imgSize = CGSize.init(width: cropSize.width * originalRatio, height: cropSize.height)
        }
        imgIV.frame = CGRect.init(origin: .zero, size: imgSize)
        coordinationV.frame = imgIV.frame
        let horizontalMarge: CGFloat = CGFloat(Int((Screen.width - cropSize.width) * 0.5))
        let verticalMarge: CGFloat = CGFloat(Int((Screen.height - cropSize.height) * 0.5))
        scrollView.contentInset = UIEdgeInsets.init(top: verticalMarge, left: horizontalMarge, bottom: verticalMarge, right: horizontalMarge)
        scrollView.contentSize = imgSize
        scrollView.setZoomScale(1, animated: true)
    }
    private func hollowLayer() {
        let bgLayer = CAShapeLayer.init()
        bgLayer.frame = overlayV.bounds
        
        let bgPath = UIBezierPath.init(rect: bgLayer.bounds)
        bgPath.append(UIBezierPath.init(rect: CGRect.init(x: (Screen.width - cropSize.width) * 0.5, y: (Screen.height - cropSize.height) * 0.5, width: cropSize.width, height: cropSize.height)).reversing())
        
        bgLayer.path = bgPath.cgPath
        overlayV.layer.mask = bgLayer
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func finish() {
        completion?(cropImage())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(coordinationV)
        scrollView.addSubview(imgIV)
        imgIV.image = originalImg
        _ = cancelB
        _ = certainB
        hollowLayer()
        firstGlance()
    }
    init(img: UIImage) {
        self.originalImg = img
        self.originalRatio = img.size.width / img.size.height
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    var completion: ((UIImage?) -> Void)?
    let originalImg: UIImage
    let originalRatio: CGFloat
    var cropSize: CGSize = CGSize.init(width: 300, height: 300)
    var cropRatio: CGFloat {
        return cropSize.width / cropSize.height
    }
    lazy var scrollView: UIScrollView = {
        let scr = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: Screen.width, height: Screen.height))
        scr.contentInsetAdjustmentBehavior = .never
        scr.scrollsToTop = false
        scr.maximumZoomScale = 3
        scr.minimumZoomScale = 1
        scr.backgroundColor = UIColor.white
        scr.delegate = self
        view.addSubview(scr)
        return scr
    }()
    lazy var imgIV: UIImageView = {
        let img = UIImageView.init()
        img.contentMode = UIView.ContentMode.scaleAspectFill
        return img
    }()
    lazy var coordinationV: UIView = {  // 仅仅用来确定imgIV的frame,为后面的convert方法做准备,
        let vie = UIView.init()
        return vie
    }()
    lazy var cancelB: UIButton = {
        let but = UIButton.init(type: .custom)
        but.frame = CGRect.init(x: 20, y: Screen.height - 50, width: 50, height: 30)
        but.setTitleColor(UIColor.black, for: .normal)
        but.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        but.setTitle("取消", for: .normal)
        but.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        view.addSubview(but)
        return but
    }()
    lazy var certainB: UIButton = {
        let but = UIButton.init(type: .custom)
        but.frame = CGRect.init(x: Screen.width - 70, y: Screen.height - 50, width: 50, height: 30)
        but.setTitleColor(UIColor.black, for: .normal)
        but.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        but.setTitle("确定", for: .normal)
        but.addTarget(self, action: #selector(finish), for: .touchUpInside)
        view.addSubview(but)
        return but
    }()
    lazy var overlayV: UIView = {
        let vie = UIView.init(frame: Screen.bounds)
        vie.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        vie.isUserInteractionEnabled = false
        view.addSubview(vie)
        return vie
    }()
}

extension CropViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgIV
    }
    // 缩放后仅仅是通过transform来改变缩放容器,容器的bound值不会变,改变的只是容器size和center
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        coordinationV.frame = imgIV.frame
        coordinationV.center = imgIV.center
    }
}
