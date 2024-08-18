//
//  UILabelExtension.swift
//  GreenSitter
//
//  Created by 김영훈 on 8/13/24.
//

import UIKit

extension UILabel {
    //자간 수정 기능
    func addCharacterSpacing(_ value: Double = -0.03) {
        let kernValue = self.font.pointSize * CGFloat(value)
        guard let text = text, !text.isEmpty else { return }
        let string = NSMutableAttributedString(string: text)
        string.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: string.length - 1))
        attributedText = string
    }
}
