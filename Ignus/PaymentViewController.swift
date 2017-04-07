//
//  PaymentViewController.swift
//  Ignus
//
//  Created by Anant Jain on 3/31/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    
    // MARK: - Table view data source methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard
            let paymentInfo = paymentInfo,
            let username = username,
            let sender = paymentInfo["sender"] as? String,
            let recipient = paymentInfo["recipient"] as? String,
            let memo = paymentInfo["memo"] as? String
        else {
            return 0
        }
        
        if username == recipient {
            return memo.isEmpty ? 2 : 3
        }
        else if username == sender {
            return memo.isEmpty ? 1 : 2
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard
            let paymentInfo = paymentInfo,
            let username = username,
            let sender = paymentInfo["sender"] as? String,
            let recipient = paymentInfo["recipient"] as? String,
            let memo = paymentInfo["memo"] as? String
        else {
            return 0
        }
        
        if username == recipient {
            switch section {
            case 0:
                return 3
            case 1:
                return memo.isEmpty ? 2 : 1
            case 2:
                return 2
            default:
                return 0
            }
        }
        else if username == sender {
            switch section {
            case 0:
                return 3
            case 1:
                return memo.isEmpty ? 0 : 1
            default:
                return 0
            }
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "Friend Cell", for: indexPath)
                
                let personImageView = cell.viewWithTag(1) as! UIImageView!
                let personNameView = cell.viewWithTag(2) as! UILabel!
                let personUsernameView = cell.viewWithTag(3) as! UILabel!
                
                let profileFile = user["Profile"] as! PFFile
                profileFile.getDataInBackground { (data, error) -> Void in
                    if error == nil {
                        UIView.transition(with: personImageView!, duration: 0.3, options: .transitionCrossDissolve, animations: { () -> Void in
                            personImageView?.image = UIImage(data: data!)
                        }, completion: nil)
                    }
                }
                
                personNameView?.text = user["FullName"] as? String
                personUsernameView?.text = user["username"] as? String
                
                let backgroundView = UIView()
                backgroundView.backgroundColor = UIColor.gray
                cell.selectedBackgroundView = backgroundView
            }
            else if (indexPath as NSIndexPath).row == 1 {
                cell = tableView.dequeueReusableCell(withIdentifier: "Info Cell", for: indexPath)
                
                if paymentType == .myRequest {
                    cell.textLabel?.text = "Owes me:"
                }
                else if paymentType == .incoming {
                    cell.textLabel?.text = "Needs:"
                }
                
                cell.detailTextLabel?.text = "$" + (payment["MoneyOwed"] as! String)
            }
            else if (indexPath as NSIndexPath).row == 2 {
                cell = tableView.dequeueReusableCell(withIdentifier: "Info Cell", for: indexPath)
                
                cell.textLabel?.text = "Requested on:"
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy h:mm a"
                cell.detailTextLabel?.text = dateFormatter.string(from: payment.createdAt)
            }
        }
        else if (indexPath as NSIndexPath).section == 1 {
            if memoExists {
                cell = tableView.dequeueReusableCell(withIdentifier: "Memo Cell", for: indexPath)
                
                let memoTextView = cell.viewWithTag(1) as! UITextView
                memoTextView.text = payment["Memo"] as? String
                
                memoTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "Button Cell", for: indexPath)
                
                if (indexPath as NSIndexPath).row == 0 {
                    cell.textLabel?.text = "Complete Request"
                    cell.textLabel?.textColor = UIColor.white
                }
                else if (indexPath as NSIndexPath).row == 1 {
                    cell.textLabel?.text = "Delete Request"
                    cell.textLabel?.textColor = UIColor(red: 1.0, green: 82 / 255.0, blue: 72 / 255.0, alpha: 1.0)
                }
                
                let backgroundView = UIView()
                backgroundView.backgroundColor = UIColor.gray
                cell.selectedBackgroundView = backgroundView
            }
        }
        else if (indexPath as NSIndexPath).section == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Button Cell", for: indexPath)
            
            if (indexPath as NSIndexPath).row == 0 {
                cell.textLabel?.text = "Complete Request"
                cell.textLabel?.textColor = UIColor.white
            }
            else if (indexPath as NSIndexPath).row == 1 {
                cell.textLabel?.text = "Delete Request"
                cell.textLabel?.textColor = UIColor(red: 1.0, green: 82 / 255.0, blue: 72 / 255.0, alpha: 1.0)
            }
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.gray
            cell.selectedBackgroundView = backgroundView
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Payment Info"
        case 1:
            guard
                let paymentInfo = paymentInfo,
                let memo = paymentInfo["memo"] as? String
            else {
                return nil
            }
            
            return memo.isEmpty ? nil : "Memo"
        default:
            return nil
        }
    }
    
    // MARK: - Table view delegate methods
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont(name: "Gotham-Book", size: 13)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return 64
            }
            else {
                return 44
            }
        case 1:
            guard
                let paymentInfo = paymentInfo,
                let memo = paymentInfo["memo"] as? String
            else {
                return 0
            }
            
            if memo.isEmpty {
                return 44
            }
            else {
                return 74
            }
        case 2:
            return 44
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).section {
        case 1:
            if !memoExists {
                switch (indexPath as NSIndexPath).row {
                case 0:
                    performSegue(withIdentifier: "Rate Payment", sender: nil)
                    break
                case 1:
                    let confirmationActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    confirmationActionSheet.addAction(UIAlertAction(title: "Delete Request", style: .destructive, handler: { (alertAction) -> Void in
                        self.delegate?.deletePayment()
                        self.dismiss(animated: true, completion: nil)
                    }))
                    confirmationActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) -> Void in
                        self.tableView.deselectRow(at: indexPath, animated: true)
                    }))
                    present(confirmationActionSheet, animated: true, completion: nil)
                default:
                    break
                }
            }
        case 2:
            switch (indexPath as NSIndexPath).row {
            case 0:
                performSegue(withIdentifier: "Rate Payment", sender: nil)
                break
            case 1:
                let confirmationActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                confirmationActionSheet.addAction(UIAlertAction(title: "Delete Request", style: .destructive, handler: { (alertAction) -> Void in
                    self.delegate?.deletePayment()
                    self.dismiss(animated: true, completion: nil)
                }))
                confirmationActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) -> Void in
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }))
                present(confirmationActionSheet, animated: true, completion: nil)
            default:
                break
            }
        default:
            break
        }
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
