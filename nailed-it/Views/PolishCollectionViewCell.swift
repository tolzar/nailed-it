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
            colorName.text = polishColor?.displayName ?? ""
        }
    }
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorName: UILabel!
    
    
    
}
