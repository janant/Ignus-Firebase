//
//  PaymentsSplitViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/27/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit

class PaymentsSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.preferredDisplayMode = .allVisible
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let paymentNavVC = secondaryViewController as? UINavigationController {
            if let paymentVC = paymentNavVC.viewControllers[0] as? PaymentViewController {
                if let _ = paymentVC.paymentRequest {
                    return false
                }
            }
        }
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
