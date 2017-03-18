//
//  PaymentsViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/27/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit

class PaymentsViewController: UIViewController {
    
    // Navigation item
    @IBOutlet weak var paymentsScopeSegmentedControl: UISegmentedControl!
    
    // Main views
    @IBOutlet weak var paymentsLoadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var noPaymentsStackView: UIStackView!
    @IBOutlet weak var noPaymentsTitle: UILabel!
    @IBOutlet weak var noPaymentsDetail: UILabel!
    @IBOutlet weak var paymentsTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

}
