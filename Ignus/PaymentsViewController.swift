//
//  PaymentsViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/27/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit

class PaymentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate {
    
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
                
                // Resets current payments data
                self.activePaymentsSent        = [[String: Any]]()
                self.activePaymentsReceived    = [[String: Any]]()
                self.completedPaymentsSent     = [[String: Any]]()
                self.completedPaymentsReceived = [[String: Any]]()
                
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
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if friendsCategorySegmentedControl.selectedSegmentIndex == Constants.FriendsScope.FriendRequests {
//            switch section {
//            case 0:
//                if friendRequestsReceived.count > 0 {
//                    return "Friend Requests"
//                }
//                else {
//                    return "Pending Requests"
//                }
//            case 1:
//                return "Pending Requests"
//            default:
//                return nil
//            }
//        }
//        return nil
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if friendsCategorySegmentedControl.selectedSegmentIndex == Constants.FriendsScope.FriendRequests {
//            return 25
//        }
//        return 0
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    // MARK: - Table view delegate methods
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {
            return
        }
        view.tintColor = #colorLiteral(red: 0.1215686275, green: 0.1215686275, blue: 0.1215686275, alpha: 1)
        headerView.textLabel?.textColor = UIColor.white
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
