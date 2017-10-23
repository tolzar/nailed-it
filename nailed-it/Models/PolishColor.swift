//
//  PolishColor.swift
//  nailed-it
//
//  Created by Terra Oldham on 10/10/17.
//  Copyright © 2017 Lia Zadoyan. All rights reserved.
//

import UIKit
import Parse

class PolishColor: PFObject, PFSubclassing {
    @NSManaged var displayName: String?
    @NSManaged var hexValue: String?
    @NSManaged var redValue: CGFloat
    @NSManaged var greenValue: CGFloat
    @NSManaged var blueValue: CGFloat
    @NSManaged var brand: String?
    @NSManaged var colorFamily: String?
    @NSManaged var polishType: String?
    @NSManaged var favorited: Bool
    var distanceVector: CGFloat?
    
    
    class func parseClassName() -> String {
        return "PolishColor"
    }
    
    func getUIColor() -> UIColor {
        return UIColor(red: CGFloat(Double(redValue)), green: CGFloat(Double(greenValue)), blue: CGFloat(Double(blueValue)), alpha: 1.0)
    }
    
}

extension UIColor {
    // With a hex value, get the UIColor
    // let gold = UIColor(hexString: "#ffe700ff")
    public convenience init?(hexValue: String) {
        let r, g, b, a: CGFloat
        
        if hexValue.hasPrefix("#") {
            let start = hexValue.index(hexValue.startIndex, offsetBy: 1)
            var hexColor = String(hexValue[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            } else if hexColor.count == 6 {
                hexColor = hexColor + "FF"
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
            
        }
        
        return nil
    }
}

extension UIColor {
    // With a UI Color, get the RGB Components
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
}
