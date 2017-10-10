//
//  NearbyShopsClient.swift
//  nailed-it
//
//  Created by Lia Zadoyan on 10/10/17.
//  Copyright © 2017 Lia Zadoyan. All rights reserved.
//

import UIKit
import AFNetworking
import BDBOAuth1Manager
import CoreLocation

// You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
let yelpConsumerKey = "vxKwwcR_NMQ7WaEiQBK_CA"
let yelpConsumerSecret = "33QCvh5bIF5jIHR5klQr7RtBDhQ"
let yelpToken = "uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV"
let yelpTokenSecret = "mqtKIxMIR4iBtBPZCmCLEb-Dz3Y"

enum YelpSortMode: Int {
    case bestMatched = 0, distance, highestRated
}

class NearbyShopsClient: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!
    var latitude: String?
    var longitude: String?
    
    //MARK: Shared Instance
    
    static let sharedInstance = NearbyShopsClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        let baseUrl = URL(string: "https://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
        
        let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }
    
    func setLatitudeAndLongitude(latitude: String!, longitude: String!) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func searchWithTerm(_ term: String, limit: Int, offset: Int, completion: @escaping ([Shop]?, Error?) -> Void) -> AFHTTPRequestOperation {
        return searchWithTerm(term, limit: limit, offset: offset, sort: nil, categories: nil, deals: nil, distance: nil, completion: completion)
    }
    
    func searchWithTerm(_ term: String, limit: Int, offset:Int, sort: YelpSortMode?, categories: [String]?, deals: Bool?, distance: Int?, completion: @escaping ([Shop]?, Error?) -> Void) -> AFHTTPRequestOperation {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
        
        // Default the location to San Francisco
        let locationManager = CLLocationManager()
        
        var latlongString: String?
        if let lat = latitude {
            latlongString = lat + "," + longitude!
        } else {
            latlongString = "37.785771,-122.406165"
        }

        var parameters: [String : AnyObject] = ["term": term as AnyObject, "ll": latlongString as AnyObject]
        
        if sort != nil {
            parameters["sort"] = sort!.rawValue as AnyObject?
        }
        
        if categories != nil && categories!.count > 0 {
            parameters["category_filter"] = (categories!).joined(separator: ",") as AnyObject?
        }
        
        if deals != nil {
            parameters["deals_filter"] = deals! as AnyObject?
        }
        
        if distance != nil {
            parameters["radius_filter"] = distance! as AnyObject?
        }
        
        if offset != 0 {
            parameters["offset"] = offset as AnyObject
        }
        
        print(parameters)
        
        return self.get("search", parameters: parameters,
                        success: { (operation: AFHTTPRequestOperation, response: Any) -> Void in
                            if let response = response as? [String: Any]{
                                let dictionaries = response["businesses"] as? [NSDictionary]
                                if dictionaries != nil {
                                    completion(Shop.businesses(array: dictionaries!), nil)
                                }
                            }
        },
                        failure: { (operation: AFHTTPRequestOperation?, error: Error) -> Void in
                            completion(nil, error)
        })!
    }
}
