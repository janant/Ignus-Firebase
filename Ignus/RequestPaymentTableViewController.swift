//
//  RequestPaymentTableViewController.swift
//  Ignus
//
//  Created by Anant Jain on 3/16/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit
import Firebase

protocol RequestPaymentTableViewControllerDelegate: class {
    func sentNewPaymentRequest(requestPaymentTVC: RequestPaymentTableViewController)
    func canceledNewPaymentRequest(requestPaymentTVC: RequestPaymentTableViewController)
}

class RequestPaymentTableViewController: UITableViewController, ChooseFriendViewControllerDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var requestPaymentTable: UITableView!
    
    @IBOutlet weak var recipientCell: UITableViewCell!
    @IBOutlet weak var recipientLabel: UILabel!
    
    @IBOutlet weak var paymentAmountPicker: UIPickerView!
    @IBOutlet weak var memoTextView: UITextView!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
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
        
        // Configures selection highlight color
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.gray
        recipientCell.selectedBackgroundView = selectedView
        
        memoTextView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelRequest(_ sender: Any) {
        self.delegate?.canceledNewPaymentRequest(requestPaymentTVC: self)
    }
    
    @IBAction func sentRequest(_ sender: Any) {
        guard let recipient = recipient else {
            return
        }
        
        // Tells the user that the request is being sent
        self.title = "Sending..."
        self.recipientCell.isUserInteractionEnabled = false
        self.doneButton.isEnabled = false
        
        // Sends the payment request
        IgnusBackend.sendPaymentRequest(toUser: recipient, dollars: paymentAmountPicker.selectedRow(inComponent: 0), cents: paymentAmountPicker.selectedRow(inComponent: 1), memo: memoTextView.text) { (error) in
            if error == nil {
                self.delegate?.sentNewPaymentRequest(requestPaymentTVC: self)
            }
        }
    }
    
    // MARK: - Picker view data source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100
    }
    
    // MARK: - Picker view delegate methods
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = String()
        
        switch component {
        case 0:
            title = "$\(row)."
        case 1:
            title = row < 10 ? "0\(row)" : "\(row)"
        default:
            break
        }
        return NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName:UIColor.white, NSFontAttributeName: UIFont(name: "Gotham-Book", size: 16)!])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let dollarsSelected = paymentAmountPicker.selectedRow(inComponent: 0)
        let centsSelected = paymentAmountPicker.selectedRow(inComponent: 1)
        
        doneButton.isEnabled = !(dollarsSelected == 0 && centsSelected == 0) && recipient != nil
    }

    
    // MARK: - ChooseFriendViewController delegate methods
    
    func chooseFriendViewController(vc: ChooseFriendViewController, choseFriend friend: String) {
        self.recipient = friend
        recipientLabel.text = friend
        _ = self.navigationController?.popViewController(animated: true)
        
        self.pickerView(paymentAmountPicker, didSelectRow: 0, inComponent: 0)
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont(name: "Gotham-Book", size: 13)
        }
    }
    
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
