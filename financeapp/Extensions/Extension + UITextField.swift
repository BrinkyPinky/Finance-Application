//
//  Extension + UITextField.swift
//  financeapp
//
//  Created by Егор Шилов on 11.10.2022.
//

import UIKit

extension UITextField {
    func setUnderLine() {
        borderStyle = .none
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = UIColor.opaqueSeparator.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
