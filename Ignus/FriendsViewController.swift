//
//  FriendsViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/29/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController {
    
    // Main views
    @IBOutlet weak var friendsTable: UITableView!
    @IBOutlet weak var noFriendsStackView: UIStackView!
    @IBOutlet weak var loadingFriendsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var friendsCategorySegmentedControl: UISegmentedControl!
    
    // No friends labels, text changes when segmented control value changes.
    @IBOutlet weak var noFriendsTitle: UILabel!
    @IBOutlet weak var noFriendsDetail: UILabel!
    
    
    var friends = [[String: String]]()
    var requests = [[String: Any]]()
    
    let refreshControl = UIRefreshControl()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        friendsCategoryChanged(friendsCategorySegmentedControl)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Sets up the table
        friendsTable.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark))
        friendsTable.backgroundView = nil
        refreshControl.addTarget(self, action: #selector(MessagesViewController.reloadData), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        friendsTable.addSubview(refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func friendsCategoryChanged(_ sender: Any) {
        guard let selectedIndex = (sender as? UISegmentedControl)?.selectedSegmentIndex else {
            return
        }
        
        guard
            let currentUser = FIRAuth.auth()?.currentUser,
            let username = currentUser.displayName
            else {
                return
        }
        
        if selectedIndex == Constants.FriendsScope.MyFriends {
            // Gets data if there are no friends
            if friends.count == 0 && !self.loadingFriendsActivityIndicator.isAnimating {
                // Shows the user that friends are loading
                self.loadingFriendsActivityIndicator.startAnimating()
                self.loadingFriendsActivityIndicator.alpha = 1.0
                self.noFriendsStackView.alpha = 0.0
                self.friendsTable.alpha = 0.0
                
                // Gets friends from Firebase
                let databaseRef = FIRDatabase.database().reference().child("friends").child(username)
                var handle: UInt = 0
                handle = databaseRef.observe(.value, with: { (snapshot) in
                    
                    databaseRef.removeObserver(withHandle: handle)
                    guard let friendsData = snapshot.value as? [[String: String]] else {
                        // Displays to the user that there are no friends, with animation
                        UIView.animate(withDuration: 0.25, animations: {
                            self.loadingFriendsActivityIndicator.alpha = 0.0
                            self.noFriendsStackView.alpha = 1.0
                        }, completion: { (completed) in
                            self.loadingFriendsActivityIndicator.stopAnimating()
                        })
                        return
                    }
                    
                    if friendsData.count == 0 {
                        // Displays to the user that there are no friends, with animation
                        UIView.animate(withDuration: 0.25, animations: {
                            self.loadingFriendsActivityIndicator.alpha = 0.0
                            self.noFriendsStackView.alpha = 1.0
                        }, completion: { (completed) in
                            self.loadingFriendsActivityIndicator.stopAnimating()
                        })
                    }
                    else { // There are friends, displays friends in the table
                        self.friends = friendsData
                        self.friendsTable.reloadData()
                        
                        UIView.animate(withDuration: 0.25, animations: {
                            self.loadingFriendsActivityIndicator.alpha = 0.0
                            self.friendsTable.alpha = 1.0
                        }, completion: { (completed) in
                            self.loadingFriendsActivityIndicator.stopAnimating()
                            self.friendsTable.isUserInteractionEnabled = true
                        })
                    }
                    
                })
            }
            
            noFriendsTitle.text = Constants.NoFriendsLabelText.FriendsTitle
            noFriendsDetail.text = Constants.NoFriendsLabelText.FriendsDetail
        }
        else if selectedIndex == Constants.FriendsScope.FriendRequests {
            // Gets data if there are no requests
            if requests.count == 0 && !self.loadingFriendsActivityIndicator.isAnimating {
                // Shows the user that requests are loading
                self.loadingFriendsActivityIndicator.startAnimating()
                self.loadingFriendsActivityIndicator.alpha = 1.0
                self.noFriendsStackView.alpha = 0.0
                self.friendsTable.alpha = 0.0
                
                // Gets requests from Firebase
                let databaseRef = FIRDatabase.database().reference().child("friendRequests").child(username).child("received")
                var handle: UInt = 0
                handle = databaseRef.observe(.value, with: { (snapshot) in
                    
                    databaseRef.removeObserver(withHandle: handle)
                    guard let requestsData = snapshot.value as? [[String: Any]] else {
                        // Displays to the user that there are no requests, with animation
                        UIView.animate(withDuration: 0.25, animations: {
                            self.loadingFriendsActivityIndicator.alpha = 0.0
                            self.noFriendsStackView.alpha = 1.0
                        }, completion: { (completed) in
                            self.loadingFriendsActivityIndicator.stopAnimating()
                        })
                        return
                    }
                    
                    if requestsData.count == 0 {
                        // Displays to the user that there are no requests, with animation
                        UIView.animate(withDuration: 0.25, animations: {
                            self.loadingFriendsActivityIndicator.alpha = 0.0
                            self.noFriendsStackView.alpha = 1.0
                        }, completion: { (completed) in
                            self.loadingFriendsActivityIndicator.stopAnimating()
                        })
                    }
                    else { // There are requests, displays requests in the table
                        self.requests = requestsData
                        self.friendsTable.reloadData()
                        
                        UIView.animate(withDuration: 0.25, animations: {
                            self.loadingFriendsActivityIndicator.alpha = 0.0
                            self.friendsTable.alpha = 1.0
                        }, completion: { (completed) in
                            self.loadingFriendsActivityIndicator.stopAnimating()
                            self.friendsTable.isUserInteractionEnabled = true
                        })
                    }
                    
                })
            }
            
            noFriendsTitle.text = Constants.NoFriendsLabelText.RequestsTitle
            noFriendsDetail.text = Constants.NoFriendsLabelText.RequestsDetail
        }
    
    }

    
    // MARK: - Navigation
    
    @IBAction func dismissAddFriends(segue: UIStoryboardSegue) {
        
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
