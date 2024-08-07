//
//  LoginViewController.swift
//  GreenSitter
//
//  Created by Jiyong Cha on 8/7/24.
//

import UIKit

class LoginViewController: UIViewController {
    
    lazy var textLabel: UILabel = {
       let label = UILabel()
        label.text = "새싹 돌봄이"
        label.font = .systemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(textLabel)
        showToast(withDuration: 1, delay: 4)
    }
    
    //MARK: - ToastMessage
    func showToast(withDuration: Double, delay: Double) {
        let toastLabelWidth: CGFloat = 280
        let toastLabelHeight: CGFloat = 80
        
        // UIView 생성
        let toastView = UIView(frame: CGRect(x: (self.view.frame.size.width - toastLabelWidth) / 2, y: 75, width: toastLabelWidth, height: toastLabelHeight))
        toastView.backgroundColor = UIColor.white
        toastView.alpha = 1.0
        toastView.layer.cornerRadius = 25
        toastView.clipsToBounds = true
        toastView.layer.borderColor = UIColor.black.cgColor
        toastView.layer.borderWidth = 1
        
        //쉐도우 설정
        toastView.layer.shadowColor = UIColor.gray.cgColor
        toastView.layer.shadowOpacity = 0.5 //투명도
        toastView.layer.shadowOffset = CGSize(width: 4, height: 4) //그림자 위치
        toastView.layer.shadowRadius = 10
        
        // UIImageView 생성 및 설정
        let image = UIImageView(image: UIImage(named: "로고7"))
        image.layer.cornerRadius = 25
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 50).isActive = true  // 이미지의 크기를 설정.
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        // UILabel 생성 및 설정
        let labelOne = UILabel()
        labelOne.text = "로그인이 권한이 필요한 기능입니다"
        labelOne.textColor = .black
        labelOne.font = UIFont.systemFont(ofSize: 13)
        labelOne.textAlignment = .left
        labelOne.translatesAutoresizingMaskIntoConstraints = false
        
        let labelTwo = UILabel()
        labelTwo.text = "로그인화면으로 이동합니다"
        labelTwo.textColor = .black
        labelTwo.font = UIFont.systemFont(ofSize: 11)
        labelTwo.textAlignment = .left
        labelTwo.translatesAutoresizingMaskIntoConstraints = false
        
        // StackView 생성 및 설정 (Vertical Stack)
        let labelStackView = UIStackView(arrangedSubviews: [labelOne, labelTwo])
        labelStackView.axis = .vertical
        labelStackView.alignment = .leading
        labelStackView.spacing = 5
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // StackView 생성 및 설정 (Horizontal Stack)
        let mainStackView = UIStackView(arrangedSubviews: [image, labelStackView])
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center
        mainStackView.spacing = 10
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        toastView.addSubview(mainStackView)
        
        // Auto Layout 설정
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -10),
            mainStackView.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 10),
            mainStackView.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -10)
        ])
        
        self.view.addSubview(toastView)
        
        
        UIView.animate(withDuration: withDuration, delay: delay, options: .curveEaseOut, animations: {
            toastView.alpha = 0.0
        }, completion: {(isCompleted) in
            toastView.removeFromSuperview()
        })
    }


}
