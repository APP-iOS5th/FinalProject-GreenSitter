//
//  PersonalinfomationViewController.swift
//  GreenSitter
//
//  Created by 차지용 on 8/22/24.
//

import UIKit
import WebKit
class PersonalinfomationViewController: UIViewController {
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        
        // WKWebView 초기화 및 설정
        webView = WKWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        
        // URL 생성
        if let url = URL(string: "https://likelion.notion.site/3fa21fceaa4a4144a2ce16df040a7c88") {
            let request = URLRequest(url: url)
            
            // 웹 페이지 로드
            webView.load(request)
        }
    }
}
