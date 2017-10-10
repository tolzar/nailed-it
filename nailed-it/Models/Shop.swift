//
//  Shop.swift
//  nailed-it
//
//  Created by Lia Zadoyan on 10/10/17.
//  Copyright © 2017 Lia Zadoyan. All rights reserved.
//

import UIKit

class Shop: NSObject {
    let name: String?
    let address: String?
    let displayAddress: String?
    let imageURL: URL?
    let categories: String?
    let distance: String?
    let ratingImageURL: URL?
    let reviewCount: NSNumber?
    
    init(dictionary: NSDictionary) {
        name = dictionary["name"] as? String
        
        let imageURLString = dictionary["image_url"] as? String
        if imageURLString != nil {
            imageURL = URL(string: imageURLString!)!
        } else {
            imageURL = nil
        }
        
        let location = dictionary["location"] as? NSDictionary
        var address = ""
        var displayAddress = ""
        if location != nil {
            let addressArray = location!["address"] as? NSArray
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }
            
            let displayAddressArray = location!["display_address"] as? NSArray
            if displayAddressArray != nil && displayAddressArray!.count > 0 {
                displayAddress = (displayAddressArray![0] as! String)
            } else {
                displayAddress = ""
            }
            
            let neighborhoods = location!["neighborhoods"] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                address += neighborhoods![0] as! String
            }
        }
        self.address = address
        self.displayAddress = displayAddress
        
        let categoriesArray = dictionary["categories"] as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                let categoryName = category[0]
                categoryNames.append(categoryName)
            }
            categories = categoryNames.joined(separator: ", ")
        } else {
            categories = nil
        }
        
        let distanceMeters = dictionary["distance"] as? NSNumber
        if distanceMeters != nil {
            let milesPerMeter = 0.000621371
            distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
        } else {
            distance = nil
        }
        
        let ratingImageURLString = dictionary["rating_img_url_large"] as? String
        if ratingImageURLString != nil {
            ratingImageURL = URL(string: ratingImageURLString!)
        } else {
            ratingImageURL = nil
        }
        
        reviewCount = dictionary["review_count"] as? NSNumber
    }
    
    class func businesses(array: [NSDictionary]) -> [Shop] {
        var businesses = [Shop]()
        for dictionary in array {
            let business = Shop(dictionary: dictionary)
            businesses.append(business)
        }
        return businesses
    }
    
    class func searchWithTerm(term: String, limit: Int, offset: Int, completion: @escaping ([Shop]?, Error?) -> Void) {
        _ = NearbyShopsClient.sharedInstance.searchWithTerm(term, limit: limit, offset: offset, completion: completion)
    }
    
    class func searchWithTerm(term: String, limit: Int, offset: Int, sort: YelpSortMode?, categories: [String]?, deals: Bool?, distance: Int?, completion: @escaping ([Shop]?, Error?) -> Void) -> Void {
        _ = NearbyShopsClient.sharedInstance.searchWithTerm(term, limit: limit, offset: offset, sort: sort, categories: categories, deals: deals, distance: distance, completion: completion)
    }
}
