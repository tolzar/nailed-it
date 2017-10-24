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

class PolishLibraryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIActionSheetDelegate, UISearchBarDelegate, NVActivityIndicatorViewable {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    var colors: [PolishColor]?
    var recommendedColors: [PolishColor]?
    var brands = [String]()
    var sortingOptions = [String]()
    weak var hamburgerDelegate: HamburgerDelegate?
    var selectedRows: [Any]! = [4]
    let size = CGSize(width: 30, height: 30)
    var refresher: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        searchBar.delegate = self

        sortingOptions = ["Price: $ to $$$", "Price: $$$ to $", "Color", "Name", "Brand"]

        let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize

        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
    }

    @IBAction func onSort(_ sender: Any) {
        let picker = CZPickerView(headerTitle: "Sort By", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        setUpPicker(picker: picker!)
    }

    @objc func refreshData() {
        fetchData(animate: true)
        self.refresher.endRefreshing()
    }

    func setUpPicker(picker: CZPickerView) {
        let greenColor = UIColor(red:0.59, green:0.89, blue:0.70, alpha:1.0)
        let pinkColor = UIColor(red:0.98, green:0.66, blue:0.65, alpha:1.0)
        let whiteColor = UIColor.white
        picker.delegate = self
        picker.dataSource = self
        picker.needFooterView = false
        picker.allowMultipleSelection = false
        picker.headerBackgroundColor = greenColor
        picker.confirmButtonBackgroundColor = greenColor
        picker.headerTitleColor = whiteColor
        picker.confirmButtonNormalColor = whiteColor
        picker.cancelButtonNormalColor = whiteColor
        picker.checkmarkColor = pinkColor
        picker.show()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchData(searchText: self.searchBar.text!, animate: true)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchData(searchText: searchBar.text!, animate: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        fetchData(animate: collectionView.numberOfItems(inSection: 0) == 0)
    }

    func searchData(searchText: String, animate: Bool) {
        if animate {
            startAnimating(size, message: "Hang tight!\nLoading your polish collection...", type: NVActivityIndicatorType.ballTrianglePath)
        }
        var query: PFQuery<PFObject>!
        let brandQuery = PFQuery(className: "PolishColor")
        let nameQuery = PFQuery(className: "PolishColor")
        brandQuery.whereKey("brand", contains: searchText)
        nameQuery.whereKey("displayName", contains: searchText)
        query = PFQuery.orQuery(withSubqueries: [brandQuery, nameQuery])
        query.order(byDescending: "brand")
        query.limit = 250
        query.findObjectsInBackground {
            (colors: [PFObject]?, error: Error?) -> Void in

            if error == nil {
                print("Successfully retrieved \(colors!.count) scores.")
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
                print("Error: \(error!) \(error!.localizedDescription)")
                self.stopAnimating()
            }
        }
    }

    func fetchData(animate: Bool) {
        if animate {
            startAnimating(size, message: "Hang tight!\nLoading your polish collection...", type: NVActivityIndicatorType.ballTrianglePath)
        }
        let query = PFQuery(className:"PolishColor")
        query.order(byDescending: "brand")
        query.limit = 250
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground {
            (colors: [PFObject]?, error: Error?) -> Void in

            if error == nil {
                print("Successfully retrieved \(colors!.count) scores.")
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RecommendedColorsViewController {
            vc.colors = self.recommendedColors
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
            self.startAnimating(self.size, message: "Sorting by Color...", type: NVActivityIndicatorType.ballTrianglePath)
            self.saveDistanceVectors(color: color, libraryColors: self.colors!)
            self.findRecommendedColors(sortedColors: self.sortLibraryColors())
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
        UIApplication.shared.open(URL(string: searchString)!, options: [:], completionHandler: nil)
    }

    func saveDistanceVectors(color: PolishColor!, libraryColors: [PolishColor?]) {
        for libraryColor in libraryColors {
            let redDistance = color.redValue - (libraryColor?.redValue)!
            let greenDistance = color.greenValue - (libraryColor?.greenValue)!
            let blueDistance = color.blueValue - (libraryColor?.blueValue)!
            libraryColor?.distanceVector = CGFloat(((redDistance * redDistance) + (greenDistance * greenDistance) + (blueDistance * blueDistance)).squareRoot())
        }
    }

    func sortLibraryColors() -> [PolishColor] {
        let sortedColors = self.colors?.sorted {
            let string0 = String(describing: $0.distanceVector)
            let string1 = String(describing: $1.distanceVector)
            return string0 < string1
        }
        return sortedColors!
    }

    func findRecommendedColors(sortedColors: [PolishColor]) {
        var sortedAndFiltered = [PolishColor]()
        for sortedColor in sortedColors {
            if sortedColor.distanceVector! < 0.4 {
                sortedAndFiltered.append(sortedColor)
            }
        }
        if sortedAndFiltered.count > 1 {
            self.recommendedColors = sortedAndFiltered
            performSegue(withIdentifier: "recommendedColorsSegue", sender: self)
        } else {
            let banner = NotificationBanner(title: "Oops! We didn't find any similar colors. Try a different one!", subtitle: nil, style: .info)
            banner.show()
        }
        stopAnimating()
    }

    func updateSortedColors(sortedColors: [PolishColor]) {
        self.colors = sortedColors
        self.collectionView.reloadData()
        self.stopAnimating()
        self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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
            } else if self.sortingOptions[row] == "Color" {
                self.selectedRows = [2]
                pickerView.setSelectedRows([2])
                let compColor = PolishColor()
                compColor.redValue = 255
                compColor.blueValue = 255
                compColor.blueValue = 255
                saveDistanceVectors(color: compColor, libraryColors: self.colors!)
                updateSortedColors(sortedColors: sortLibraryColors())
            } else if self.sortingOptions[row] == "Name" {
                self.selectedRows = [3]
                pickerView.setSelectedRows([3])
                let sortedColors = self.colors?.sorted {
                    let string0 = String(describing: $0.displayName)
                    let string1 = String(describing: $1.displayName)
                    return string0 < string1
                }
                self.updateSortedColors(sortedColors: sortedColors!)
            }  else if self.sortingOptions[row] == "Brand" {
                self.selectedRows = [4]
                pickerView.setSelectedRows([4])
                var sortedColors = self.colors?.sorted {
                    let string0 = String(describing: $0.brand)
                    let string1 = String(describing: $1.brand)
                    return string0 > string1
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

