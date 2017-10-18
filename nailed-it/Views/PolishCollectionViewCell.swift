//
//  PolishCollectionViewCell.swift
//  nailed-it
//
//  Created by Terra Oldham on 10/11/17.
//  Copyright © 2017 Lia Zadoyan. All rights reserved.
//

import UIKit

class PolishCollectionViewCell: UICollectionViewCell {
    
    var polishColor: PolishColor? {
        didSet {
            colorView.layer.cornerRadius = colorView.frame.size.height / 2
            colorView.clipsToBounds = true
            colorView.backgroundColor = polishColor?.getUIColor()
            whiteView.layer.cornerRadius = whiteView.frame.size.height / 2
            whiteView.backgroundColor = UIColor.white
            colorView.layer.borderWidth = 1
            colorView.layer.borderColor = UIColor.gray.cgColor
            whiteView.layer.borderWidth = 1
            whiteView.layer.borderColor = UIColor.gray.cgColor
            
            colorName.text = polishColor?.displayName ?? ""
            colorBrand.text = polishColor?.brand ?? ""
        }
    }
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorName: UILabel!
    @IBOutlet weak var colorBrand: UILabel!
    @IBOutlet weak var whiteView: UIView!

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
}

