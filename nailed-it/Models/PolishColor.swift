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
    @NSManaged var redValue: Int
    @NSManaged var greenValue: Int
    @NSManaged var blueValue: Int
    @NSManaged var brand: String?
    @NSManaged var colorFamily: String?
    @NSManaged var polishType: String?
    @NSManaged var favorited: Bool
    
    
    class func parseClassName() -> String {
        return "PolishColor"
    }
}
