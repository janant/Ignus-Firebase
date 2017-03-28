//
//  PaymentsViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/27/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit
import Firebase

class PaymentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, RequestPaymentTableViewControllerDelegate {
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        paymentsCategoryChanged(paymentsCategorySegmentedControl)
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
            
            cell.backgroundColor = UIColor.clear
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.gray
            cell.selectedBackgroundView = backgroundView
            
            return cell
        }
        else if paymentsCategorySegmentedControl.selectedSegmentIndex == Constants.PaymentsScope.Completed {
            let cell = paymentsTable.dequeueReusableCell(withIdentifier: "Completed Cell", for: indexPath)
            
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
    
    // MARK: - RequestPaymentTableViewControllerDelegate methods
    
    func sentNewPaymentRequest(requestPaymentTVC: RequestPaymentTableViewController, requestData: [String : Any]) {
        reloadData()
        
        requestPaymentDismissalTransition = RequestPaymentTransition(presenting: false, sentMessage: true)
        requestPaymentTVC.dismiss(animated: true, completion: nil)
    }
    
    func canceledNewPaymentRequest(requestPaymentTVC: RequestPaymentTableViewController) {
        requestPaymentDismissalTransition = RequestPaymentTransition(presenting: false, sentMessage: false)
        requestPaymentTVC.dismiss(animated: true, completion: nil)
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
    }
    

}
