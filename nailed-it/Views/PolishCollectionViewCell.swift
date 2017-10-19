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
            colorView.backgroundColor = polishColor?.getUIColor()
            whiteView.layer.cornerRadius = whiteView.frame.size.height / 2
            whiteView.clipsToBounds = true
            
            colorView.layer.cornerRadius = 20
            colorView.clipsToBounds = true

            whiteView.backgroundColor = UIColor.white
            colorView.layer.borderWidth = 1
            colorView.layer.borderColor = UIColor.gray.cgColor
            whiteView.layer.borderWidth = 1
            whiteView.layer.borderColor = UIColor.gray.cgColor
            
            layer.masksToBounds = true
            
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

