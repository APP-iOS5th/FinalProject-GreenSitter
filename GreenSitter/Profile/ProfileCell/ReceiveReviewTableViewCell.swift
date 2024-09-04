//
//  ReceiveReviewTableViewCell.swift
//  GreenSitter
//
//  Created by 차지용 on 8/21/24.
//

import UIKit

class ReceiveReviewTableViewCell: UITableViewCell {

    lazy var badButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        return button
    }()
    
    lazy var averageButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var goodButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var row1Button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor(named: "BGPrimary")
        return button
    }()
    
    lazy var row2Button: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "BGPrimary")
        return button
    }()
    
    lazy var row3Button: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "BGPrimary")
        return button
    }()
    
    lazy var row4Button: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "BGPrimary")
        return button
    }()
    
    lazy var reviewTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "직접입력하세요"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .white
        return textField
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(badButton)
        contentView.addSubview(averageButton)
        contentView.addSubview(goodButton)
        contentView.addSubview(row1Button)
        contentView.addSubview(row2Button)
        contentView.addSubview(row3Button)
        contentView.addSubview(row4Button)
        contentView.addSubview(reviewTextField)

        NSLayoutConstraint.activate([
            // badButton: 왼쪽 배치
            badButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            badButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            badButton.widthAnchor.constraint(equalToConstant: 100),
            badButton.heightAnchor.constraint(equalToConstant: 100),
            
            // averageButton: 가운데 배치
            averageButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            averageButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            averageButton.widthAnchor.constraint(equalToConstant: 100), 
            averageButton.heightAnchor.constraint(equalToConstant: 100),
            
            // goodButton: 오른쪽 배치
            goodButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            goodButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            goodButton.widthAnchor.constraint(equalToConstant: 100), // width와 height를 동일하게 설정
            goodButton.heightAnchor.constraint(equalToConstant: 100),
            
            row1Button.topAnchor.constraint(equalTo: badButton.bottomAnchor, constant: 20),
            row1Button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            row1Button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            row1Button.widthAnchor.constraint(equalToConstant: 500),
            row1Button.heightAnchor.constraint(equalToConstant: 50),
            
            // row2Button: row1Button 아래에 배치
            row2Button.topAnchor.constraint(equalTo: row1Button.bottomAnchor, constant: 20),
            row2Button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            row2Button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            row2Button.widthAnchor.constraint(equalToConstant: 500),
            row2Button.heightAnchor.constraint(equalToConstant: 50),
            
            // row3Button: row2Button 아래에 배치
            row3Button.topAnchor.constraint(equalTo: row2Button.bottomAnchor, constant: 20),
            row3Button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            row3Button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            row3Button.widthAnchor.constraint(equalToConstant: 500),
            row3Button.heightAnchor.constraint(equalToConstant: 50),
            
            // row4Button: row3Button 아래에 배치
            row4Button.topAnchor.constraint(equalTo: row3Button.bottomAnchor, constant: 20),
            row4Button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            row4Button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            row4Button.widthAnchor.constraint(equalToConstant: 500),
            row4Button.heightAnchor.constraint(equalToConstant: 50),
            
            reviewTextField.topAnchor.constraint(equalTo: row4Button.bottomAnchor, constant: 20),
            reviewTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            reviewTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            reviewTextField.widthAnchor.constraint(equalToConstant: 500),
            reviewTextField.heightAnchor.constraint(equalToConstant: 50),
            
            reviewTextField.topAnchor.constraint(equalTo: row4Button.bottomAnchor, constant: 20),
            reviewTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            reviewTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            reviewTextField.widthAnchor.constraint(equalToConstant: 500),
            reviewTextField.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
