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

extension UIView {
    
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }
    
    
    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.2,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
}

