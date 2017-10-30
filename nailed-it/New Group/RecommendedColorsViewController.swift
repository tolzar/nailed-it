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

class RecommendedColorsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIActionSheetDelegate, NVActivityIndicatorViewable {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var colors: [PolishColor]?
    var sortingOptions = [String]()
    var selectedRows: [Any]!
    let size = CGSize(width: 30, height: 30)
    var refresher: UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        sortingOptions = ["Price: $ to $$$", "Price: $$$ to $", "Name", "Brand"]
        
        let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        
        collectionView.reloadData()
    }
    
    @IBAction func onSort(_ sender: Any) {
        let picker = CZPickerView(headerTitle: "Sort By", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        setUpPicker(picker: picker!)
    }
    
    @objc func refreshData() {
        fetchData(animate: true)
    }
    
    func setUpPicker(picker: CZPickerView) {
        let brownColor = UIColor(red:(164/255), green:(148/255), blue:(147/255), alpha:1.0)
        let greenColor = UIColor(red:(242/255), green:(248/255), blue:(244/255), alpha:1.0)
        let whiteColor = UIColor.white
        picker.delegate = self
        picker.dataSource = self
        picker.needFooterView = false
        picker.allowMultipleSelection = false
        picker.headerBackgroundColor = greenColor
        picker.confirmButtonBackgroundColor = brownColor
        picker.headerTitleColor = brownColor
        picker.confirmButtonNormalColor = whiteColor
        picker.cancelButtonNormalColor = whiteColor
        picker.checkmarkColor = brownColor
        picker.show()
    }
    
    func fetchData(animate: Bool) {
        if animate {
            startAnimating(size, message: "Hang tight!\nLoading your polish collection...", type: NVActivityIndicatorType.ballTrianglePath)
        }
        let query = PFQuery(className:"PolishColor")
        query.order(byDescending: "brand")
        query.addDescendingOrder("createdAt")
        query.limit = 250
        query.findObjectsInBackground {
            (colors: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                if let colors = colors {
                    self.colors = colors as? [PolishColor]
                    if animate {
                        UIView.transition(with: self.collectionView, duration: 1.0, options: .transitionFlipFromBottom, animations: { self.collectionView.reloadData() }, completion: nil)
                    } else {
                        self.collectionView.reloadData()
                    }
                    self.stopAnimating()
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.localizedDescription)")
                self.stopAnimating()
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
        showActionSheet(color: color)
    }
    
    func showActionSheet(color: PolishColor!) {
        let actionSheetController = UIAlertController(title: "\(color!.displayName!) by \(color!.brand!)", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            // Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        let sharePolishColor = UIAlertAction(title: "Share Polish Color", style: .default) { action -> Void in
            self.showShareOptions(polishColor: color!)
        }
        actionSheetController.addAction(sharePolishColor)
        
        let tryItOnAction = UIAlertAction(title: "Try It On", style: .default) { action -> Void in
            self.prepareForTryItOn(color: color)
        }
        actionSheetController.addAction(tryItOnAction)
        
        
        if color!.brand! != "My Color" {
            let findThisColor = UIAlertAction(title: "Find \(color!.displayName!) Online", style: .default) { action -> Void in
                self.prepareForPolishSearch(color: color)
            }
            actionSheetController.addAction(findThisColor)
            
        }
        actionSheetController.popoverPresentationController?.sourceView = self.view as UIView
        self.present(actionSheetController, animated: true, completion: {() -> Void in
            actionSheetController.view.tintColor = UIColor(red:0.98, green:0.66, blue:0.65, alpha:1.0)
        })
    }
    
    func prepareForTryItOn(color: PolishColor!) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tryItOnViewController = storyboard.instantiateViewController(withIdentifier: "TryItOnViewController") as! TryItOnViewController
        tryItOnViewController.colorPickedFromLib = color
        self.show(tryItOnViewController, sender: self)
    }
    
    func prepareForPolishSearch(color: PolishColor!) {
        let allowedCharacterSet = (CharacterSet(charactersIn: " ").inverted)
        let escapedBrand = color!.brand!.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        let escapedName = color!.displayName!.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        let searchString = "https://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords=" + escapedName! + "+" + escapedBrand!
        UIApplication.shared.open(URL(string: searchString)!, options: [:], completionHandler: nil)
    }
    
    func updateSortedColors(sortedColors: [PolishColor]) {
        self.colors = sortedColors
        self.collectionView.reloadData()
        self.stopAnimating()
        self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func showShareOptions(polishColor: PolishColor) {
        var hex = polishColor.hexValue!
        if hex.contains("#") {
            hex = hex.replacingOccurrences(of: "#", with: "")
        }
        
        let allowedCharacterSet = (CharacterSet(charactersIn: " ").inverted)
        let nameBrandString = polishColor.displayName! + " by " + polishColor.brand!
        
        let escapedString = nameBrandString.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        
        let imageToShare = ["https://naileditcodepath.herokuapp.com/colors/\(hex)?name=\(escapedString!)"] as [Any]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension RecommendedColorsViewController: CZPickerViewDelegate, CZPickerViewDataSource {
    func czpickerViewWillDisplay(_ pickerView: CZPickerView!) {
        pickerView.setSelectedRows(self.selectedRows)
    }
    
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return self.sortingOptions.count
    }
    
    func numberOfRowsInPickerView(pickerView: CZPickerView!) -> Int {
        return self.sortingOptions.count
    }
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        return self.sortingOptions[row]
        
    }
    
    func czpickerViewDidClickCancelButton(_ pickerView: CZPickerView!) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
        startAnimating(size, message: "Sorting...", type: NVActivityIndicatorType.ballTrianglePath)
        if self.sortingOptions[row] == "Price: $ to $$$" {
            self.selectedRows = [0]
            pickerView.setSelectedRows([0])
            let sortedColors = self.colors?.sorted {
                let string0 = String(describing: $0.brand)
                let string1 = String(describing: $1.brand)
                return string0 > string1
            }
            self.updateSortedColors(sortedColors: sortedColors!)
        } else if self.sortingOptions[row] == "Price: $$$ to $" {
            self.selectedRows = [1]
            pickerView.setSelectedRows([1])
            let sortedColors = self.colors?.sorted {
                let string0 = String(describing: $0.brand)
                let string1 = String(describing: $1.brand)
                return string0 < string1
            }
            self.updateSortedColors(sortedColors: sortedColors!)
        } else if self.sortingOptions[row] == "Name" {
            self.selectedRows = [2]
            pickerView.setSelectedRows([2])
            let sortedColors = self.colors?.sorted {
                let string0 = String(describing: $0.displayName)
                let string1 = String(describing: $1.displayName)
                return string0 < string1
            }
            self.updateSortedColors(sortedColors: sortedColors!)
        } else if self.sortingOptions[row] == "Brand" {
            self.selectedRows = [3]
            pickerView.setSelectedRows([3])
            var sortedColors = self.colors?.sorted {
                let string0 = String(describing: $0.brand)
                let string1 = String(describing: $1.brand)
                return string0 < string1
            }
            sortedColors = sortedColors?.sorted {
                let createdAt1 = String(describing: $0.createdAt)
                let createdAt2 = String(describing: $1.createdAt)
                return createdAt1 > createdAt2
            }
            self.updateSortedColors(sortedColors: sortedColors!)
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemsAtRows rows: [Any]!) {
    }
}


