//
//  ProfileViewModel.swift
//  GreenSitter
//
//  Created by 차지용 on 8/13/24.
//

import UIKit

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProfileTableViewCell
        let cornerRadius: CGFloat = 10
        var maskedCorners: CACornerMask = []
        
        if indexPath.row == 0 {
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.titleLabel.text = "이름"
                cell.bodyLabel.text = users?.nickname
                cell.bodyLabel.textColor = .black
                cell.actionButton.isHidden = false
                cell.actionButton.setTitle("변경", for: .normal)
                cell.actionButton.addTarget(self, action: #selector(changeNicknameButtonTap), for: .touchUpInside)
                cell.setIconHidden(true)
            }
            else if indexPath.row == 1 {
                cell.titleLabel.text = "사는 곳"
                cell.bodyLabel.text = users?.location.address
                cell.actionButton.isHidden = false
                cell.actionButton.setTitle("변경", for: .normal)
                cell.actionButton.addTarget(self, action: #selector(changeLocationButtonTap), for: .touchUpInside)
                cell.setIconHidden(true)
            }
            else if indexPath.row == 2 {
                cell.titleLabel.text = nil
                cell.bodyLabel.text = "레벨"
                cell.iconImageView.image = UIImage(named: "로고7")
                cell.actionButton.setImage(UIImage(systemName: "exclamationmark.circle"), for: .normal)
                cell.actionButton.addTarget(self, action: #selector(inpoButtonTap), for: .touchUpInside)
                cell.actionButton.isHidden = false
                cell.iconImageView.isHidden = false
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.titleLabel.text = nil
                cell.bodyLabel.text = "내가 쓴 돌봄 후기"
                cell.iconImageView.image = UIImage(systemName: "pencil")
                cell.actionButton.isHidden = true
                cell.iconImageView.isHidden = false
            }
            else if indexPath.row == 1 {
                cell.titleLabel.text = nil
                cell.bodyLabel.text = "로그아웃"
                cell.bodyLabel.textColor = UIColor.systemBlue
                cell.iconImageView.image = UIImage(systemName: "power")
                cell.iconImageView.tintColor = UIColor.systemBlue
                cell.actionButton.isHidden = true
                cell.iconImageView.isHidden = false
            }
            else if indexPath.row == 2 {
                cell.titleLabel.text = nil
                cell.bodyLabel.text = "탈퇴하기"
                cell.bodyLabel.textColor = UIColor.red
                cell.iconImageView.image = UIImage(systemName: "person.crop.circle.badge.xmark")
                cell.iconImageView.tintColor = UIColor.red
                cell.actionButton.isHidden = true
                cell.iconImageView.isHidden = false
            }
        }
        
        let isFirstRow = indexPath.row == 0
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if isFirstRow && isLastRow {
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirstRow {
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastRow {
            maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        cell.layer.cornerRadius = cornerRadius
        cell.layer.maskedCorners = maskedCorners
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (1, 1):
            logout()
        case (1, 2):
            accountDeletion()
        default:
            break
        }
    }
}

