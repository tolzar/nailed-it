//
//  MenuViewController.swift
//  nailed-it
//
//  Created by Lia Zadoyan on 10/10/17.
//  Copyright © 2017 Lia Zadoyan. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    private var nearbyShopsNavController: UIViewController!
    private var colorDropperNavController: UIViewController!
    private var polishLibraryNavController: UIViewController!
    private var tryItOnNavController: UIViewController!
    
    var viewControllers: [UIViewController] = []
    
    var hamburgerViewController: HamburgerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        nearbyShopsNavController = storyboard.instantiateViewController(withIdentifier: "NearbyShopsNavigationController")
        let nearbyShopsVC = nearbyShopsNavController.childViewControllers[0] as! NearbyShopsViewController
        nearbyShopsVC.delegate = hamburgerViewController
        
        colorDropperNavController = storyboard.instantiateViewController(withIdentifier: "ColorDropperNavigationController")
        let colorDropperVC = colorDropperNavController.childViewControllers[0] as! ColorDropperViewController
        colorDropperVC.delegate = hamburgerViewController
        
        polishLibraryNavController = storyboard.instantiateViewController(withIdentifier: "PolishLibraryNavigationController")
        let polishLibraryVC = polishLibraryNavController.childViewControllers[0] as! PolishLibraryViewController
        polishLibraryVC.hamburgerDelegate = hamburgerViewController
        
        tryItOnNavController = storyboard.instantiateViewController(withIdentifier: "TryItOnNavigationController")
        let tryItOnVC = tryItOnNavController.childViewControllers[0] as! TryItOnViewController
        tryItOnVC.delegate = hamburgerViewController

        viewControllers.append(nearbyShopsNavController)
        viewControllers.append(colorDropperNavController)
        viewControllers.append(polishLibraryNavController)
        viewControllers.append(tryItOnNavController)

        hamburgerViewController.contentViewController = viewControllers[2]
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func onNearbyShopsSelected(_ sender: Any) {
        hamburgerViewController.contentViewController = viewControllers[0]
    }
    
    
    @IBAction func onColorDropperSelected(_ sender: Any) {
        hamburgerViewController.contentViewController = viewControllers[1]
    }

    @IBAction func onPolishLibrarySelected(_ sender: Any) {
        hamburgerViewController.contentViewController = viewControllers[2]

    }


    @IBAction func onTryItOnSelected(_ sender: Any) {
        hamburgerViewController.contentViewController = viewControllers[3]
    }
}
