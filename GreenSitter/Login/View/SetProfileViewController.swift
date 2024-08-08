//
//  TestViewController.swift
//  GreenSitter
//
//  Created by 차지용 on 8/7/24.
//

import UIKit

class SetProfileViewController: UIViewController {
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.text = "testView"
        label.font = UIFont.boldSystemFont(ofSize: 15)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(bodyLabel)
        NSLayoutConstraint.activate([
            bodyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            bodyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
        ])
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
