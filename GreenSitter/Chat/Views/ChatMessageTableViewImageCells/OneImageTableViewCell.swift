//
//  OneImageTableViewCell.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/26/24.
//

import UIKit

protocol ChatMessageTableViewImageCellDelegate: AnyObject {
    func imageViewTapped(images: [UIImage], index: Int)
}

class OneImageTableViewCell: UITableViewCell {
    weak var delegate: ChatMessageTableViewImageCellDelegate?
    
    private let firestorageManager = FirestorageManager()
    
    var isIncoming: Bool = false {
        didSet {
            setupUI()
        }
    }
    
    var isRead: Bool = false {
        didSet {
            isReadLabel.text = isRead ? "" : "읽지 않음"
        }
    }
    
    var imageSize: CGFloat?
        
    var imageURLs = [URL]()
    
    private lazy var firstImageView: UIImageView = {
       let firstImageView = UIImageView()
        firstImageView.layer.cornerRadius = 10
        firstImageView.backgroundColor = .white
        firstImageView.clipsToBounds = true
        firstImageView.contentMode = .scaleAspectFit
        firstImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        firstImageView.isUserInteractionEnabled = true
        firstImageView.addGestureRecognizer(tapGesture)
        return firstImageView
    }()
    
    lazy var bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo7")
        
        return imageView
    }()
    
    // TODO: - 오전 12시에 날짜 출력
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .fillTertiary
        label.layer.cornerRadius = label.frame.size.height / 2
        label.layer.masksToBounds = true
        label.text = "2024년 8월 19일"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "오후 1:43"
        label.textColor = .labelsSecondary
        label.font = UIFont.systemFont(ofSize: 11)
        
        return label
    }()
    
    lazy var isReadLabel: UILabel = {
        let label = UILabel()
        label.textColor = .complementary
        label.font = UIFont.systemFont(ofSize: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layoutIfNeeded()

        let bubbleViewWidth = bubbleView.bounds.width
        
        if imageSize == nil {
            imageSize = bubbleViewWidth
        }
        
        guard let imageSize = imageSize else { return }
        NSLayoutConstraint.activate([
            firstImageView.heightAnchor.constraint(equalToConstant: imageSize),
            firstImageView.widthAnchor.constraint(equalToConstant: imageSize),
        ])
        
        var imageViews = [firstImageView]

        for (index, imageURL) in imageURLs.enumerated() {
            if index < imageViews.count {
                firestorageManager.loadImage(imageURL: imageURL, imageSize: imageSize, imageView: &imageViews[index])
            }
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // 제약조건 재설정을 위한 기존 제약조건 제거
        NSLayoutConstraint.deactivate(contentView.constraints)
        // profileImageView와 isReadLabel 제거
        profileImageView.removeFromSuperview()
        isReadLabel.removeFromSuperview()
        
        bubbleView.addSubview(firstImageView)
        
        contentView.addSubview(bubbleView)
        contentView.addSubview(timeLabel)
        
        if isIncoming {
            contentView.addSubview(profileImageView)
            
            NSLayoutConstraint.activate([
                profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                profileImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                profileImageView.widthAnchor.constraint(equalToConstant: 52),
                profileImageView.heightAnchor.constraint(equalToConstant: 52),
                
                bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                bubbleView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
                
                timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5),
                timeLabel.leadingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: 5),
                timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -100),
                timeLabel.widthAnchor.constraint(equalToConstant: 45),
                
                firstImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                firstImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
                firstImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
                firstImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
                firstImageView.heightAnchor.constraint(equalTo: firstImageView.widthAnchor),
            ])
        } else {
            contentView.addSubview(isReadLabel)
            
            NSLayoutConstraint.activate([
                isReadLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5),
                isReadLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 100),
                isReadLabel.widthAnchor.constraint(equalToConstant: 41.333333333333336),

                timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5),
                timeLabel.leadingAnchor.constraint(equalTo: isReadLabel.trailingAnchor, constant: 5),
                timeLabel.widthAnchor.constraint(equalToConstant: 45),
                
                bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                bubbleView.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 5),
                bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                
                firstImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                firstImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
                firstImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
                firstImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
                firstImageView.heightAnchor.constraint(equalTo: firstImageView.widthAnchor),
                
            ])
        }
    }
    
    @objc
    private func handleImageTap(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView, let image = imageView.image else { return }
        
        var images = [UIImage]()
        
        let imageViews = [firstImageView]
        for imageView in imageViews {
            if let image = imageView.image {
                images.append(image)
            }
        }
        
        if let index = imageViews.firstIndex(of: imageView) {
            delegate?.imageViewTapped(images: images, index: index)
        }
    }
}

