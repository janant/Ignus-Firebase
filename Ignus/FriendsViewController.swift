//
//  FriendsViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/29/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit
import Firebase

protocol FriendsViewControllerAddFriendsDelegate: class {
    func didTapAddFriendsButton()
    func dismissAddFriends()
}

class FriendsViewController: UIViewController, AddFriendsViewControllerDelegate {
    
    // Main views
    @IBOutlet weak var friendsTable: UITableView!
    @IBOutlet weak var noFriendsStackView: UIStackView!
    @IBOutlet weak var loadingFriendsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var friendsCategorySegmentedControl: UISegmentedControl!
    
    // No friends labels, text changes when segmented control value changes.
    @IBOutlet weak var noFriendsTitle: UILabel!
    @IBOutlet weak var noFriendsDetail: UILabel!
    
    @IBOutlet var friendsNavItemSegmentedControl: UISegmentedControl!
    @IBOutlet var friendsNavItemAddButton: UIBarButtonItem!
    @IBOutlet weak var addFriendsContainerView: UIView!
    
    var friends                 = [String]()
    var friendRequestsSent      = [String]()
    var friendRequestsReceived  = [String]()
    
    let refreshControl = UIRefreshControl()
    
    weak var addFriendsDelegate: FriendsViewControllerAddFriendsDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        friendsCategoryChanged(friendsCategorySegmentedControl)
        if let selectedIndex = friendsTable.indexPathForSelectedRow {
            friendsTable.deselectRow(at: selectedIndex, animated: true)
        }
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
        
        var noFriendsTitleText: String!
        var noFriendsDetailText: String!
        
        if selectedIndex == Constants.FriendsScope.MyFriends {
            // Gets data if there are no friends
            if friends.count == 0 && !self.loadingFriendsActivityIndicator.isAnimating {
                // Shows the user that friends are loading
                self.loadingFriendsActivityIndicator.startAnimating()
                self.loadingFriendsActivityIndicator.alpha = 1.0
                self.noFriendsStackView.alpha = 0.0
                self.friendsTable.alpha = 0.0
                
                // Get friends from IgnusBackend
                IgnusBackend.getFriends(with: { (friendsData) in
                    self.friends = friendsData
                    
                    // If there are no friends, display this to the user
                    if self.friends.count == 0 {
                        UIView.animate(withDuration: 0.25, animations: {
                            self.loadingFriendsActivityIndicator.alpha = 0.0
                            self.noFriendsStackView.alpha = 1.0
                        }, completion: { (completed) in
                            self.loadingFriendsActivityIndicator.stopAnimating()
                        })
                    }
                    else { // There are friends, displays friends in the table
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
            
            // Sets appropriate text
            noFriendsTitleText = Constants.NoFriendsLabelText.FriendsTitle
            noFriendsDetailText = Constants.NoFriendsLabelText.FriendsDetail
        }
        else if selectedIndex == Constants.FriendsScope.FriendRequests {
            // Gets data if there are no requests
            if (friendRequestsSent.count == 0 || friendRequestsReceived.count == 0)
                && !self.loadingFriendsActivityIndicator.isAnimating {
                
                // Shows the user that requests are loading
                self.loadingFriendsActivityIndicator.startAnimating()
                self.loadingFriendsActivityIndicator.alpha = 1.0
                self.noFriendsStackView.alpha = 0.0
                self.friendsTable.alpha = 0.0
                
                // Gets requests from IgnusBackend
                IgnusBackend.getFriendRequests(with: { (friendRequestsData) in
                    // Saves friend request data, if available
                    if let friendRequestsSentData = friendRequestsData["sent"] {
                        self.friendRequestsSent = friendRequestsSentData
                    }
                    if let friendRequestsReceivedData = friendRequestsData["received"] {
                        self.friendRequestsReceived = friendRequestsReceivedData
                    }
                    
                    // If no friend requests, display this to the user
                    if self.friendRequestsSent.count == 0 && self.friendRequestsReceived.count == 0 {
                        // Displays to the user that there are no requests, with animation
                        UIView.animate(withDuration: 0.25, animations: {
                            self.loadingFriendsActivityIndicator.alpha = 0.0
                            self.noFriendsStackView.alpha = 1.0
                        }, completion: { (completed) in
                            self.loadingFriendsActivityIndicator.stopAnimating()
                        })
                    }
                    else { // There are requests, displays requests in the table
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
            
            // Sets appropriate text
            noFriendsTitleText = Constants.NoFriendsLabelText.RequestsTitle
            noFriendsDetailText = Constants.NoFriendsLabelText.RequestsDetail
        }
        
        // Sets the text labels. Because they are attributed text labels, it is a little more complicated
        
        guard
            let noFriendsTitleAttributedString = noFriendsTitle.attributedText,
            let noFriendsDetailAttributedString = noFriendsDetail.attributedText
        else {
            return
        }
        
        let noFriendsTitleMutableAttributedString = NSMutableAttributedString(attributedString: noFriendsTitleAttributedString)
        let noFriendsDetailMutableAttributedString = NSMutableAttributedString(attributedString: noFriendsDetailAttributedString)
        
        noFriendsTitleMutableAttributedString.mutableString.setString(noFriendsTitleText)
        noFriendsDetailMutableAttributedString.mutableString.setString(noFriendsDetailText)
        
        noFriendsTitle.attributedText = noFriendsTitleMutableAttributedString
        noFriendsDetail.attributedText = noFriendsDetailMutableAttributedString
    }
    
    // MARK: - AddFriendsViewControllerDelegate methods
    
    func didSelectUser(withProfileData profileData: [String : String]) {
        
        IgnusBackend.getFriendRequests(with: { (friendRequests) in
            
            let senderData: [String : Any] =
                [Constants.ProfileSegueSenderKeys.ProfileData:          profileData,
                 Constants.ProfileSegueSenderKeys.FriendRequestsData:   friendRequests]
            
            self.performSegue(withIdentifier: "Show Profile Detail", sender: senderData)
            
        })
        
    }

    @IBAction func tappedAddFriends(_ sender: Any) {
        self.addFriendsDelegate?.didTapAddFriendsButton()
        
        if let addFriendsVC = self.addFriendsDelegate as? AddFriendsViewController {
            let fadeTextTransition = CATransition()
            fadeTextTransition.duration = 0.5
            fadeTextTransition.type = kCATransitionFade
            
            self.navigationController?.navigationBar.layer.add(fadeTextTransition, forKey: "fadeText")
            self.navigationItem.titleView = nil
            self.navigationItem.title = "Add Friends"
            self.navigationItem.rightBarButtonItem = addFriendsVC.navigationItem.rightBarButtonItem
            self.navigationController?.navigationBar.layer.removeAnimation(forKey: "fadeText")
            
            addFriendsContainerView.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func dismissAddFriends(segue: UIStoryboardSegue) {
        self.addFriendsDelegate?.dismissAddFriends()
        
        let fadeTextTransition = CATransition()
        fadeTextTransition.duration = 0.5
        fadeTextTransition.type = kCATransitionFade
        self.navigationController?.navigationBar.layer.add(fadeTextTransition, forKey: "fadeText")
        
        self.navigationItem.title = nil
        self.navigationItem.titleView = friendsNavItemSegmentedControl
        self.navigationItem.rightBarButtonItem = friendsNavItemAddButton
        
        self.navigationController?.navigationBar.layer.removeAnimation(forKey: "fadeText")
        
        addFriendsContainerView.isUserInteractionEnabled = false
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Show Profile Detail" {
            guard
                let profileNavVC = segue.destination as? UINavigationController,
                let profileVC = profileNavVC.topViewController as? ProfileViewController,
            
                let senderData = sender as? [String : Any],
                let profileData = senderData[Constants.ProfileSegueSenderKeys.ProfileData] as? [String : String],
                let friendRequestsData = senderData[Constants.ProfileSegueSenderKeys.FriendRequestsData] as? [String : [String]]
            else {
                return
            }
            
            profileVC.profileInfo = profileData
            profileVC.friendRequests = friendRequestsData
            profileVC.friends = friends
        }
        else if segue.identifier == "Add Friends" {
            guard
                let addFriendsNavVC = segue.destination as? UINavigationController,
                let addFriendsVC = addFriendsNavVC.topViewController as? AddFriendsViewController
            else {
                return
            }
            
            addFriendsVC.delegate = self
            self.addFriendsDelegate = addFriendsVC
        }
    }
}
