//
//  MBHashTestViewController.swift
//  MultistageBar
//
//  Created by x on 2020/10/27.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class MBHashTestViewController: MBViewController {
    @objc func mb_click() {
        guard let text = originalTF.text, text.count > 0 else {
            shaResultL.text = "请输入待转换的值"
            return
        }
        
        shaResultL.text = Hash.sha(str: text, type: .sha512) // sha256
        hmacResultL.text = Hash.hmacSha(str: text, key: "123456", type: .sha512)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = originalTF
        _ = signatureB
        _ = shaTL
        _ = shaResultL
        _ = hmacL
        _ = hmacResultL
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if originalTF.isFirstResponder {
            originalTF.resignFirstResponder()
        }
    }
    
    lazy var originalTF: UITextField = {
        let temp = UITextField.init(frame: CGRect.init(x: 10, y: 20, width: Screen.width - 20, height: 50))
        temp.backgroundColor = UIColor.lightGray
        temp.placeholder = "输入待转换内容"
        view.addSubview(temp)
        return temp
    }()
    lazy var signatureB: UIButton = {
        let but = UIButton.init()
        but.backgroundColor = UIColor.black
        but.frame = CGRect.init(x: (Screen.width - 100) * 0.5, y: originalTF.frame.maxY + 10, width: 100, height: 40)
        but.setTitle("开始转换", for: .normal)
        but.addTarget(self, action: #selector(mb_click), for: .touchUpInside)
        view.addSubview(but)
        return but
    }()
    
    lazy var shaTL: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 10, y: signatureB.frame.maxY + 20, width: 60, height: 20))
        lab.text = "sha"
        lab.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lab.textColor = UIColor.black
        view.addSubview(lab)
        return lab
    }()
    lazy var shaResultL: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 10, y: shaTL.frame.maxY + 10, width: Screen.width - 20, height: 100))
        lab.numberOfLines = 0
        lab.text = "结果"
        lab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lab.textColor = UIColor.black
        view.addSubview(lab)
        return lab
    }()
    
    lazy var hmacL: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 10, y: shaResultL.frame.maxY + 20, width: 60, height: 20))
        lab.text = "hmac"
        lab.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lab.textColor = UIColor.black
        view.addSubview(lab)
        return lab
    }()
    lazy var hmacResultL: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 10, y: hmacL.frame.maxY + 10, width: Screen.width - 20, height: 100))
        lab.numberOfLines = 0
        lab.text = "结果"
        lab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lab.textColor = UIColor.black
        view.addSubview(lab)
        return lab
    }()
    
    
}
