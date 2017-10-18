//
//  NearbyShopsViewController.swift
//  nailed-it
//
//  Created by Lia Zadoyan on 10/10/17.
//  Copyright © 2017 Lia Zadoyan. All rights reserved.
//

import UIKit
import CoreLocation

class NearbyShopsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var hamburgerButton: UIBarButtonItem!
    
    weak var delegate: HamburgerDelegate?
    
    var businesses: [Shop]!
    var filters: [String : Any]!
    
    var categoryToggles = [Int:Bool]()
    var sortToggles = [Int:Bool]()
    var dealToggles = [Int:Bool]()
    var distanceToggles = [Int:Bool]()
    
    var limit = 0
    var offset = 0
    
    var isMoreDataLoading = false
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        searchBar.delegate = self
                
        // Ask for Authorisation from the User.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopCell", for: indexPath) as! ShopCell
        
        cell.business = businesses[indexPath.row]
        return cell;
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        offset = 0
        searchBar.resignFirstResponder()
        loadData(searchText: self.searchBar.text!)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        offset = 0
        loadData(searchText: searchBar.text!)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                loadMoreData(searchText: searchBar.text!)
            }
        }
    }
    
    func loadData(searchText: String) {
        if filters != nil {
            let categories = filters["categories"] as? [String] ?? nil
            let sort = filters["sortMode"] as? YelpSortMode ?? nil
            let distance = filters["distance"] as? Int ?? nil
            let deals = filters["deals"] as? Bool ?? nil
            
            Shop.searchWithTerm(term: "Nail Salon " + searchText, limit: limit, offset: self.offset, sort: sort, categories: categories, deals: deals, distance: distance) { (businesses: [Shop]?, error: Error?) in
                self.businesses = businesses
                self.offset = (businesses?.count)!
                self.tableView.reloadData()
                self.isMoreDataLoading = false
            }
        } else {
            Shop.searchWithTerm(term: "Nail Salon " + searchText, limit: limit , offset: self.offset, completion: { (businesses: [Shop]?, error: Error?) in
                self.businesses = businesses
                self.offset = (businesses?.count)!
                self.tableView.reloadData()
                self.isMoreDataLoading = false
                
            })
        }
        
        
    }
    
    func loadMoreData(searchText: String) {
        if filters != nil {
            let categories = filters["categories"] as? [String] ?? nil
            let sort = filters["sortMode"] as? YelpSortMode ?? nil
            let distance = filters["distance"] as? Int ?? nil
            let deals = filters["deals"] as? Bool ?? nil
            
            Shop.searchWithTerm(term: "Nail Salon " + searchText, limit: limit, offset: self.offset, sort: sort, categories: categories, deals: deals, distance: distance) { (businesses: [Shop]?, error: Error?) in
                for business in businesses! {
                    self.businesses.append(business)
                }
                self.offset = (self.businesses?.count)!
                self.tableView.reloadData()
                self.isMoreDataLoading = false
            }
        } else {
            Shop.searchWithTerm(term: "Nail Salon " + searchText, limit: limit , offset: self.offset, completion: { (businesses: [Shop]?, error: Error?) in
                for business in businesses! {
                    self.businesses.append(business)
                }
                self.offset = (self.businesses?.count)!
                self.tableView.reloadData()
                self.isMoreDataLoading = false
            })
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            NearbyShopsClient.sharedInstance.setLatitudeAndLongitude(latitude: location.coordinate.latitude.description, longitude: location.coordinate.longitude.description)
            loadData(searchText: "")
        }
    }

    @IBAction func onHamburgerPressed(_ sender: Any) {
        delegate?.hamburgerPressed()
    }
    
    @IBAction func onMapSelected(_ sender: Any) {
        let mapViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        mapViewController.businesses = businesses
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
}
