//
//  ServiceViewController.swift
//  GreenSitter
//
//  Created by 차지용 on 8/22/24.
//

import UIKit
import WebKit

class ServiceViewController: UIViewController {
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "서비스 이용약관"
        view.backgroundColor = UIColor(named: "BGPrimary")

        // WKWebView 초기화 및 설정
        webView = WKWebView(frame: self.view.frame)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(webView)
        
        // URL 생성
        if let url = URL(string: "https://enchanting-marmoset-e63.notion.site/926e4ab67f774402a7bd5a7c49f3eb67") {
            let request = URLRequest(url: url)
            
            // 웹 페이지 로드
            webView.load(request)
        }
        // 내비게이션 바 백 버튼 숨기기
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""

        
        NSLayoutConstraint.activate([
             webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
             webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
    }
}


