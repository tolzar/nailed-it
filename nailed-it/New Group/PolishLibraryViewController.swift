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

@objc protocol PolishLibraryViewControllerDelegate {
    @objc optional func polishColor(with polishColor: PolishColor?)
}

class PolishLibraryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIActionSheetDelegate, NVActivityIndicatorViewable {
    @IBOutlet weak var collectionView: UICollectionView!

    var colors: [PolishColor]?
    var brands = [String]()
    var sortingOptions = [String]()
    weak var delegate: PolishLibraryViewControllerDelegate?
    weak var hamburgerDelegate: HamburgerDelegate?
    var selectedRows: [Any]!
    let size = CGSize(width: 30, height: 30)
    var sortFilter: String = ""
    var refresher:UIRefreshControl!
    var didRefresh: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        brands = ["Essie", "My Color", "Butter London"]
        sortingOptions = ["Price: $ to $$$", "Price: $$$ to $", "Color", "Name"]

        let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.collectionView!.addSubview(refresher)

    }

    @IBAction func onFilter(_ sender: Any) {
        let picker = CZPickerView(headerTitle: "Brands", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        setUpPicker(picker: picker!, type: "filter")
    }
    
    @IBAction func onSort(_ sender: Any) {
        let picker = CZPickerView(headerTitle: "Sort By", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        setUpPicker(picker: picker!, type: "sort")
    }
    
    @objc func refreshData() {
        fetchData(animate: true)
        self.refresher.endRefreshing()
        self.didRefresh = true
    }
    
    func setUpPicker(picker: CZPickerView, type: String) {
        let greenColor = UIColor(red:0.59, green:0.89, blue:0.70, alpha:1.0)
        let pinkColor = UIColor(red:0.98, green:0.66, blue:0.65, alpha:1.0)
        picker.delegate = self
        picker.dataSource = self
        picker.needFooterView = false
        if type == "sort" {
            picker.allowMultipleSelection = false
            self.sortFilter = "sort"
        } else {
            picker.allowMultipleSelection = true
            self.sortFilter = "filter"
        }
        picker.headerBackgroundColor = greenColor
        picker.confirmButtonBackgroundColor = greenColor
        picker.headerTitleColor = pinkColor
        picker.confirmButtonNormalColor = pinkColor
        picker.cancelButtonNormalColor = pinkColor
        picker.checkmarkColor = pinkColor
        picker.show()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        fetchData(animate: collectionView.numberOfItems(inSection: 0) == 0)
    }

    func fetchData(animate: Bool) {
        if animate {
            startAnimating(size, message: "Hang tight!\nLoading your polish collection...", type: NVActivityIndicatorType.ballTrianglePath)
        }
        let query = PFQuery(className:"PolishColor")
        query.order(byDescending: "brand")
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground {
            (colors: [PFObject]?, error: Error?) -> Void in

            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(colors!.count) scores.")
                print(colors!)
                // Do something with the found objects
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
        if let delegate = delegate {
            delegate.polishColor!(with: color)
            dismiss(animated: true, completion: nil)
        } else {
            showActionSheet(color: color)
        }
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
        
        let findSimilarColor = UIAlertAction(title: "Find Similar Colors", style: .default) { action -> Void in
            self.prepareForColorComparasion(color: color, libraryColors: self.colors!)
        }
        actionSheetController.addAction(findSimilarColor)

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
        print(searchString)
        UIApplication.shared.open(URL(string: searchString)!, options: [:], completionHandler: nil)
    }
    
    func prepareForColorComparasion(color: PolishColor!, libraryColors: [PolishColor?]) {
        startAnimating(size, message: "Sorting by Color...", type: NVActivityIndicatorType.ballTrianglePath)
        for libraryColor in libraryColors {
            let redDistance = color.redValue - (libraryColor?.redValue)!
            let greenDistance = color.greenValue - (libraryColor?.greenValue)!
            let blueDistance = color.blueValue - (libraryColor?.blueValue)!
            libraryColor?.distanceVector = CGFloat(((redDistance * redDistance) + (greenDistance * greenDistance) + (blueDistance * blueDistance)).squareRoot())
            
        }
        let sortedColors = self.colors?.sorted {
            let string0 = String(describing: $0.distanceVector)
            let string1 = String(describing: $1.distanceVector)
            return string0 < string1
        }
        self.stopAnimating()
        self.colors = sortedColors
        self.collectionView.reloadData()
        self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                          at: .top,
                                          animated: true)

    }
    
    func updateSortedColors(sortedColors: [PolishColor]) {
        self.stopAnimating()
        self.colors = sortedColors
        self.collectionView.reloadData()
    }
    
    func showShareOptions(polishColor: PolishColor) {
        let image = UIImageView()
        image.image = UIImage.from(color: polishColor.getUIColor())

        let imageToShare = [image.image!, "Check out this nail polish color by \(polishColor.brand!). It's called \(polishColor.displayName!).", "\nShared via Nailed It"] as [Any]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        self.present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func onHamburgerPressed(_ sender: Any) {
        hamburgerDelegate?.hamburgerPressed()
    }
}

extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 200)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

extension PolishLibraryViewController: CZPickerViewDelegate, CZPickerViewDataSource {
    func czpickerViewWillDisplay(_ pickerView: CZPickerView!) {
        if self.sortFilter == "filter" {
            if self.didRefresh == false {
                pickerView.setSelectedRows(self.selectedRows)
            }
        }
    }

    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        if self.sortFilter == "filter" {
            return self.brands.count
        } else {
            return self.sortingOptions.count
        }
    }

    func numberOfRowsInPickerView(pickerView: CZPickerView!) -> Int {
        if self.sortFilter == "filter" {
            return self.brands.count
        } else {
            return self.sortingOptions.count
        }
    }

    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        if self.sortFilter == "filter" {
            return self.brands[row]
        } else {
            return self.sortingOptions[row]
        }

    }

    func czpickerViewDidClickCancelButton(_ pickerView: CZPickerView!) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
        if self.sortFilter == "sort" {
            if self.sortingOptions[row] == "Price: $ to $$$" {
                startAnimating(size, message: "Sorting...", type: NVActivityIndicatorType.ballTrianglePath)
                // Sorting based on brand right now, because it corresponds to price
                let sortedColors = self.colors?.sorted {
                    let string0 = String(describing: $0.brand)
                    let string1 = String(describing: $1.brand)
                    return string0 > string1
                }
                self.updateSortedColors(sortedColors: sortedColors!)
            } else if self.sortingOptions[row] == "Price: $$$ to $" {
                // Sorting based on brand right now, because it corresponds to price
                startAnimating(size, message: "Sorting...", type: NVActivityIndicatorType.ballTrianglePath)
                let sortedColors = self.colors?.sorted {
                    let string0 = String(describing: $0.brand)
                    let string1 = String(describing: $1.brand)
                    return string0 < string1
                }
                self.updateSortedColors(sortedColors: sortedColors!)
            } else if self.sortingOptions[row] == "Color" {
                let compColor = PolishColor()
                compColor.redValue = 255
                compColor.blueValue = 255
                compColor.blueValue = 255
                prepareForColorComparasion(color: compColor, libraryColors: self.colors!)
            } else if self.sortingOptions[row] == "Name" {
                startAnimating(size, message: "Filtering...", type: NVActivityIndicatorType.ballTrianglePath)
                let sortedColors = self.colors?.sorted {
                    let string0 = String(describing: $0.displayName)
                    let string1 = String(describing: $1.displayName)
                    return string0 < string1
                }
                self.updateSortedColors(sortedColors: sortedColors!)
            }
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemsAtRows rows: [Any]!) {
        if self.sortFilter == "filter" {
            startAnimating(size, message: "Filtering...", type: NVActivityIndicatorType.ballTrianglePath)
            var selectedBrands: [String] = []
            self.selectedRows = rows
            var selectedBrandPolishes: [PolishColor] = []
            for row in rows {
                if let row = row as? Int {
                    selectedBrands.append(self.brands[row])
                }
            }
            let brandQuery = PFQuery(className: "PolishColor")
            if !selectedBrands.isEmpty {
                brandQuery.whereKey("brand", containedIn: selectedBrands)
            }
            brandQuery.order(byDescending: "brand")
            brandQuery.addDescendingOrder("createdAt")
            brandQuery.findObjectsInBackground {
                (colors: [PFObject]?, error: Error?) -> Void in
                if error == nil {
                    self.stopAnimating()
                    for color in colors! {
                        if let color = color as? PolishColor {
                            selectedBrandPolishes.append(color)
                        }
                    }
                    self.colors = selectedBrandPolishes
                    self.collectionView.reloadData()
                } else {
                    self.stopAnimating()
                    print("Error: \(error!) \(error!.localizedDescription)")
                }
            }
        }
    }
}
