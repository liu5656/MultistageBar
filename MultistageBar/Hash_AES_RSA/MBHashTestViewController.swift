//
//  MBHashTestViewController.swift
//  MultistageBar
//
//  Created by x on 2020/10/27.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

// pkcs1 1024
let privateKey = """
-----BEGIN RSA PRIVATE KEY-----
MIICXgIBAAKBgQDS65mDhJUl3z1Y1WsnGDZgzBiX8EBcmA9yVEsu8fiG4YQQIvkx
93RgvUi6A/qTqoOsJOMXdA+kq0SI+ghDlF3Z+NNajbj8tBuhPWaJpriznT6UuaTF
42ABMBPAiFuOy8Kr2rATocm8uN1rSUgS9cVWQufwTpJgDEgGDwbmp0Ru3wIDAQAB
AoGAQwF93347M7Db+GC0jdLvU4kDNyGoEMJuBdApolxUq+Tw43940xrd6e24MQAa
ltbQxdtiGY1Reuq99xYXkgCMX6M8hXdrVJ4omrUgsNBG8CL58O/YBTKzYGkHYn7F
OJNVKb6ttZMn+DowUzEgbTV+USEhoIJXGaJXGHwR1MYTxAECQQDoeSbbueOZrGrF
r1wLvxAasz4RKpdEwc3ffbNKQjXaRO4BCemk8Sh8ZdJtI1xvWpeUfqZ2W8wcRozF
F8y5GpGBAkEA6EQPi9H/ER+sJHSPUi/I3afdsamuN57mYwhPkIi09XQjOCMi2G5m
RbT2C3ZtXZm7ZI2Q0RYd+lNHxXRUNsBwXwJBAJ5qKGukoY8PqfaqB6xNd3jqWcoy
3r/Q3SyFqM5ajf396L22douadj9G13zdktiiwBZFs8OFzHIcNUL9c9lTXIECQQCl
iszhxNxc4gwZN5Jm63Pot5pE5EEtl21xLB05UJZZU1s+yZwuUhFGoYG0DcZJLibn
thZ/T5oyLmU7EHxtQZ9VAkEA1S+7otyHRyK+NYME9/gPnh9mi8QLj93dmTuY2MBG
NWyHBiz5pewGHnMgCYCl+tAzcjypd4nve3KqMb4nS9JU3g==
-----END RSA PRIVATE KEY-----
"""

let publicKey = """
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDS65mDhJUl3z1Y1WsnGDZgzBiX
8EBcmA9yVEsu8fiG4YQQIvkx93RgvUi6A/qTqoOsJOMXdA+kq0SI+ghDlF3Z+NNa
jbj8tBuhPWaJpriznT6UuaTF42ABMBPAiFuOy8Kr2rATocm8uN1rSUgS9cVWQufw
TpJgDEgGDwbmp0Ru3wIDAQAB
-----END PUBLIC KEY-----
"""

class MBHashTestViewController: MBViewController {
    @objc func mb_click() {
        guard let text = originalTF.text, text.count > 0 else {
            shaResultL.text = "请输入待转换的值"
            return
        }
        
        shaResultL.text = "SHA:\n\(Hash.sha(str: text, type: .sha512))" // sha256
        hmacResultL.text = "HMAC:\n\(Hash.hmacSha(str: text, key: "123456", type: .sha512))"
        desResultL.text = "DES:\n\(DES.des(str: "123456", key: "deskey"))"
        aesResultL.text = "AES:\n\(AES.aes(str: "123456", key: "aeskey"))"
        rsaResultL.text = "RSA:\n\(RSA.encrypt(plaintext: "123456", key: RSA.secKey(key: publicKey, isPublic: true)!))"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = originalTF
        _ = signatureB
        _ = shaResultL
        _ = hmacResultL
        _ = desResultL
        _ = aesResultL
        _ = rsaResultL
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if originalTF.isFirstResponder {
            originalTF.resignFirstResponder()
        }
    }
    
    lazy var originalTF: UITextField = {
        let temp = UITextField.init(frame: CGRect.init(x: 10, y: 10, width: Screen.width - 20, height: 50))
        temp.backgroundColor = UIColor.lightGray
        temp.placeholder = "输入待转换内容"
        view.addSubview(temp)
        return temp
    }()
    lazy var signatureB: UIButton = {
        let but = UIButton.init()
        but.backgroundColor = UIColor.black
        but.frame = CGRect.init(x: (Screen.width - 100) * 0.5, y: originalTF.frame.maxY + 5, width: 100, height: 40)
        but.setTitle("开始转换", for: .normal)
        but.addTarget(self, action: #selector(mb_click), for: .touchUpInside)
        view.addSubview(but)
        return but
    }()
    lazy var shaResultL: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 10, y: signatureB.frame.maxY + 5, width: Screen.width - 20, height: 100))
        lab.numberOfLines = 0
        lab.text = "sha:结果"
        lab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lab.textColor = UIColor.black
        view.addSubview(lab)
        return lab
    }()
    lazy var hmacResultL: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 10, y: shaResultL.frame.maxY + 5, width: Screen.width - 20, height: 100))
        lab.numberOfLines = 0
        lab.text = "hmac:结果"
        lab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lab.textColor = UIColor.black
        view.addSubview(lab)
        return lab
    }()
    lazy var desResultL: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 10, y: hmacResultL.frame.maxY + 5, width: Screen.width - 20, height: 40))
        lab.numberOfLines = 0
        lab.text = "des:结果"
        lab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lab.textColor = UIColor.black
        view.addSubview(lab)
        return lab
    }()
    lazy var aesResultL: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 10, y: desResultL.frame.maxY + 5, width: Screen.width - 20, height: 40))
        lab.numberOfLines = 0
        lab.text = "aes:结果"
        lab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lab.textColor = UIColor.black
        view.addSubview(lab)
        return lab
    }()
    lazy var rsaResultL: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 10, y: aesResultL.frame.maxY + 5, width: Screen.width - 20, height: 100))
        lab.numberOfLines = 0
        lab.text = "rsa:结果"
        lab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lab.textColor = UIColor.black
        view.addSubview(lab)
        return lab
    }()
    
    
}
