//
//  Colors.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/7/24.
//

import UIKit

extension UIColor {
    
    //hex 코드로 UIColor 만들기
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    // Custom Colors
    static var progressGray: UIColor {
        return UIColor(hexCode: "C6C6C6")
    }
    
    static var progressBlue: UIColor {
        return UIColor(hexCode: "3686D0")
    }
    
    static var progressDeactivateGray: UIColor {
        return UIColor(hexCode: "717171")
    }
}
