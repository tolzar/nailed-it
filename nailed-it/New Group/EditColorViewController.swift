//
//  EditColorViewController.swift
//  nailed-it
//
//  Created by Terra Oldham on 10/11/17.
//  Copyright © 2017 Lia Zadoyan. All rights reserved.
//

import UIKit
import NotificationBannerSwift

protocol EditColorViewControllerDelegate {
    func onColorSaveSuccess()
}

class EditColorViewController: UIViewController {
    var polishColor: PolishColor!
    
    @IBOutlet weak var pickedColorImage: UIView!
    @IBOutlet weak var pickedColorName: UITextView!
    @IBOutlet weak var whiteCircleView: UIView!
    
    var delegate: EditColorViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let uiColor = polishColor.getUIColor()
        pickedColorImage.backgroundColor = uiColor
        pickedColorImage.layer.borderWidth = 1
        pickedColorImage.layer.borderColor = UIColor.gray.cgColor
        whiteCircleView.layer.cornerRadius = whiteCircleView.frame.width / 2
        whiteCircleView.layer.masksToBounds = true
        whiteCircleView.layer.borderWidth = 1
        whiteCircleView.layer.borderColor = UIColor.gray.cgColor
        
        pickedColorName.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onSaveButton(_ sender: Any) {
        self.polishColor.displayName = pickedColorName.text
        self.polishColor.brand = "My Color"
        if polishColor.displayName != nil && polishColor.displayName != "" {
            polishColor.saveInBackground(block: { (success, error) in
                if (success) {
                    _ = self.navigationController?.popViewController(animated: true)
                    self.delegate?.onColorSaveSuccess()
                } else {
                    print("Error: \(error!.localizedDescription)")
                }
            })
        } else {
            let banner = NotificationBanner(title: "Oops! You need to add a polish name before you can save.", subtitle: nil, style: .info)
            banner.show()
            
        }
    }
    
    
}
