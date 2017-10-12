//
//  EditColorViewController.swift
//  nailed-it
//
//  Created by Terra Oldham on 10/11/17.
//  Copyright © 2017 Lia Zadoyan. All rights reserved.
//

import UIKit

class EditColorViewController: UIViewController {
    var pickedColor: PickerColor!
    
    @IBOutlet weak var pickedColorImage: UIView!
    @IBOutlet weak var pickedColorName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let uiColor = pickedColor.getUIColor()
        pickedColorImage.backgroundColor = uiColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onSaveButton(_ sender: Any) {
        self.pickedColor.displayName = pickedColorName.text
        if pickedColor.displayName != nil {
            pickedColor.saveInBackground(block: { (success, error) in
                if (success) {
                    print(self.pickedColor)
                } else {
                    print("Error: \(error!.localizedDescription)")
                }
            })
        } else {
            print("Please enter name for color")
        }
    }
}
