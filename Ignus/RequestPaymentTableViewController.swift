//
//  RequestPaymentTableViewController.swift
//  Ignus
//
//  Created by Anant Jain on 3/16/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit

protocol RequestPaymentTableViewControllerDelegate: class {
    func sentNewPaymentRequest(requestPaymentTVC: RequestPaymentTableViewController, requestData: [String: Any])
    func canceledNewPaymentRequest(requestPaymentTVC: RequestPaymentTableViewController)
}

class RequestPaymentTableViewController: UITableViewController {
    
    weak var delegate: RequestPaymentTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelRequest(_ sender: Any) {
        self.delegate?.canceledNewPaymentRequest(requestPaymentTVC: self)
    }
    
    @IBAction func sentRequest(_ sender: Any) {
        self.delegate?.sentNewPaymentRequest(requestPaymentTVC: self, requestData: [String : Any]())
    }
    

    // MARK: - Table view data source

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
