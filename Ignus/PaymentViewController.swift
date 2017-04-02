//
//  PaymentViewController.swift
//  Ignus
//
//  Created by Anant Jain on 3/31/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {
    
    @IBOutlet weak var selectPaymentLabel: UILabel!
    @IBOutlet weak var paymentDetailTable: UITableView!
    
    var paymentInfo: [String: Any]?
    var username: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Hides/shows views based on available information
        guard let paymentInfo = paymentInfo else {
            paymentDetailTable.isHidden = true
            return
        }
        selectPaymentLabel.isHidden = true
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
