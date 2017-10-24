//
//  PolishLibraryViewController.swift
//  nailed-it
//
//  Created by Lia Zadoyan on 10/10/17.
//  Copyright © 2017 Lia Zadoyan. All rights reserved.
//

import UIKit
import Parse
import SafariServices
import CZPicker
import NVActivityIndicatorView
import NotificationBannerSwift

@objc protocol TryItOnLibraryViewControllerDelegate {
    @objc optional func polishColor(with polishColor: PolishColor?)
}
class TryItOnLibraryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, HalfModalPresentable {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var colors: [PolishColor]?
    var recommendedColors: [PolishColor]?
    var brands = [String]()
    var sortingOptions = [String]()
    weak var delegate: TryItOnLibraryViewControllerDelegate?
    var selectedRows: [Any]! = [4]
    let size = CGSize(width: 30, height: 30)
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        sortingOptions = ["Price: $ to $$$", "Price: $$$ to $", "Color", "Name", "Brand"]
        
        let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
    }
    override func viewDidAppear(_ animated: Bool) {
        fetchData()
    }
    
    func fetchData() {
        let query = PFQuery(className:"PolishColor")
        query.order(byDescending: "brand")
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground {
            (colors: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                print("Successfully retrieved \(colors!.count) scores.")
                if let colors = colors {
                    self.colors = colors as? [PolishColor]
                    self.collectionView.reloadData()
                }
            } else {
                print("Error: \(error!) \(error!.localizedDescription)")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PolishCollectionViewCell", for: indexPath) as! PolishCollectionViewCell
        cell.polishColor = colors?[indexPath.row]
        
        return cell;
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color = colors?[indexPath.row]
        if let delegate = delegate {
            delegate.polishColor!(with: color)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func maximizeButtonTapped(sender: AnyObject) {
        maximizeToFullScreen()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        dismiss(animated: true, completion: nil)
    }
}


