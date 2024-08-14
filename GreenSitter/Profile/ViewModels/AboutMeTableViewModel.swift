//
//  AboutMeTableViewModel.swift
//  GreenSitter
//
//  Created by 차지용 on 8/14/24.
//

import UIKit

extension AboutMeViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }
    
    //MARK: - 섹션의 수
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    //MARK: - 섹션의 행수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 2
        case 3:
            return 2
        case 4:
            return 4
        default:
            return 0
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "introductionTableCell", for: indexPath) as! IntroductionTableCell
            (cell as! IntroductionTableCell).bodyLabel.text = "자기소개"
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "customTableCell", for: indexPath) as! CustomTableCell
            if indexPath.row == 0 {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "heart.fill")
                (cell as! CustomTableCell).textsLabel.text = "돌봄 후기"
            } else {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "list.bullet.clipboard.fill")
                (cell as! CustomTableCell).textsLabel.text = "돌봄 기록"
            }
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "customTableCell", for: indexPath) as! CustomTableCell
            if indexPath.row == 0 {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "leaf.fill")
                (cell as! CustomTableCell).textsLabel.text = "내가 맡긴 식물"
            } else {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "list.bullet.rectangle.fill")
                (cell as! CustomTableCell).textsLabel.text = "내가 쓴 돌봄 후기"
            }
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "customTableCell", for: indexPath) as! CustomTableCell
            if indexPath.row == 0 {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "heart.fill")
                (cell as! CustomTableCell).iconImage.tintColor = .systemRed
                (cell as! CustomTableCell).textsLabel.text = "회원 탈퇴"
                (cell as! CustomTableCell).textsLabel.textColor = .systemRed
            } else {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "list.bullet.clipboard.fill")
                (cell as! CustomTableCell).iconImage.tintColor = .systemBlue
                (cell as! CustomTableCell).textsLabel.text = "로그아웃"
                (cell as! CustomTableCell).textsLabel.textColor = .systemBlue
            }
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "informationTableCell", for: indexPath) as! InformationTableCell
            switch indexPath.row {
            case 0:
                (cell as! InformationTableCell).infoLabel.text = "서비스 이용약관"
            case 1:
                (cell as! InformationTableCell).infoLabel.text = "개인정보 처리 방침"
            case 2:
                (cell as! InformationTableCell).infoLabel.text = "비즈니스 개인정보 처리방침"
            case 3:
                (cell as! InformationTableCell).infoLabel.text = "위치기반서비스 이용약관"
            default:
                (cell as! InformationTableCell).infoLabel.text = ""
            }
        default:
            cell = UITableViewCell()
        }
        
        // 셀의 모서리와 테두리 설정
        configureCellAppearance(cell, at: indexPath, in: tableView)
        
        return cell
    }

    
    func configureCellAppearance(_ cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
        let cornerRadius: CGFloat = 10.0
        var maskedCorners: CACornerMask = []
        
        let isFirstRow = indexPath.row == 0
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if isFirstRow && isLastRow {
            // 첫 번째와 마지막 셀의 모서리만 둥글게
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirstRow {
            // 첫 번째 셀의 상단 모서리만 둥글게
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastRow {
            // 마지막 셀의 하단 모서리만 둥글게
            maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        // 셀의 외관 설정
        cell.contentView.layer.cornerRadius = cornerRadius
        cell.contentView.layer.maskedCorners = maskedCorners
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.backgroundColor = .white
    }

}
