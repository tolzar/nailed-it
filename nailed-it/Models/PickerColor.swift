//
//  PickerColor.swift
//  nailed-it
//
//  Created by Terra Oldham on 10/10/17.
//  Copyright © 2017 Lia Zadoyan. All rights reserved.
//

import UIKit
import Parse

class PickerColor: PFObject, PFSubclassing {
    @NSManaged var hexValue: String?
    @NSManaged var redValue: Int
    @NSManaged var greenValue: Int
    @NSManaged var blueValue: Int
    @NSManaged var favorited: Bool
    @NSManaged var displayName: String?
    
    
    class func parseClassName() -> String {
        return "PickerColor"
    }
    
    func getUIColor() -> UIColor {
        return UIColor(red: CGFloat(Double(redValue)/255.0), green: CGFloat(Double(greenValue)/255.0), blue: CGFloat(Double(blueValue)/255.0), alpha: 1.0)
    }
}
