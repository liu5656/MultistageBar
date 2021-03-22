//
//  MBWebView.swift
//  MultistageBar
//
//  Created by x on 2021/3/22.
//  Copyright © 2021 x. All rights reserved.
//

import WebKit
import UIKit

class MBWebView: WKWebView, MBScriptHandlerDelegate {
    
    enum ScriptName: String {
        case login
    }
    
    private func mb_injection() {
        guard let path = Bundle.main.path(forResource: "bridge", ofType: "js"),
              let content = try? String.init(contentsOfFile: path) else {
            return
        }
        let script = WKUserScript.init(source: content,
                                       injectionTime: WKUserScriptInjectionTime.atDocumentStart,
                                       forMainFrameOnly: true)
        self.configuration.userContentController.addUserScript(script)
    }
    private func mb_registerScript() {
        self.configuration.userContentController.add(scriptHandler, name: ScriptName.login.rawValue)
    }
    
    // MBScriptHandlerDelegate
    func mb_receive(message: WKScriptMessage) {
        guard let type = ScriptName.init(rawValue: message.name)  else {
            return
        }
        mb_handlerReceive(type: type) { [weak self] (res) in
            guard let temp = message.body as? [String: Any],
                  let callbackID = temp["callbackID"] as? String else {
                return
            }
            let res = ["callbackID": callbackID, "data": res].jsonString() ?? ""
            self?.evaluateJavaScript("jsCallIOSCallback('\(res)')", completionHandler: nil)
        }
    }
    func mb_handlerReceive(type: ScriptName, callback: (([String: Any]) -> Void)? = nil) {
        switch type {
        case .login:
            callback?(["jj": "kk"])
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
        backgroundColor = UIColor.white
        mb_injection()
        mb_registerScript()
        navigationDelegate = self
        uiDelegate = self
    }
    
    lazy var scriptHandler: MBScriptHandler = {
        let temp = MBScriptHandler.init()
        temp.delegate = self
        return temp
    }()
}

extension MBWebView: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        completionHandler("abc")
    }
}

extension MBWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}


protocol MBScriptHandlerDelegate: class {
    func mb_receive(message: WKScriptMessage)
}

// 创建此类主要是防止内存泄露
class MBScriptHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: MBScriptHandlerDelegate?
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.mb_receive(message: message)
    }
}
