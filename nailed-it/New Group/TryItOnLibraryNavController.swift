//
//  TryItOnLibraryNavController.swift
//  nailed-it
//
//  Created by Lia Zadoyan on 10/23/17.
//  Copyright © 2017 Lia Zadoyan. All rights reserved.
//

import UIKit

class TryItOnLibraryNavController: UINavigationController, HalfModalPresentable {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isHalfModalMaximized() ? .default : .lightContent
    }
}
