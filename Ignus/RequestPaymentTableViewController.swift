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

class RequestPaymentTableViewController: UITableViewController, ChooseFriendViewControllerDelegate {
    
    @IBOutlet var requestPaymentTable: UITableView!
    
    @IBOutlet weak var recipientCell: UITableViewCell!
    @IBOutlet weak var recipientLabel: UILabel!
    
    var recipient: String?
    
    weak var delegate: RequestPaymentTableViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Deselects the currently selected table view cell
        if let selectedIndexPath = requestPaymentTable.indexPathForSelectedRow {
            requestPaymentTable.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If composing a payment request from someone's profile
        if recipient != nil {
            self.recipientCell.isUserInteractionEnabled = false
            self.recipientLabel.text = recipient
        }
        
        // Adds blur separator effect
        requestPaymentTable.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark))
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
    
    // MARK: - ChooseFriendViewController delegate methods
    
    func chooseFriendViewController(vc: ChooseFriendViewController, choseFriend friend: String) {
        self.recipient = friend
        recipientLabel.text = friend
//        self.textViewDidChange(messageTextView)
        _ = self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Choose Friend" {
            if let chooseFriendVC = segue.destination as? ChooseFriendViewController {
                chooseFriendVC.delegate = self
            }
        }
    }
    

}
