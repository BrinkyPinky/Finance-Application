//
//  CategoryCollectionViewCell.swift
//  financeapp
//
//  Created by Егор Шилов on 11.10.2022.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var categoryNameLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        self.layer.cornerRadius = self.contentView.frame.width / 5
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.opaqueSeparator.cgColor
        
        let redView = UIView(frame: bounds)
        redView.backgroundColor = .clear
        self.backgroundView = redView

        let blueView = UIView(frame: bounds)
        blueView.backgroundColor = .link
        self.selectedBackgroundView = blueView
    }
}
