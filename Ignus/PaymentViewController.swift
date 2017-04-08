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
    
    var paymentRequest: [String: Any]?
    var username: String?
    var profileInfo: [String: String]?
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedIndex = paymentDetailTable.indexPathForSelectedRow {
            paymentDetailTable.deselectRow(at: selectedIndex, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Hides/shows views based on available information
        if paymentRequest == nil {
            paymentDetailTable.isHidden = true
        }
        else {
            selectPaymentLabel.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard
            let paymentRequest = paymentRequest,
            let username = username,
            let sender = paymentRequest["sender"] as? String,
            let recipient = paymentRequest["recipient"] as? String,
            let memo = paymentRequest["memo"] as? String
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
            let paymentRequest = paymentRequest,
            let username = username,
            let sender = paymentRequest["sender"] as? String,
            let recipient = paymentRequest["recipient"] as? String,
            let memo = paymentRequest["memo"] as? String
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "User Cell", for: indexPath)
                
                guard
                    let personImageView = cell.viewWithTag(1) as? UIImageView,
                    let personNameView = cell.viewWithTag(2) as? UILabel,
                    let personUsernameView = cell.viewWithTag(3) as? UILabel,
                    let username = username
                else {
                    return UITableViewCell()
                }
                
                // Sets initial views to blank, since cells get reused
                personNameView.text = ""
                personUsernameView.text = ""
                personImageView.image = #imageLiteral(resourceName: "Not Loaded Profile")
                cell.isUserInteractionEnabled = false
                
                // Gets user information
                IgnusBackend.getUserInfo(forUser: username, with: { (error, userInfo) in
                    if error == nil {
                        guard
                            let userInfo = userInfo,
                            let firstName = userInfo["firstName"],
                            let lastName = userInfo["lastName"]
                        else {
                            return
                        }
                        
                        self.profileInfo = userInfo
                        cell.isUserInteractionEnabled = true
                        
                        UIView.transition(with: personNameView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            personNameView.text = "\(firstName) \(lastName)"
                        }, completion: nil)
                        UIView.transition(with: personUsernameView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            personUsernameView.text = username
                        }, completion: nil)
                    }
                })
                
                // Gets profile image data
                IgnusBackend.getProfileImage(forUser: username, with: { (error, image) in
                    if error == nil {
                        UIView.transition(with: personImageView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            personImageView.image = image
                        }, completion: nil)
                    }
                })
                
                let backgroundView = UIView()
                backgroundView.backgroundColor = UIColor.gray
                cell.selectedBackgroundView = backgroundView
            }
            else if indexPath.row == 1 {
                cell = tableView.dequeueReusableCell(withIdentifier: "Info Cell", for: indexPath)
                
                guard
                    let username = username,
                    let paymentRequest = paymentRequest,
                    let sender = paymentRequest["sender"] as? String,
                    let recipient = paymentRequest["recipient"] as? String
                else {
                    return UITableViewCell()
                }
                
                if username == sender {
                    cell.textLabel?.text = "Requested:"
                }
                else if username == recipient {
                    cell.textLabel?.text = "Owes me:"
                }
                
                // Sets the label with money and memo
                if let dollars = paymentRequest["dollars"] as? Int,
                   let cents   = paymentRequest["cents"] as? Int {
                    var moneyMemoLabelText = "$\(dollars)."
                    moneyMemoLabelText += (cents >= 10 ? "\(cents)" : "0\(cents)")
                    cell.detailTextLabel?.text = moneyMemoLabelText
                }
            }
            else if indexPath.row == 2 {
                cell = tableView.dequeueReusableCell(withIdentifier: "Info Cell", for: indexPath)
                
                guard
                    let paymentRequest = paymentRequest
                else {
                    return UITableViewCell()
                }
                
                cell.textLabel?.text = "Requested on:"
                
                // Sets timestamp
                if let timeSent = paymentRequest["timestamp"] as? Double {
                    let messageDate = Date(timeIntervalSince1970: timeSent / 1000)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = (Calendar.current.isDateInToday(messageDate)) ? "h:mm a" : "MM/dd/yy"
                    cell.detailTextLabel?.text = dateFormatter.string(from: messageDate)
                }
            }
        }
        else if indexPath.section == 1 {
            guard
                let paymentRequest = paymentRequest,
                let memo = paymentRequest["memo"] as? String
            else {
                return UITableViewCell()
            }
            
            if memo.isEmpty {
                cell = tableView.dequeueReusableCell(withIdentifier: "Button Cell", for: indexPath)
                
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Complete Request"
                    cell.textLabel?.textColor = UIColor.white
                }
                else if indexPath.row == 1 {
                    cell.textLabel?.text = "Delete Request"
                    cell.textLabel?.textColor = UIColor(red: 1.0, green: 82 / 255.0, blue: 72 / 255.0, alpha: 1.0)
                }
                
                let backgroundView = UIView()
                backgroundView.backgroundColor = UIColor.gray
                cell.selectedBackgroundView = backgroundView
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "Memo Cell", for: indexPath)
                
                if let memoTextView = cell.viewWithTag(1) as? UITextView {
                    memoTextView.text = memo
                    memoTextView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
                }
            }
        }
        else if indexPath.section == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Button Cell", for: indexPath)
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Complete Request"
                cell.textLabel?.textColor = UIColor.white
            }
            else if indexPath.row == 1 {
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
                let paymentRequest = paymentRequest,
                let memo = paymentRequest["memo"] as? String
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
                let paymentRequest = paymentRequest,
                let memo = paymentRequest["memo"] as? String
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            guard
                let paymentRequest = paymentRequest,
                let memo = paymentRequest["memo"] as? String
            else {
                return
            }
            if !memo.isEmpty {
                if indexPath.row == 0 {
                    performSegue(withIdentifier: "Rate Payment", sender: nil)
                }
                else if indexPath.row == 1 {
                    let confirmationActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    confirmationActionSheet.addAction(UIAlertAction(title: "Delete Request", style: .destructive, handler: { (alertAction) -> Void in
//                        self.delegate?.deletePayment()
//                        self.dismiss(animated: true, completion: nil)
                    }))
                    confirmationActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) -> Void in
                        tableView.deselectRow(at: indexPath, animated: true)
                    }))
                    present(confirmationActionSheet, animated: true, completion: nil)
                }
            }
        case 2:
            if indexPath.row == 0 {
                performSegue(withIdentifier: "Rate Payment", sender: nil)
            }
            else if indexPath.row == 1 {
                let confirmationActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                confirmationActionSheet.addAction(UIAlertAction(title: "Delete Request", style: .destructive, handler: { (alertAction) -> Void in
                    //                        self.delegate?.deletePayment()
                    //                        self.dismiss(animated: true, completion: nil)
                }))
                confirmationActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) -> Void in
                    tableView.deselectRow(at: indexPath, animated: true)
                }))
                present(confirmationActionSheet, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Show Profile" {
            if let profileVC = segue.destination as? ProfileViewController {
                profileVC.profileInfo = profileInfo
            }
            guard
                let profileNavVC = segue.destination as? UINavigationController,
                let profileVC = profileNavVC.topViewController as? ProfileViewController,
                
                let profileData = sender as? [String : String]
                else {
                    return
            }
            
            profileVC.profileInfo = profileData
        }
    }
    

}
