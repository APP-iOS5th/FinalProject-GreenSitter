//
//  ChatMessageTableViewCell.swift
//  GreenSitter
//
//  Created by 박지혜 on 8/18/24.
//

import UIKit

class ChatMessageTableViewCell: UITableViewCell {
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .fillTertiary
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(bubbleView)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
            messageLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, constant: 0.75)
            

        ])
    }

}
