//
//  PolishLibraryViewController.swift
//  nailed-it
//
//  Created by Lia Zadoyan on 10/10/17.
//  Copyright © 2017 Lia Zadoyan. All rights reserved.
//

import UIKit
import Parse

@objc protocol PolishLibraryViewControllerDelegate {
    @objc optional func polishColor(with polishColor: PickerColor?)
}

class PolishLibraryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var colors: [PickerColor]?
    weak var delegate: PolishLibraryViewControllerDelegate?
    weak var hamburgerDelegate: HamburgerDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var query = PFQuery(className:"PickerColor")
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground {
            (colors: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(colors!.count) scores.")
                print(colors!)
                // Do something with the found objects
                if let colors = colors {
                    self.colors = colors as? [PickerColor]
                    self.collectionView.reloadData()
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.localizedDescription)")
            }
            
            self.collectionView.dataSource = self
            self.collectionView.delegate = self
            
            let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            layout?.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        }
        
        func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PolishCollectionViewCell", for: indexPath) as! PolishCollectionViewCell
        cell.pickerColor = colors?[indexPath.row]
        return cell;
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let color = colors?[indexPath.row] {
            delegate?.polishColor!(with: color)
            dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func onHamurgerPressed(_ sender: Any) {
        hamburgerDelegate?.hamburgerPressed()
    }
}
