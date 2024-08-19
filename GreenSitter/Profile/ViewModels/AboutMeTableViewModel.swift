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
            (cell as! IntroductionTableCell).bodyLabel.text = user?.aboutMe ?? ""
            (cell as! IntroductionTableCell).bodyLabel.textColor = .black

            
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "customTableCell", for: indexPath) as! CustomTableCell
            if indexPath.row == 0 {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "heart.fill")
                (cell as! CustomTableCell).iconImage.tintColor = UIColor(named: "DominentColor")
                (cell as! CustomTableCell).textsLabel.text = "돌봄 후기"
                (cell as! CustomTableCell).textsLabel.textColor = .black
            } else {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "list.bullet.clipboard.fill")
                (cell as! CustomTableCell).iconImage.tintColor = UIColor(named: "DominentColor")
                (cell as! CustomTableCell).textsLabel.text = "돌봄 기록"
                (cell as! CustomTableCell).textsLabel.textColor = .black
            }
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "customTableCell", for: indexPath) as! CustomTableCell
            if indexPath.row == 0 {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "leaf.fill")
                (cell as! CustomTableCell).iconImage.tintColor = UIColor(named: "DominentColor")
                (cell as! CustomTableCell).textsLabel.text = "내가 맡긴 식물"
                (cell as! CustomTableCell).textsLabel.textColor = .black

            } else {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "list.bullet.rectangle.fill")
                (cell as! CustomTableCell).iconImage.tintColor = UIColor(named: "DominentColor")
                (cell as! CustomTableCell).textsLabel.text = "내가 쓴 돌봄 후기"
                (cell as! CustomTableCell).textsLabel.textColor = .black
            }
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "customTableCell", for: indexPath) as! CustomTableCell
            if indexPath.row == 0 {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "rectangle.portrait.and.arrow.forward.fill")
                (cell as! CustomTableCell).iconImage.tintColor = .systemBlue
                (cell as! CustomTableCell).textsLabel.text = "로그아웃"
                (cell as! CustomTableCell).textsLabel.textColor = .systemBlue
            } else {
                (cell as! CustomTableCell).iconImage.image = UIImage(systemName: "person.crop.circle.badge.xmark")
                (cell as! CustomTableCell).iconImage.tintColor = .systemRed
                (cell as! CustomTableCell).textsLabel.text = "회원탈퇴"
                (cell as! CustomTableCell).textsLabel.textColor = .systemRed
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
    
    //MARK: - 셀 높이 조정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }
        else {
            return UITableView.automaticDimension
        }
    }
    
    //MARK: - 헤더뷰를 반환하는 Method
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // "자기소개" 섹션에만 수정 버튼 추가
        if section == 0 {
            let headerView = UIView()
            headerView.backgroundColor = .clear

            let titleLabel = UILabel()
            titleLabel.text = sectionTitle[section]
            titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            let editButton = UIButton(type: .system)
            editButton.setTitle("수정하기", for: .normal)
            editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
            editButton.translatesAutoresizingMaskIntoConstraints = false

            headerView.addSubview(titleLabel)
            headerView.addSubview(editButton)

            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

                editButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                editButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
            ])

            return headerView
        }

        // 다른 섹션의 경우 기본 섹션 헤더로 대체 가능
        let defaultHeaderView = UIView()
        defaultHeaderView.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.text = sectionTitle[section]
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        defaultHeaderView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: defaultHeaderView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: defaultHeaderView.centerYAnchor),
        ])

        return defaultHeaderView
    }
    
    //MARK: - cell 클릭시 발생하는 이벤트
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 {
            let careRecordViewController = CareRecordViewController()
            navigationController?.pushViewController(careRecordViewController, animated: true)
        }
    }
}
