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
        view.backgroundColor = UIColor(named: "BGPrimary")
        navigationItem.title = "위치기반 서비스 이용약관"
        // WKWebView 초기화 및 설정
        webView = WKWebView(frame: self.view.frame)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(webView)
        
        // URL 생성
        if let url = URL(string: "https://likelion.notion.site/a077c16466e1406ea9bb26075130f260") {
            let request = URLRequest(url: url)
            
            // 웹 페이지 로드
            webView.load(request)
        }
        
        NSLayoutConstraint.activate([
             webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
             webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
    }
}
