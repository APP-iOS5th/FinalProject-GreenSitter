//
//  ReviewViewModel.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit

extension ReviewViewController {
    
    //MARK: - 나쁨, 보통, 좋음 리뷰
    @objc func selectButtonTap(_ sender: UIButton) {
        if let previousButton = selectedRatingButton {
            previousButton.layer.borderColor = UIColor.clear.cgColor
            previousButton.layer.borderWidth = 0
        }
        
        // 선택된 버튼에 테두리 설정
        sender.layer.borderColor = UIColor(named: "ComplementaryColor")?.cgColor ?? UIColor.blue.cgColor
        sender.layer.borderWidth = 2.0 
        sender.isSelected = true
        selectedRatingButton = sender
        
        if sender == (tableView.cellForRow(at: IndexPath(row: 0, section: 1))as? ReviewSendTableViewCell)?.badButton {
            print("Bad selected")
        }
        else if sender == (tableView.cellForRow(at: IndexPath(row: 0, section: 1))as? ReviewSendTableViewCell)?.averageButton {
            print("Average selected")
        } 
        else if sender == (tableView.cellForRow(at: IndexPath(row: 0, section: 1))as? ReviewSendTableViewCell)?.goodButton {
            print("Good selected")
        }
    }
    //MARK: - 텍스트 리뷰
    @objc func slectTextButtonTap(_ sender: UIButton) {
        let isSelected = sender.isSelected
        
        if isSelected {
            // 선택 해제시 기본 상태로 복구
            sender.backgroundColor = UIColor.white
        }
        else {
            sender.backgroundColor = UIColor(named: "ComplementaryColor")
        }
        sender.isSelected = !isSelected
    }
    
    //MARK: - 완료
    @objc func completeButtonTap() {
        
    }
}
