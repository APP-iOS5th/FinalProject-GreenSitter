//
//  LocationServiceViewController.swift
//  GreenSitter
//
//  Created by 차지용 on 8/22/24.
//

import UIKit
import WebKit
class LocationServiceViewController: UIViewController {
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // WKWebView 초기화 및 설정
        webView = WKWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        
        // URL 생성
        if let url = URL(string: "https://likelion.notion.site/a077c16466e1406ea9bb26075130f260") {
            let request = URLRequest(url: url)
            
            // 웹 페이지 로드
            webView.load(request)
        }
    }
}
