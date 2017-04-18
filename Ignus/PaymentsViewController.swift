//
//  PaymentsViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/27/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit
import Firebase

class PaymentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, RequestPaymentTableViewControllerDelegate, PaymentViewControllerDelegate {
    
    // Navigation item
    @IBOutlet weak var paymentsCategorySegmentedControl: UISegmentedControl!
    
    // Main views
    @IBOutlet weak var paymentsLoadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var noPaymentsStackView: UIStackView!
    @IBOutlet weak var noPaymentsTitle: UILabel!
    @IBOutlet weak var noPaymentsDetail: UILabel!
    @IBOutlet weak var paymentsTable: UITableView!
    
    var activePaymentsSent        = [[String: Any]]()
    var activePaymentsReceived    = [[String: Any]]()
    var completedPaymentsSent     = [[String: Any]]()
    var completedPaymentsReceived = [[String: Any]]()
    
    let refreshControl = UIRefreshControl()
    
    var requestPaymentDismissalTransition: RequestPaymentTransition?
    
    var shouldManuallyReload = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldManuallyReload {
            reloadData()
            shouldManuallyReload = false
        }
        else {
            paymentsCategoryChanged(paymentsCategorySegmentedControl)
        }
        
        if let selectedIndex = paymentsTable.indexPathForSelectedRow {
            paymentsTable.deselectRow(at: selectedIndex, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Sets up the table
        paymentsTable.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark))
        paymentsTable.backgroundView = nil
        paymentsTable.backgroundColor = UIColor.clear
        refreshControl.addTarget(self, action: #selector(PaymentsViewController.reloadData), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        paymentsTable.addSubview(refreshControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.reloadData), name: NSNotification.Name(Constants.NotificationNames.ReloadPayments), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData() {
        guard let currentUser = FIRAuth.auth()?.currentUser else {
            return
        }
        
        IgnusBackend.resetState()
        IgnusBackend.configureState(forUser: currentUser)
        
        // Gets payments data from Ignus backend
        IgnusBackend.getCurrentUserPaymentRequests(with: { (paymentsData) in
            guard
                let sentPaymentRequests = paymentsData["sent"],
                let receivedPaymentRequests = paymentsData["received"]
            else {
                return
            }
            
            // Sets current payments data
            self.activePaymentsSent = sentPaymentRequests.filter {
                guard let paymentStatus = $0["status"] as? String else {
                    return false
                }
                return paymentStatus == Constants.PaymentRequestStatus.Active
            }
            self.activePaymentsReceived = receivedPaymentRequests.filter {
                guard let paymentStatus = $0["status"] as? String else {
                    return false
                }
                return paymentStatus == Constants.PaymentRequestStatus.Active
            }
            self.completedPaymentsSent = sentPaymentRequests.filter {
                guard let paymentStatus = $0["status"] as? String else {
                    return false
                }
                return paymentStatus == Constants.PaymentRequestStatus.Completed
            }
            self.completedPaymentsReceived = receivedPaymentRequests.filter {
                guard let paymentStatus = $0["status"] as? String else {
                    return false
                }
                return paymentStatus == Constants.PaymentRequestStatus.Completed
            }
            
            // If the refresh was caused by pulling the refresh control, end refresh animation
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            // Displays appropriate information depending on currently selected scope
            if self.paymentsCategorySegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Active {
                self.paymentsTable.reloadData()
                
                if self.activePaymentsSent.isEmpty && self.activePaymentsReceived.isEmpty {
                    // Displays to the user that there are no requests, with animation
                    UIView.animate(withDuration: 0.25, animations: {
                        self.paymentsLoadingIndicatorView.alpha = 0.0
                        self.noPaymentsStackView.alpha = 1.0
                        self.paymentsTable.alpha = 0.0
                    }, completion: { (completed) in
                        self.paymentsLoadingIndicatorView.stopAnimating()
                        self.paymentsTable.isUserInteractionEnabled = false
                    })
                }
                else { // There are requests, displays requests in the table
                    UIView.animate(withDuration: 0.25, animations: {
                        self.paymentsLoadingIndicatorView.alpha = 0.0
                        self.noPaymentsStackView.alpha = 0.0
                        self.paymentsTable.alpha = 1.0
                    }, completion: { (completed) in
                        self.paymentsLoadingIndicatorView.stopAnimating()
                        self.paymentsTable.isUserInteractionEnabled = true
                    })
                }
            }
            else if self.paymentsCategorySegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Completed {
                self.paymentsTable.reloadData()
                
                if self.completedPaymentsSent.isEmpty && self.completedPaymentsReceived.isEmpty {
                    // Displays to the user that there are no requests, with animation
                    UIView.animate(withDuration: 0.25, animations: {
                        self.paymentsLoadingIndicatorView.alpha = 0.0
                        self.noPaymentsStackView.alpha = 1.0
                        self.paymentsTable.alpha = 0.0
                    }, completion: { (completed) in
                        self.paymentsLoadingIndicatorView.stopAnimating()
                        self.paymentsTable.isUserInteractionEnabled = false
                    })
                }
                else { // There are requests, displays requests in the table
                    UIView.animate(withDuration: 0.25, animations: {
                        self.paymentsLoadingIndicatorView.alpha = 0.0
                        self.noPaymentsStackView.alpha = 0.0
                        self.paymentsTable.alpha = 1.0
                    }, completion: { (completed) in
                        self.paymentsLoadingIndicatorView.stopAnimating()
                        self.paymentsTable.isUserInteractionEnabled = true
                    })
                }
            }
        })
    }
    
    @IBAction func paymentsCategoryChanged(_ sender: Any) {
        guard let selectedIndex = (sender as? UISegmentedControl)?.selectedSegmentIndex else {
            return
        }
        
        // Gets data if there are either no sent or received requests, and not already loading them
        if activePaymentsSent.isEmpty && activePaymentsReceived.isEmpty
            && completedPaymentsSent.isEmpty && completedPaymentsReceived.isEmpty
            && !paymentsLoadingIndicatorView.isAnimating {
            
            // Shows the user that requests are loading
            paymentsLoadingIndicatorView.startAnimating()
            paymentsLoadingIndicatorView.alpha = 1.0
            noPaymentsStackView.alpha = 0.0
            paymentsTable.alpha = 0.0
            
            // Gets payments data from Ignus backend
            IgnusBackend.getCurrentUserPaymentRequests(with: { (paymentsData) in
                guard
                    let sentPaymentRequests = paymentsData["sent"],
                    let receivedPaymentRequests = paymentsData["received"]
                else {
                    return
                }
                
                // Sets current payments data
                self.activePaymentsSent = sentPaymentRequests.filter {
                    guard let paymentStatus = $0["status"] as? String else {
                        return false
                    }
                    return paymentStatus == Constants.PaymentRequestStatus.Active
                }
                self.activePaymentsReceived = receivedPaymentRequests.filter {
                    guard let paymentStatus = $0["status"] as? String else {
                        return false
                    }
                    return paymentStatus == Constants.PaymentRequestStatus.Active
                }
                self.completedPaymentsSent = sentPaymentRequests.filter {
                    guard let paymentStatus = $0["status"] as? String else {
                        return false
                    }
                    return paymentStatus == Constants.PaymentRequestStatus.Completed
                }
                self.completedPaymentsReceived = receivedPaymentRequests.filter {
                    guard let paymentStatus = $0["status"] as? String else {
                        return false
                    }
                    return paymentStatus == Constants.PaymentRequestStatus.Completed
                }
                
                // Displays appropriate information depending on currently selected scope
                if selectedIndex == Constants.PaymentsScope.Active {
                    if self.activePaymentsSent.isEmpty && self.activePaymentsReceived.isEmpty {
                        // Displays to the user that there are no payment requests, with animation
                        UIView.animate(withDuration: 0.25, animations: {
                            self.paymentsLoadingIndicatorView.alpha = 0.0
                            self.noPaymentsStackView.alpha = 1.0
                        }, completion: { (completed) in
                            self.paymentsTable.isUserInteractionEnabled = false
                            self.paymentsLoadingIndicatorView.stopAnimating()
                        })
                    }
                    else {
                        // There are payment requests, display them in the table
                        self.paymentsTable.reloadData()
                        
                        UIView.animate(withDuration: 0.25, animations: {
                            self.paymentsLoadingIndicatorView.alpha = 0.0
                            self.paymentsTable.alpha = 1.0
                        }, completion: { (completed) in
                            self.paymentsLoadingIndicatorView.stopAnimating()
                            self.paymentsTable.isUserInteractionEnabled = true
                        })
                    }
                }
                else if selectedIndex == Constants.PaymentsScope.Completed {
                    if self.completedPaymentsSent.isEmpty && self.completedPaymentsReceived.isEmpty {
                        // Displays to the user that there are no payment requests, with animation
                        UIView.animate(withDuration: 0.25, animations: {
                            self.paymentsLoadingIndicatorView.alpha = 0.0
                            self.noPaymentsStackView.alpha = 1.0
                        }, completion: { (completed) in
                            self.paymentsTable.isUserInteractionEnabled = false
                            self.paymentsLoadingIndicatorView.stopAnimating()
                        })
                    }
                    else {
                        // There are payment requests, display them in the table
                        self.paymentsTable.reloadData()
                        
                        UIView.animate(withDuration: 0.25, animations: {
                            self.paymentsLoadingIndicatorView.alpha = 0.0
                            self.paymentsTable.alpha = 1.0
                        }, completion: { (completed) in
                            self.paymentsLoadingIndicatorView.stopAnimating()
                            self.paymentsTable.isUserInteractionEnabled = true
                        })
                    }
                }
            })
        }
        else {
            paymentsTable.reloadData()
            paymentsLoadingIndicatorView.alpha = 0.0
            
            // Displays appropriate information depending on currently selected scope
            if selectedIndex == Constants.PaymentsScope.Active {
                if self.activePaymentsSent.isEmpty && self.activePaymentsReceived.isEmpty {
                    // Displays to the user that there are no payment requests
                    paymentsTable.alpha = 0.0
                    paymentsTable.isUserInteractionEnabled = false
                    noPaymentsStackView.alpha = 1.0
                }
                else {
                    // There are payment requests, display them in the table
                    paymentsTable.alpha = 1.0
                    paymentsTable.isUserInteractionEnabled = true
                    noPaymentsStackView.alpha = 0.0
                }
            }
            else if selectedIndex == Constants.PaymentsScope.Completed {
                if self.completedPaymentsSent.isEmpty && self.completedPaymentsReceived.isEmpty {
                    // Displays to the user that there are no payment requests
                    paymentsTable.alpha = 0.0
                    paymentsTable.isUserInteractionEnabled = false
                    noPaymentsStackView.alpha = 1.0
                }
                else {
                    // There are payment requests, display them in the table
                    paymentsTable.alpha = 1.0
                    paymentsTable.isUserInteractionEnabled = true
                    noPaymentsStackView.alpha = 0.0
                }
            }
        }
    }

    // MARK: - Table view data source methods

    func numberOfSections(in tableView: UITableView) -> Int {
        if paymentsCategorySegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Active {
            if !activePaymentsSent.isEmpty && !activePaymentsReceived.isEmpty {
                return 2
            }
            else if !activePaymentsSent.isEmpty || !activePaymentsReceived.isEmpty {
                return 1
            }
            else {
                return 0
            }
        }
        else if paymentsCategorySegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Completed {
            if !completedPaymentsSent.isEmpty && !completedPaymentsReceived.isEmpty {
                return 2
            }
            else if !completedPaymentsSent.isEmpty || !completedPaymentsReceived.isEmpty {
                return 1
            }
            else {
                return 0
            }
        }
        else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if paymentsCategorySegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Active {
            if section == 0 {
                if !activePaymentsReceived.isEmpty {
                    return activePaymentsReceived.count
                }
                else {
                    return activePaymentsSent.count
                }
            }
            else if section == 1 {
                return activePaymentsSent.count
            }
            else {
                return 0
            }
        }
        else if paymentsCategorySegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Completed {
            if section == 0 {
                if !completedPaymentsReceived.isEmpty {
                    return completedPaymentsReceived.count
                }
                else {
                    return completedPaymentsSent.count
                }
            }
            else if section == 1 {
                return completedPaymentsSent.count
            }
            else {
                return 0
            }
        }
        else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if paymentsCategorySegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Active {
            if section == 0 {
                if !activePaymentsReceived.isEmpty {
                    return "Requests to Me"
                }
                else {
                    return "My Requests"
                }
            }
            else if section == 1 {
                return "My Requests"
            }
            else {
                return nil
            }
        }
        else if paymentsCategorySegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Completed {
            if section == 0 {
                if !completedPaymentsReceived.isEmpty {
                    return "Requests to Me"
                }
                else {
                    return "My Requests"
                }
            }
            else if section == 1 {
                return "My Requests"
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if paymentsCategorySegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Active {
            let cell = paymentsTable.dequeueReusableCell(withIdentifier: "Active Cell", for: indexPath)
            
            // Gets views needed for setting up the table cell
            guard
                let profileImageView = cell.viewWithTag(1) as? UIImageView,
                let nameLabel = cell.viewWithTag(2) as? UILabel,
                let moneyMemoLabel = cell.viewWithTag(3) as? UILabel,
                let unreadIndicator = cell.viewWithTag(4),
                let dateLabel = cell.viewWithTag(5) as? UILabel
            else {
                return UITableViewCell()
            }
            
            // Gets the current payment request data and username
            guard
                let paymentRequest: [String: Any] = {
                    if indexPath.section == 0 {
                        if !activePaymentsReceived.isEmpty {
                            return activePaymentsReceived[indexPath.row]
                        }
                        else {
                            return activePaymentsSent[indexPath.row]
                        }
                    }
                    else if indexPath.section == 1 {
                        return activePaymentsSent[indexPath.row]
                    }
                    else {
                        return nil
                    }
                }(),
                let username: String = {
                    if indexPath.section == 0 {
                        if !activePaymentsReceived.isEmpty {
                            return paymentRequest["sender"] as? String
                        }
                        else {
                            return paymentRequest["recipient"] as? String
                        }
                    }
                    else if indexPath.section == 1 {
                        return paymentRequest["recipient"] as? String
                    }
                    else {
                        return nil
                    }
                }()
            else {
                return UITableViewCell()
            }
            
            // Sets initial data to blank, since cells get reused
            nameLabel.text = ""
            moneyMemoLabel.text = ""
            dateLabel.text = ""
            profileImageView.image = #imageLiteral(resourceName: "Not Loaded Profile")
            
            // Gets profile info for this user
            IgnusBackend.getUserInfo(forUser: username, with: { (error, userData) in
                if error == nil {
                    guard
                        let userInfo = userData,
                        let firstName = userInfo["firstName"],
                        let lastName = userInfo["lastName"]
                    else {
                        return
                    }
                    
                    UIView.transition(with: nameLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        nameLabel.text = "\(firstName) \(lastName)"
                    }, completion: nil)
                }
            })
            
            // Gets profile image data
            IgnusBackend.getProfileImage(forUser: username) { (error, image) in
                if error == nil {
                    UIView.transition(with: profileImageView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        profileImageView.image = image
                    }, completion: nil)
                }
            }
            
            // Sets the label with money and memo
            if let dollars = paymentRequest["dollars"] as? Int,
               let cents   = paymentRequest["cents"] as? Int,
               let memo    = paymentRequest["memo"] as? String {
                var moneyMemoLabelText = "$\(dollars)."
                moneyMemoLabelText += (cents >= 10 ? "\(cents)" : "0\(cents)")
                if !memo.isEmpty {
                    moneyMemoLabelText += " - \(memo)"
                }
                moneyMemoLabel.text = moneyMemoLabelText
            }
            
            // Sets timestamp
            if let timeSent = paymentRequest["createdTimestamp"] as? TimeInterval {
                let messageDate = Date(timeIntervalSince1970: timeSent / 1000)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = (Calendar.current.isDateInToday(messageDate)) ? "h:mm a" : "MM/dd/yy"
                dateLabel.text = dateFormatter.string(from: messageDate)
            }
            
            // Shows/hides unread indicator
            if paymentRequest["sender"] as? String == username {
                if let messageUnread = paymentRequest["unread"] as? Bool {
                    unreadIndicator.isHidden = !messageUnread
                }
            }
            else {
                unreadIndicator.isHidden = true
            }
            
            
            cell.backgroundColor = UIColor.clear
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.gray
            cell.selectedBackgroundView = backgroundView
            
            return cell
        }
        else if paymentsCategorySegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Completed {
            let cell = paymentsTable.dequeueReusableCell(withIdentifier: "Completed Cell", for: indexPath)
            
            // Gets views needed for setting up the table cell
            guard
                let profileImageView = cell.viewWithTag(1) as? UIImageView,
                let nameLabel = cell.viewWithTag(2) as? UILabel,
                let moneyMemoLabel = cell.viewWithTag(3) as? UILabel,
                let dateLabel = cell.viewWithTag(5) as? UILabel
            else {
                return UITableViewCell()
            }
            
            // Gets the current payment request data and username
            guard
                let paymentRequest: [String: Any] = {
                    if indexPath.section == 0 {
                        if !completedPaymentsReceived.isEmpty {
                            return completedPaymentsReceived[indexPath.row]
                        }
                        else {
                            return completedPaymentsSent[indexPath.row]
                        }
                    }
                    else if indexPath.section == 1 {
                        return completedPaymentsSent[indexPath.row]
                    }
                    else {
                        return nil
                    }
                }(),
                let username: String = {
                    if indexPath.section == 0 {
                        if !completedPaymentsReceived.isEmpty {
                            return paymentRequest["sender"] as? String
                        }
                        else {
                            return paymentRequest["recipient"] as? String
                        }
                    }
                    else if indexPath.section == 1 {
                        return paymentRequest["recipient"] as? String
                    }
                    else {
                        return nil
                    }
                }()
            else {
                return UITableViewCell()
            }
            
            // Sets initial data to blank, since cells get reused
            nameLabel.text = ""
            moneyMemoLabel.text = ""
            profileImageView.image = #imageLiteral(resourceName: "Not Loaded Profile")
            
            // Gets profile info for this user
            IgnusBackend.getUserInfo(forUser: username, with: { (error, userData) in
                if error == nil {
                    guard
                        let userInfo = userData,
                        let firstName = userInfo["firstName"],
                        let lastName = userInfo["lastName"]
                    else {
                        return
                    }
                    
                    UIView.transition(with: nameLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        nameLabel.text = "\(firstName) \(lastName)"
                    }, completion: nil)
                }
            })
            
            // Gets profile image data
            IgnusBackend.getProfileImage(forUser: username) { (error, image) in
                if error == nil {
                    UIView.transition(with: profileImageView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        profileImageView.image = image
                    }, completion: nil)
                }
            }
            
            // Sets the label with money and memo
            if let dollars = paymentRequest["dollars"] as? Int,
               let cents   = paymentRequest["cents"] as? Int,
               let memo    = paymentRequest["memo"] as? String {
                var moneyMemoLabelText = "$\(dollars)."
                moneyMemoLabelText += (cents >= 10 ? "\(cents)" : "0\(cents)")
                if !memo.isEmpty {
                    moneyMemoLabelText += " - \(memo)"
                }
                moneyMemoLabel.text = moneyMemoLabelText
            }
            
            // Sets timestamp
            if let timeSent = paymentRequest["completedTimestamp"] as? TimeInterval {
                let messageDate = Date(timeIntervalSince1970: timeSent / 1000)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = (Calendar.current.isDateInToday(messageDate)) ? "h:mm a" : "MM/dd/yy"
                let dateText = "\(dateFormatter.string(from: messageDate))   "
                let dateAttributedText = NSAttributedString(string: dateText, attributes: dateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                dateLabel.attributedText = dateAttributedText
            }
            
            // Sets the background color of timestamp label to indicate rating
            if let rating = paymentRequest["rating"] as? String {
                if rating == Constants.PaymentRating.Green {
                    dateLabel.backgroundColor = #colorLiteral(red: 0.3333333333, green: 0.8039215686, blue: 0.1607843137, alpha: 1)
                    dateLabel.textColor = UIColor.white
                }
                else if rating == Constants.PaymentRating.Yellow {
                    dateLabel.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1)
                    dateLabel.textColor = UIColor.darkGray
                }
                else if rating == Constants.PaymentRating.Red {
                    dateLabel.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
                    dateLabel.textColor = UIColor.white
                }
            }
            
            cell.backgroundColor = UIColor.clear
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.gray
            cell.selectedBackgroundView = backgroundView
            
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    // MARK: - Table view delegate methods
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {
            return
        }
        view.tintColor = #colorLiteral(red: 0.1215686275, green: 0.1215686275, blue: 0.1215686275, alpha: 1)
        headerView.textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Gets the current payment request data and username
        if paymentsCategorySegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Active {
            guard
                var paymentRequest: [String: Any] = {
                    if indexPath.section == 0 {
                        if !activePaymentsReceived.isEmpty {
                            return activePaymentsReceived[indexPath.row]
                        }
                        else {
                            return activePaymentsSent[indexPath.row]
                        }
                    }
                    else if indexPath.section == 1 {
                        return activePaymentsSent[indexPath.row]
                    }
                    else {
                        return nil
                    }
                }(),
                let username: String = {
                    if indexPath.section == 0 {
                        if !activePaymentsReceived.isEmpty {
                            return paymentRequest["sender"] as? String
                        }
                        else {
                            return paymentRequest["recipient"] as? String
                        }
                    }
                    else if indexPath.section == 1 {
                        return paymentRequest["recipient"] as? String
                    }
                    else {
                        return nil
                    }
                }()
            else {
                return
            }
            
            // Marks the payment request as read, if not already
            if paymentRequest["sender"] as? String == username &&
               paymentRequest["unread"] as? Bool == true {
                activePaymentsReceived[indexPath.row]["unread"] = false
                paymentRequest["unread"] = false
                IgnusBackend.markPaymentRequestAsRead(paymentRequest, with: { (error) in
                    if let selectedCell = tableView.cellForRow(at: indexPath) {
                        if let unreadIndicator = selectedCell.viewWithTag(4) {

                            unreadIndicator.isHidden = true
                        }
                    }
                })
            }
            
            let paymentSegueInfo: [String: Any] =
                [Constants.PaymentSegueInfoKeys.Username: username,
                 Constants.PaymentSegueInfoKeys.PaymentRequest: paymentRequest]
            
            performSegue(withIdentifier: "Show Payment Detail", sender: paymentSegueInfo)
        }
        if paymentsCategorySegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Completed {
            guard
                let paymentRequest: [String: Any] = {
                    if indexPath.section == 0 {
                        if !completedPaymentsReceived.isEmpty {
                            return completedPaymentsReceived[indexPath.row]
                        }
                        else {
                            return completedPaymentsSent[indexPath.row]
                        }
                    }
                    else if indexPath.section == 1 {
                        return completedPaymentsSent[indexPath.row]
                    }
                    else {
                        return nil
                    }
                }(),
                let username: String = {
                    if indexPath.section == 0 {
                        if !completedPaymentsReceived.isEmpty {
                            return paymentRequest["sender"] as? String
                        }
                        else {
                            return paymentRequest["recipient"] as? String
                        }
                    }
                    else if indexPath.section == 1 {
                        return paymentRequest["recipient"] as? String
                    }
                    else {
                        return nil
                    }
                }()
                else {
                    return
            }
            
            let paymentSegueInfo: [String: Any] =
                [Constants.PaymentSegueInfoKeys.Username: username,
                 Constants.PaymentSegueInfoKeys.PaymentRequest: paymentRequest]
            
            performSegue(withIdentifier: "Show Payment Detail", sender: paymentSegueInfo)
        }
    }
    
    // MARK: - RequestPaymentTableViewControllerDelegate methods
    
    func sentNewPaymentRequest(requestPaymentTVC: RequestPaymentTableViewController) {
        reloadData()
        
        requestPaymentDismissalTransition = RequestPaymentTransition(presenting: false, sentRequest: true)
        requestPaymentTVC.dismiss(animated: true, completion: nil)
    }
    
    func canceledNewPaymentRequest(requestPaymentTVC: RequestPaymentTableViewController) {
        requestPaymentDismissalTransition = RequestPaymentTransition(presenting: false, sentRequest: false)
        requestPaymentTVC.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - PaymentViewController delegate methods
    
    func closePaymentInfo(paymentVC: PaymentViewController) {
        
        // Pops view controllers
        if self.splitViewController?.traitCollection.horizontalSizeClass == .regular {
            reloadData()
        }
        else {
            shouldManuallyReload = true
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        // Hides payment detail views
        paymentVC.selectPaymentLabel.isHidden = false
        paymentVC.paymentRequest = nil
        paymentVC.paymentDetailTable.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.25, animations: {
            paymentVC.selectPaymentLabel.alpha = 1.0
            paymentVC.paymentDetailTable.alpha = 0.0
        })
    }
    
    // MARK: - Transitioning delegate methods
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let navVC = presented as? UINavigationController {
            if navVC.topViewController is RequestPaymentTableViewController {
                return RequestPaymentTransition(presenting: true)
            }
        }
        
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let navVC = dismissed as? UINavigationController {
            if navVC.topViewController is RequestPaymentTableViewController {
                return requestPaymentDismissalTransition
            }
        }
        
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if let navVC = presented as? UINavigationController {
            if navVC.topViewController is RequestPaymentTableViewController {
                return RequestPaymentPresentation(presentedViewController: presented, presenting: presenting)
            }
        }
        
        return nil
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Request Payment" {
            if let navVC = segue.destination as? UINavigationController {
                navVC.transitioningDelegate = self
                navVC.modalPresentationStyle = .custom
                
                if let requestPaymentTVC = navVC.topViewController as? RequestPaymentTableViewController {
                    requestPaymentTVC.delegate = self
                }
            }
        }
        else if segue.identifier == "Show Payment Detail" {
            if let navVC = segue.destination as? UINavigationController {
                if let paymentVC = navVC.topViewController as? PaymentViewController {
                    guard
                        let paymentSegueInfo = sender as? [String: Any],
                        let username = paymentSegueInfo[Constants.PaymentSegueInfoKeys.Username] as? String,
                        let paymentInfo = paymentSegueInfo[Constants.PaymentSegueInfoKeys.PaymentRequest] as? [String: Any]
                    else {
                        return
                    }
                    
                    paymentVC.username = username
                    paymentVC.paymentRequest = paymentInfo
                    paymentVC.delegate = self
                }
            }
        }
    }
    

}
