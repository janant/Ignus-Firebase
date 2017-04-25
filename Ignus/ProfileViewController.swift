//
//  ProfileViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/30/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit
import Firebase
import XYPieChart

class ProfileViewController: UIViewController, UIViewControllerTransitioningDelegate, ProfileOptionsViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MessageViewControllerDelegate, RequestPaymentTableViewControllerDelegate, XYPieChartDataSource, XYPieChartDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var selectUserLabel: UILabel!
    @IBOutlet weak var profileView: UIView!
    
    // Profile header views
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    // Needed for profile options view controller animation
    @IBOutlet weak var profileOptionsButton: UIButton!
    @IBOutlet weak var profileCoverView: UIView!
    
    // Views which are switched between in profile detail
    @IBOutlet weak var pieChartView: UIView!
    @IBOutlet weak var paymentsView: UIView!
    
    // Pie chart views
    @IBOutlet weak var pieChart: XYPieChart!
    @IBOutlet weak var ratingBackgroundView: UIVisualEffectView!
    @IBOutlet weak var pieChartLoadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var pieChartNoRatingsLabel: UILabel!
    @IBOutlet weak var chartPercentageLabel: UILabel!
    @IBOutlet weak var chartPercentageDescription: UILabel!
    
    // Payments views
    @IBOutlet weak var paymentsLoadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var paymentsNoPaymentsLabel: UILabel!
    @IBOutlet weak var paymentsTable: UITableView!
    @IBOutlet weak var paymentsScopeSegmentedControl: UISegmentedControl!
    
    // Used for changing profile/cover images
    var profilePickerVC: UIImagePickerController?
    var coverPickerVC: UIImagePickerController?
    
    // Payment data
    var activePaymentsSent        = [[String: Any]]()
    var activePaymentsReceived    = [[String: Any]]()
    var completedPaymentsSent     = [[String: Any]]()
    var completedPaymentsReceived = [[String: Any]]()
    var mutualActivePaymentsSent        = [[String: Any]]()
    var mutualActivePaymentsReceived    = [[String: Any]]()
    var mutualCompletedPaymentsSent     = [[String: Any]]()
    var mutualCompletedPaymentsReceived = [[String: Any]]()
    
    var profileInfo: [String: String]?
    var profileType: String!
    
    var requestPaymentDismissalTransition: RequestPaymentTransition?
    var messageDismissalTransition: MessageTransition?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Hides/shows views based on available information
        guard let profileInfo = profileInfo else {
            profileView.isHidden = true
            return
        }
        selectUserLabel.isHidden = true
        
        // Gets user information
        guard
            let currentUserUsername = IgnusBackend.currentUserUsername,
            
            let firstName = profileInfo["firstName"],
            let lastName = profileInfo["lastName"],
            let username = profileInfo["username"]
        else {
            return
        }
        
        // Loads profile picture
        IgnusBackend.getProfileImage(forUser: username) { (error, image) in
            if error == nil {
                UIView.transition(with: self.profileImageView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.profileImageView.image = image
                }, completion: nil)
            }
        }
        // Loads cover picture
        IgnusBackend.getCoverPhoto(forUser: username) { (error, image) in
            if error == nil {
                UIView.transition(with: self.coverImageView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.coverImageView.image = image
                }, completion: nil)
            }
        }
        
        // Fades in new data
        UIView.transition(with: self.nameLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.nameLabel.text = "\(firstName) \(lastName)"
        }, completion: nil)
        UIView.transition(with: self.usernameLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.usernameLabel.text = username
        }, completion: nil)
        
        IgnusBackend.getCurrentUserFriendRequests { (myFriendRequests) in
            IgnusBackend.getCurrentUserFriends(with: { (myFriends) in
                guard
                    let myFriendRequestsSent = myFriendRequests["sent"],
                    let myFriendRequestsReceived = myFriendRequests["received"]
                else {
                    return
                }
                
                // Determines the profile type of the user
                if username == currentUserUsername {
                    self.profileType = Constants.ProfileTypes.CurrentUser
                }
                else if myFriends.contains(username) {
                    self.profileType = Constants.ProfileTypes.Friend
                }
                else if myFriendRequestsSent.contains(username) {
                    self.profileType = Constants.ProfileTypes.PendingFriend
                }
                else if myFriendRequestsReceived.contains(username) {
                    self.profileType = Constants.ProfileTypes.RequestedFriend
                }
                else {
                    self.profileType = Constants.ProfileTypes.User
                }
                
                self.profileOptionsButton.isEnabled = true
            })
        }
        
        // Gets this user's friends and displays how many friends they have
        IgnusBackend.getFriends(forUser: username) { (friends) in
            UIView.transition(with: self.friendsLabel, duration: 0.25, options: .transitionCrossDissolve, animations: { 
                self.friendsLabel.text = "\(friends.count)"
            }, completion: nil)
        }
        
        // Sets up pie chart view
        pieChart.dataSource = self
        pieChart.delegate = self
        pieChart.animationSpeed = 1.0
        pieChart.showLabel = false
        ratingBackgroundView.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        // Gets payment requests
        IgnusBackend.getPaymentRequests(forUser: username) { (paymentRequests) in
            guard
                let sentPaymentRequests = paymentRequests["sent"],
                let receivedPaymentRequests = paymentRequests["received"]
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
            self.mutualActivePaymentsSent = self.activePaymentsSent.filter {
                return ($0["recipient"] as? String) == currentUserUsername
            }
            self.mutualActivePaymentsReceived = self.activePaymentsReceived.filter {
                return ($0["sender"] as? String) == currentUserUsername
            }
            self.mutualCompletedPaymentsSent = self.completedPaymentsSent.filter {
                return ($0["recipient"] as? String) == currentUserUsername
            }
            self.mutualCompletedPaymentsReceived = self.completedPaymentsReceived.filter {
                return ($0["sender"] as? String) == currentUserUsername
            }
            
            // Sets up pie chart view
            let totalRatings = self.completedPaymentsSent.count + self.completedPaymentsReceived.count
            if totalRatings > 0 {
                let userRating = Int(round((self.ratingProportion(forRating: Constants.PaymentRating.Green) * 100)))
                // Sets rating label
                UIView.transition(with: self.ratingLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    self.ratingLabel.text = "\(userRating)%"
                }, completion: nil)
                
                // Prevents user from interacting with pie chart if only one rating type exists
                let greenRatings = self.numberOfRatings(forRating: Constants.PaymentRating.Green)
                let yellowRatings = self.numberOfRatings(forRating: Constants.PaymentRating.Yellow)
                let redRatings = self.numberOfRatings(forRating: Constants.PaymentRating.Red)
                if totalRatings == max(greenRatings, yellowRatings, redRatings) {
                    self.pieChart.isUserInteractionEnabled = false
                }
                
                // Sets up pie chart
                self.pieChart.pieRadius = min(self.pieChart.frame.size.height * 0.4, 120)
                self.pieChart.pieCenter = self.ratingBackgroundView.center
                self.pieChart.reloadData()
                
                // Sets chart percentage label
                self.chartPercentageLabel.text = String(format: "%.1lf%%", self.ratingProportion(forRating: Constants.PaymentRating.Green) * 100.0)
                
                // Animates away loading indicators
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.pieChartLoadingIndicatorView.alpha = 0.0
                    self.paymentsLoadingIndicatorView.alpha = 0.0
                }, completion: { (completed) -> Void in
                    self.pieChartLoadingIndicatorView.stopAnimating()
                    self.paymentsLoadingIndicatorView.stopAnimating()
                })
                
                // Shows rating background view on pie chart
                UIView.animate(withDuration: 1.0, animations: { () -> Void in
                    self.ratingBackgroundView.transform =  self.view.frame.size.height < 500 ? CGAffineTransform(scaleX: 0.8, y: 0.8) : CGAffineTransform.identity
                })
                
                // Shows payments views
                UIView.animate(withDuration: 0.25, animations: { 
                    if self.mutualActivePaymentsSent.count + self.mutualActivePaymentsReceived.count > 0 {
                        self.paymentsTable.reloadData()
                        self.paymentsTable.alpha = 1.0
                        self.paymentsTable.isUserInteractionEnabled = true
                    }
                    else {
                        self.paymentsNoPaymentsLabel.alpha = 1.0
                    }
                    self.paymentsScopeSegmentedControl.alpha = 1.0
                    self.paymentsLoadingIndicatorView.alpha = 0.0
                })
            }
            else {
                // Sets rating label
                UIView.transition(with: self.ratingLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    self.ratingLabel.text = "N/A"
                }, completion: nil)
                
                // Animates away loading indicators
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.pieChartLoadingIndicatorView.alpha = 0.0
                    self.paymentsLoadingIndicatorView.alpha = 0.0
                }, completion: { (completed) -> Void in
                    self.pieChartLoadingIndicatorView.stopAnimating()
                    self.paymentsLoadingIndicatorView.stopAnimating()
                })
                
                // Shows no ratings views
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.pieChartNoRatingsLabel.alpha = 1.0
                    self.paymentsNoPaymentsLabel.alpha = 1.0
                })
            }
        }
        
        // Sets up payments table
        paymentsTable.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark))
        paymentsTable.backgroundView = nil
        paymentsTable.backgroundColor = UIColor.clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyAccountViewController.refreshProfile(_:)), name: NSNotification.Name(rawValue: Constants.NotificationNames.ReloadProfileImages), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func profileInfoScopeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == Constants.ProfileScope.Ratings {
            // Hides and shows views
            pieChartView.isHidden = false
            paymentsView.isHidden = true
        }
        else if sender.selectedSegmentIndex == Constants.ProfileScope.Payments {
            // Hides and shows views
            pieChartView.isHidden = true
            paymentsView.isHidden = false
        }
    }
    
    @IBAction func paymentsScopeChanged(_ sender: UISegmentedControl) {
        paymentsTable.contentOffset = CGPoint(x: 0, y: 0)
        paymentsTable.reloadData()
        
        if sender.selectedSegmentIndex == Constants.PaymentsScope.Active {
            if mutualActivePaymentsSent.count + mutualActivePaymentsReceived.count > 0 {
                paymentsTable.alpha = 1.0
                paymentsNoPaymentsLabel.alpha = 0.0
                paymentsTable.isUserInteractionEnabled = true
            }
            else {
                paymentsTable.alpha = 0.0
                paymentsNoPaymentsLabel.alpha = 1.0
                paymentsTable.isUserInteractionEnabled = false
            }
        }
        else if sender.selectedSegmentIndex == Constants.PaymentsScope.Completed {
            if mutualCompletedPaymentsSent.count + mutualCompletedPaymentsReceived.count > 0 {
                paymentsTable.alpha = 1.0
                paymentsNoPaymentsLabel.alpha = 0.0
                paymentsTable.isUserInteractionEnabled = true
            }
            else {
                paymentsTable.alpha = 0.0
                paymentsNoPaymentsLabel.alpha = 1.0
                paymentsTable.isUserInteractionEnabled = false
            }
        }
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        if paymentsScopeSegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Active {
            if !mutualActivePaymentsSent.isEmpty && !mutualActivePaymentsReceived.isEmpty {
                return 2
            }
            else if !mutualActivePaymentsSent.isEmpty || !mutualActivePaymentsReceived.isEmpty {
                return 1
            }
            else {
                return 0
            }
        }
        else if paymentsScopeSegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Completed {
            if !mutualCompletedPaymentsSent.isEmpty && !mutualCompletedPaymentsReceived.isEmpty {
                return 2
            }
            else if !mutualCompletedPaymentsSent.isEmpty || !mutualCompletedPaymentsReceived.isEmpty {
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
        if paymentsScopeSegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Active {
            if section == 0 {
                if !mutualActivePaymentsSent.isEmpty {
                    return mutualActivePaymentsSent.count
                }
                else {
                    return mutualActivePaymentsReceived.count
                }
            }
            else if section == 1 {
                return mutualActivePaymentsReceived.count
            }
            else {
                return 0
            }
        }
        else if paymentsScopeSegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Completed {
            if section == 0 {
                if !mutualCompletedPaymentsSent.isEmpty {
                    return mutualCompletedPaymentsSent.count
                }
                else {
                    return mutualCompletedPaymentsReceived.count
                }
            }
            else if section == 1 {
                return mutualCompletedPaymentsReceived.count
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
        if paymentsScopeSegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Active {
            if section == 0 {
                if !mutualActivePaymentsSent.isEmpty {
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
        else if paymentsScopeSegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Completed {
            if section == 0 {
                if !mutualCompletedPaymentsSent.isEmpty {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Payment Cell", for: indexPath)
        
        guard
            let requestTypeLabel = cell.viewWithTag(2) as? UILabel,
            let requestDescriptionLabel = cell.viewWithTag(3) as? UILabel,
            let requestDateLabel = cell.viewWithTag(5) as? UILabel
        else {
            return cell
        }
        
        if paymentsScopeSegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Active {
            // Gets the current payment request data and username
            guard
                let paymentRequest: [String: Any] = {
                    if indexPath.section == 0 {
                        if !mutualActivePaymentsSent.isEmpty {
                            requestTypeLabel.text = "Request to Me"
                            return mutualActivePaymentsSent[indexPath.row]
                        }
                        else {
                            let payment = mutualActivePaymentsReceived[indexPath.row]
                            if let username = payment["recipient"] as? String {
                                requestTypeLabel.text = "Request to \(username)"
                            }
                            return payment
                        }
                    }
                    else if indexPath.section == 1 {
                        let payment = mutualActivePaymentsReceived[indexPath.row]
                        if let username = payment["recipient"] as? String {
                            requestTypeLabel.text = "Request to \(username)"
                        }
                        return payment
                    }
                    else {
                        return nil
                    }
                }()
                else {
                    return UITableViewCell()
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
                requestDescriptionLabel.text = moneyMemoLabelText
            }
            
            // Sets timestamp
            if let timeSent = paymentRequest["createdTimestamp"] as? TimeInterval {
                let messageDate = Date(timeIntervalSince1970: timeSent / 1000)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = (Calendar.current.isDateInToday(messageDate)) ? "h:mm a" : "MM/dd/yy"
                requestDateLabel.text = dateFormatter.string(from: messageDate)
                
                // Since cells tend to be reused
                requestDateLabel.backgroundColor = UIColor.clear
                requestDateLabel.textColor = UIColor.lightGray
            }
        }
        else if paymentsScopeSegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Completed {
            // Gets the current payment request data and username
            guard
                let paymentRequest: [String: Any] = {
                    if indexPath.section == 0 {
                        if !mutualCompletedPaymentsSent.isEmpty {
                            requestTypeLabel.text = "Request to Me"
                            return mutualCompletedPaymentsSent[indexPath.row]
                        }
                        else {
                            let payment = mutualCompletedPaymentsReceived[indexPath.row]
                            if let username = payment["recipient"] as? String {
                                requestTypeLabel.text = "Request to \(username)"
                            }
                            return payment
                        }
                    }
                    else if indexPath.section == 1 {
                        let payment = mutualCompletedPaymentsReceived[indexPath.row]
                        if let username = payment["recipient"] as? String {
                            requestTypeLabel.text = "Request to \(username)"
                        }
                        return payment
                    }
                    else {
                        return nil
                    }
                }()
                else {
                    return UITableViewCell()
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
                requestDescriptionLabel.text = moneyMemoLabelText
            }
            
            // Sets timestamp
            if let timeSent = paymentRequest["completedTimestamp"] as? TimeInterval {
                let messageDate = Date(timeIntervalSince1970: timeSent / 1000)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = (Calendar.current.isDateInToday(messageDate)) ? "h:mm a" : "MM/dd/yy"
                let dateText = "\(dateFormatter.string(from: messageDate))   "
                let dateAttributedText = NSAttributedString(string: dateText, attributes: requestDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                requestDateLabel.attributedText = dateAttributedText
            }
            
            // Sets the background color of timestamp label to indicate rating
            if let rating = paymentRequest["rating"] as? String {
                if rating == Constants.PaymentRating.Green {
                    requestDateLabel.backgroundColor = #colorLiteral(red: 0.3333333333, green: 0.8039215686, blue: 0.1607843137, alpha: 1)
                    requestDateLabel.textColor = UIColor.white
                }
                else if rating == Constants.PaymentRating.Yellow {
                    requestDateLabel.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1)
                    requestDateLabel.textColor = UIColor.darkGray
                }
                else if rating == Constants.PaymentRating.Red {
                    requestDateLabel.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
                    requestDateLabel.textColor = UIColor.white
                }
            }
        }
        
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {
            return
        }
        view.tintColor = #colorLiteral(red: 0.1215686275, green: 0.1215686275, blue: 0.1215686275, alpha: 1)
        headerView.textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Do nothing
    }
    
    // MARK: - Size change methods
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            // Do nothing
        }) { (context) in
            // Fixes pie chart size and position
            self.pieChart.pieRadius = min(self.pieChart.frame.size.height * 0.4, 120)
            self.pieChart.pieCenter = self.ratingBackgroundView.center
        }
    }
    
    // MARK: - Rating accessor methods
    
    func ratingProportion(forRating rating: String) -> Double {
        let totalRatings = completedPaymentsSent.count + completedPaymentsReceived.count
        var matchingRatings = 0
        
        if totalRatings == 0 {
            return 0
        }
        
        // Goes through completed payments and counts number of matching ratings
        for paymentRequest in completedPaymentsSent {
            if (paymentRequest["rating"] as? String) == rating {
                matchingRatings += 1
            }
        }
        for paymentRequest in completedPaymentsReceived {
            if (paymentRequest["rating"] as? String) == rating {
                matchingRatings += 1
            }
        }
        
        return Double(matchingRatings) / Double(totalRatings)
    }
    
    func numberOfRatings(forRating rating: String) -> Int {
        var matchingRatings = 0
        
        // Goes through completed payments and counts number of matching ratings
        for paymentRequest in completedPaymentsSent {
            if (paymentRequest["rating"] as? String) == rating {
                matchingRatings += 1
            }
        }
        for paymentRequest in completedPaymentsReceived {
            if (paymentRequest["rating"] as? String) == rating {
                matchingRatings += 1
            }
        }
        
        return matchingRatings
    }
    
    // MARK: - Profile refresh data methods
    
    func refreshProfile(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo as? [String: UIImage],
            let profileImage = userInfo[Constants.UserInfoKeys.Profile],
            let coverImage = userInfo[Constants.UserInfoKeys.Cover]
            else {
                return
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.profileImageView.image = profileImage
            self.coverImageView.image = coverImage
        })
    }
    
    // MARK: - ProfileOptionsViewControllerDelegate methods
    
    func changeProfilePicture() {
        // Create an image picker to change profile picture
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.allowsEditing = true
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .photoLibrary // Default
        
        // Creates an action sheet to choose from either photo library or camera
        let imagePickerSourceSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        imagePickerSourceSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerVC.sourceType = .camera
                
                UINavigationBar.appearance().titleTextAttributes = nil
                UISegmentedControl.appearance().setTitleTextAttributes(nil, for: UIControlState())
                UIBarButtonItem.appearance().setTitleTextAttributes(nil, for: UIControlState())
                
                self.profilePickerVC = imagePickerVC
                
                self.present(imagePickerVC, animated: true, completion: nil)
            }
            else {
                let errorAlert = UIAlertController(title: "Error", message: "Ignus does not have access to the camera. You may need to enable access in Settings.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        imagePickerSourceSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePickerVC.sourceType = .photoLibrary
                
                UINavigationBar.appearance().titleTextAttributes = nil
                UISegmentedControl.appearance().setTitleTextAttributes(nil, for: UIControlState())
                UIBarButtonItem.appearance().setTitleTextAttributes(nil, for: UIControlState())
                
                self.profilePickerVC = imagePickerVC
                
                self.present(imagePickerVC, animated: true, completion: nil)
            }
            else {
                let errorAlert = UIAlertController(title: "Error", message: "Ignus does not have access to your photos library. You may need to enable access in Settings.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        imagePickerSourceSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        imagePickerSourceSheet.popoverPresentationController?.sourceView = profileOptionsButton
        
        present(imagePickerSourceSheet, animated: true, completion: nil)
    }
    
    func changeCoverPicture() {
        // Create an image picker to change cover picture
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.allowsEditing = true
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .photoLibrary // Default
        
        // Creates an action sheet to choose from either photo library or camera
        let imagePickerSourceSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        imagePickerSourceSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerVC.sourceType = .camera
                
                UINavigationBar.appearance().titleTextAttributes = nil
                UISegmentedControl.appearance().setTitleTextAttributes(nil, for: UIControlState())
                UIBarButtonItem.appearance().setTitleTextAttributes(nil, for: UIControlState())
                
                self.coverPickerVC = imagePickerVC
                
                self.present(imagePickerVC, animated: true, completion: nil)
            }
            else {
                let errorAlert = UIAlertController(title: "Error", message: "Ignus does not have access to the camera. You may need to enable access in Settings.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        imagePickerSourceSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePickerVC.sourceType = .photoLibrary
                
                UINavigationBar.appearance().titleTextAttributes = nil
                UISegmentedControl.appearance().setTitleTextAttributes(nil, for: UIControlState())
                UIBarButtonItem.appearance().setTitleTextAttributes(nil, for: UIControlState())
                
                UIBarButtonItem.appearance().setTitleTextAttributes(nil, for: UIControlState())
                UINavigationBar.appearance().titleTextAttributes = nil
                
                self.coverPickerVC = imagePickerVC
                
                self.present(imagePickerVC, animated: true, completion: nil)
            }
            else {
                let errorAlert = UIAlertController(title: "Error", message: "Ignus does not have access to your photos library. You may need to enable access in Settings.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        imagePickerSourceSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        imagePickerSourceSheet.popoverPresentationController?.sourceView = profileOptionsButton
        
        present(imagePickerSourceSheet, animated: true, completion: nil)
    }
    
    func sendFriendRequest() {
        guard let profileUsername = self.profileInfo?["username"] else {
            return
        }
        
        profileOptionsButton.isEnabled = false
        
        // Handles send friend request
        IgnusBackend.sendFriendRequest(toUser: profileUsername) { (error) in
            self.profileOptionsButton.isEnabled = true
            self.profileType = Constants.ProfileTypes.PendingFriend
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
        }
    }
    
    func cancelFriendRequest() {
        
        guard let profileUsername = self.profileInfo?["username"] else {
            return
        }
        
        profileOptionsButton.isEnabled = false
        
        // Handle cancel friend request
        IgnusBackend.cancelFriendRequest(toUser: profileUsername) { (error) in
            self.profileOptionsButton.isEnabled = true
            self.profileType = Constants.ProfileTypes.User
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
        }
    }
    
    func respondToFriendRequest(_ response: String) {
        guard let profileUsername = self.profileInfo?["username"] else {
            return
        }
        
        profileOptionsButton.isEnabled = false
        
        // Handles the friend request
        IgnusBackend.handleFriendRequest(fromUser: profileUsername, response: response) { (error) in
            self.profileOptionsButton.isEnabled = true
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
            
            if response == Constants.FriendRequestResponses.Accepted {
                self.profileType = Constants.ProfileTypes.Friend
            }
            else if response == Constants.FriendRequestResponses.Declined {
                self.profileType = Constants.ProfileTypes.User
            }
        }
    }
    
    func unfriend() {
        guard let profileUsername = self.profileInfo?["username"] else {
            return
        }
        
        self.profileOptionsButton.isEnabled = false
        
        // Handles the unfriend
        IgnusBackend.unfriendUser(withUsername: profileUsername) { (error) in
            self.profileOptionsButton.isEnabled = true
            self.profileType = Constants.ProfileTypes.User
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
        }
    }
    
    func requestPayment() {
        performSegue(withIdentifier: "Request Payment", sender: nil)
    }
    
    func message() {
        performSegue(withIdentifier: "Compose Message", sender: nil)
    }
    
    // MARK: - Pie chart data source methods
    
    func numberOfSlices(in pieChart: XYPieChart!) -> UInt {
        return 3
    }
    
    func pieChart(_ pieChart: XYPieChart!, colorForSliceAt index: UInt) -> UIColor! {
        if index == 0 {
            return UIColor(red: 85/255.0, green: 205/255.0, blue: 41/255.0, alpha: 1.0)
        }
        else if index == 1 {
            return UIColor.yellow
        }
        else if index == 2 {
            return UIColor.red
        }
        else {
            return UIColor.white
        }
    }
    
    func pieChart(_ pieChart: XYPieChart!, valueForSliceAt index: UInt) -> CGFloat {
        if index == 0 {
            return CGFloat(ratingProportion(forRating: Constants.PaymentRating.Green))
        }
        else if index == 1 {
            return CGFloat(ratingProportion(forRating: Constants.PaymentRating.Yellow))
        }
        else if index == 2 {
            return CGFloat(ratingProportion(forRating: Constants.PaymentRating.Red))
        }
        else {
            return 0
        }
    }
    
    // MARK: - Pie chart delegate methods
    func pieChart(_ pieChart: XYPieChart!, didSelectSliceAt index: UInt) {
        let ratingPercentage = self.pieChart(pieChart, valueForSliceAt: index) * 100.0
        
        // Determines description text
        var text = ""
        if index == 0 {
            text = "positive"
        }
        else if index == 1 {
            text = "neutral"
        }
        else if index == 2 {
            text = "negative"
        }
        
        // Sets labels with animation
        UIView.transition(with: chartPercentageLabel, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
            self.chartPercentageLabel.text = String(format: "%.1lf%%", ratingPercentage)
        }, completion: nil)
        UIView.transition(with: chartPercentageDescription, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
            self.chartPercentageDescription.text = text
        }, completion: nil)
    }
    
    func pieChart(_ pieChart: XYPieChart!, didDeselectSliceAt index: UInt) {
        let ratingPercentage = self.pieChart(pieChart, valueForSliceAt: 0) * 100.0
        
        UIView.transition(with: chartPercentageLabel, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
            self.chartPercentageLabel.text = String(format: "%.1lf%%", ratingPercentage)
        }, completion: nil)
        UIView.transition(with: chartPercentageDescription, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
            self.chartPercentageDescription.text = "positive"
        }, completion: nil)
    }

    // MARK: - Transitioning delegate methods
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is ProfileOptionsViewController {
            var buttonCenter = self.view.convert(profileOptionsButton.center, from: profileCoverView)
            if let splitVC = self.splitViewController {
                buttonCenter = splitVC.view.convert(buttonCenter, from: self.view)
            }
            return ProfileOptionsAnimation(presenting: true, initialPoint: buttonCenter)
        }
        else if let navVC = presented as? UINavigationController {
            if navVC.topViewController is RequestPaymentTableViewController {
                return RequestPaymentTransition(presenting: true)
            }
            else if navVC.topViewController is MessageViewController {
                return MessageTransition(presenting: true)
            }
        }
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is ProfileOptionsViewController {
            var buttonCenter = self.view.convert(profileOptionsButton.center, from: profileCoverView)
            if let splitVC = self.splitViewController {
                buttonCenter = splitVC.view.convert(buttonCenter, from: self.view)
            }
            return ProfileOptionsAnimation(presenting: false, initialPoint: buttonCenter)
        }
        else if let navVC = dismissed as? UINavigationController {
            if navVC.topViewController is RequestPaymentTableViewController {
                return requestPaymentDismissalTransition
            }
            else if navVC.topViewController is MessageViewController {
                return messageDismissalTransition
            }
        }
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented is ProfileOptionsViewController {
            return ProfileOptionsPresentation(presentedViewController: presented, presenting: presenting)
        }
        else if let navVC = presented as? UINavigationController {
            if navVC.topViewController is RequestPaymentTableViewController {
                return RequestPaymentPresentation(presentedViewController: presented, presenting: presenting)
            }
            else if navVC.topViewController is MessageViewController {
                return MessagePresentation(presentedViewController: presented, presenting: presenting)
            }
        }
        return nil
    }
    
    // MARK: - Image picker controller delegate methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 18)!]
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 234/255, green: 51/255, blue: 56/255, alpha: 1.0), NSFontAttributeName: UIFont(name: "Gotham-Book", size: 14)!], for: UIControlState())
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 234/255, green: 51/255, blue: 56/255, alpha: 1.0), NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 17)!], for: UIControlState())
        
        picker.dismiss(animated: true, completion: nil)
        
        guard
            let editedImage = (editingInfo[UIImagePickerControllerEditedImage] as? UIImage ?? editingInfo[UIImagePickerControllerOriginalImage] as? UIImage),
            let imageData = UIImageJPEGRepresentation(editedImage, 0.7)
            else {
                return
        }
        
        if picker === profilePickerVC {
            // Creates a loading indicator
            let loadingAlert = UIAlertController(title: "Changing profile picture...", message: "\n\n", preferredStyle: .alert)
            let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            loadingIndicatorView.color = UIColor.gray
            loadingIndicatorView.startAnimating()
            loadingIndicatorView.center = CGPoint(x: 135, y: 65.5)
            loadingAlert.view.addSubview(loadingIndicatorView)
            present(loadingAlert, animated: true, completion: nil)
            
            // Uploads new profile photo to Firebase
            IgnusBackend.setCurrentUserProfileImage(withImageData: imageData, with: { (error, metadata) in
                if error == nil {
                    loadingAlert.dismiss(animated: true, completion: nil)
                    
                    // Sets up user info for notification, which updates profile/cover images
                    var userInfo = [String: UIImage]()
                    userInfo[Constants.UserInfoKeys.Profile] = image
                    userInfo[Constants.UserInfoKeys.Cover] = self.coverImageView.image
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadProfileImages), object: nil, userInfo: userInfo)
                }
            })
        }
        else if picker === coverPickerVC {
            let loadingAlert = UIAlertController(title: "Changing cover photo...", message: "\n\n", preferredStyle: .alert)
            let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            loadingIndicatorView.color = UIColor.gray
            loadingIndicatorView.startAnimating()
            loadingIndicatorView.center = CGPoint(x: 135, y: 65.5)
            loadingAlert.view.addSubview(loadingIndicatorView)
            present(loadingAlert, animated: true, completion: nil)
            
            // Uploads new cover photo to Firebase
            IgnusBackend.setCurrentUserCoverPhoto(withImageData: imageData, with: { (error, metadata) in
                if error == nil {
                    loadingAlert.dismiss(animated: true, completion: nil)
                    
                    // Sets up user info for notification, which updates profile/cover images
                    var userInfo = [String: UIImage]()
                    userInfo[Constants.UserInfoKeys.Profile] = self.profileImageView.image
                    userInfo[Constants.UserInfoKeys.Cover] = image
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadProfileImages), object: nil, userInfo: userInfo)
                }
            })
        }
        
        profilePickerVC = nil
        coverPickerVC = nil
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 18)!]
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 234/255, green: 51/255, blue: 56/255, alpha: 1.0), NSFontAttributeName: UIFont(name: "Gotham-Book", size: 14)!], for: UIControlState())
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 234/255, green: 51/255, blue: 56/255, alpha: 1.0), NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 17)!], for: UIControlState())
        
        picker.dismiss(animated: true, completion: nil)
        
        profilePickerVC = nil
        coverPickerVC = nil
    }
    
    // MARK: - Message view controller delegate methods
    
    func canceledNewMessage(messageVC: MessageViewController) {
        messageDismissalTransition = MessageTransition(presenting: false)
        messageVC.dismiss(animated: true, completion: nil)
    }
    
    func canceledViewMessage(messageVC: MessageViewController) {
        messageVC.dismiss(animated: true, completion: nil)
    }
    
    func sentNewMessage(messageVC: MessageViewController) {
        messageDismissalTransition = MessageTransition(presenting: false, sentMessage: true)
        messageVC.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Request payment table view controller delegate methods
    
    func sentNewPaymentRequest(requestPaymentTVC: RequestPaymentTableViewController) {
        requestPaymentDismissalTransition = RequestPaymentTransition(presenting: false, sentRequest: true)
        requestPaymentTVC.dismiss(animated: true, completion: nil)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadPayments), object: nil)
    }
    
    func canceledNewPaymentRequest(requestPaymentTVC: RequestPaymentTableViewController) {
        requestPaymentDismissalTransition = RequestPaymentTransition(presenting: false)
        requestPaymentTVC.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Show Profile Options" {
            let profileOptionsVC = segue.destination as! ProfileOptionsViewController
            profileOptionsVC.profileType = self.profileType
            profileOptionsVC.delegate = self
            profileOptionsVC.modalPresentationStyle = .custom
            profileOptionsVC.transitioningDelegate = self
        }
        else if segue.identifier == "Request Payment" {
            if let navVC = segue.destination as? UINavigationController {
                navVC.transitioningDelegate = self
                navVC.modalPresentationStyle = .custom
                
                if let requestPaymentTVC = navVC.topViewController as? RequestPaymentTableViewController {
                    requestPaymentTVC.delegate = self
                    
                    if let profileUsername = self.profileInfo?["username"] {
                        requestPaymentTVC.recipient = profileUsername
                    }
                }
            }
        }
        else if segue.identifier == "Compose Message" {
            if let navVC = segue.destination as? UINavigationController {
                navVC.transitioningDelegate = self
                navVC.modalPresentationStyle = .custom
                
                if let messageVC = navVC.topViewController as? MessageViewController {
                    messageVC.delegate = self
                    
                    if let profileUsername = self.profileInfo?["username"] {
                        messageVC.defaultRecipient = profileUsername
                    }
                }
            }
        }
    }
}
