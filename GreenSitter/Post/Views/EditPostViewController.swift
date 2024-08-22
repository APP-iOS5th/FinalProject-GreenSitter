//
//  EditPostViewController.swift
//  GreenSitter
//
//  Created by 조아라 on 8/20/24.
//

import Foundation
import UIKit

class EditPostViewController: UIViewController {
    
    private let post: Post
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .bgPrimary
        // TODO: 닫기 버튼
    }
}
