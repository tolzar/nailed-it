//
//  EditColorViewController.swift
//  nailed-it
//
//  Created by Terra Oldham on 10/11/17.
//  Copyright © 2017 Lia Zadoyan. All rights reserved.
//

import UIKit

protocol EditColorViewControllerDelegate {
    func onColorSaveSuccess()
}

class EditColorViewController: UIViewController {
    var polishColor: PolishColor!
    
    @IBOutlet weak var pickedColorImage: UIView!
    @IBOutlet weak var pickedColorName: UITextField!
    var delegate: EditColorViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let uiColor = polishColor.getUIColor()
        pickedColorImage.backgroundColor = uiColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onSaveButton(_ sender: Any) {
        self.polishColor.displayName = pickedColorName.text
        self.polishColor.brand = "My Color"
        if polishColor.displayName != nil {
            polishColor.saveInBackground(block: { (success, error) in
                if (success) {
                    _ = self.navigationController?.popViewController(animated: true)
                    self.delegate?.onColorSaveSuccess()

                } else {
                    print("Error: \(error!.localizedDescription)")
                }
            })
        } else {
            print("Please enter name for color")
        }
    }
    
}
