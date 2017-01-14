//
//  ProfileViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/30/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIViewControllerTransitioningDelegate, ProfileOptionsViewControllerDelegate {
    
    @IBOutlet weak var selectUserLabel: UILabel!
    @IBOutlet weak var profileView: UIView!
    
    // Profile header views
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    
    // Needed for profile options view controller animation
    @IBOutlet weak var profileOptionsButton: UIButton!
    @IBOutlet weak var profileInfoView: UIView!
    
    var profileInfo: [String: String]?
    var friendRequests: [String: [String]]?
    var friends: [String]?
    
    var profileType: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Hides/shows views based on available information
        guard let profileInfo = profileInfo else {
            profileView.isHidden = true
            return
        }
        selectUserLabel.isHidden = true
        
        guard
            let friendRequests = friendRequests,
            let friends = friends
        else {
            return
        }
        
        // Gets user information
        guard
            let currentUser = FIRAuth.auth()?.currentUser,
            let currentUserUsername = currentUser.displayName,
            
            let firstName = profileInfo["firstName"],
            let lastName = profileInfo["lastName"],
            let username = profileInfo["username"]
        else {
            return
        }
        
        let friendRequestsSent = friendRequests["sent"] ?? [String]()
        let friendRequestsReceived = friendRequests["received"] ?? [String]()
        
        // Gets profile and cover photo references from Firebase
        let storageRef = FIRStorage.storage().reference()
        let profileRef = storageRef.child("User_Pictures/\(username)/profile.jpg")
        let coverRef = storageRef.child("User_Pictures/\(username)/cover.jpg")
        
        // Loads profile picture
        profileRef.data(withMaxSize: INT64_MAX, completion: { (data, error) in
            if error == nil && data != nil {
                UIView.transition(with: self.profileImageView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.profileImageView.image = UIImage(data: data!)
                }, completion: nil)
            }
        })
        // Loads cover picture
        coverRef.data(withMaxSize: INT64_MAX, completion: { (data, error) in
            if error == nil && data != nil {
                UIView.transition(with: self.coverImageView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.coverImageView.image = UIImage(data: data!)
                }, completion: nil)
            }
        })
        
        // Fades in new data
        UIView.transition(with: self.nameLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.nameLabel.text = "\(firstName) \(lastName)"
        }, completion: nil)
        UIView.transition(with: self.usernameLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.usernameLabel.text = username
        }, completion: nil)
        
        // Determines the profile type of the user
        if username == currentUserUsername {
            profileType = Constants.ProfileTypes.CurrentUser
        }
        else if friends.contains(username) {
            profileType = Constants.ProfileTypes.Friend
        }
        else if friendRequestsSent.contains(username) {
            profileType = Constants.ProfileTypes.PendingFriend
        }
        else if friendRequestsReceived.contains(username) {
            profileType = Constants.ProfileTypes.RequestedFriend
        }
        else {
            profileType = Constants.ProfileTypes.User
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ProfileOptionsViewControllerDelegate methods
    
    func changeProfilePicture() {
        print("should change profile picture")
    }
    
    func changeCoverPicture() {
        print("should change cover picture")
    }
    
    func sendFriendRequest() {
        profileOptionsButton.isEnabled = false
        
        IgnusBackend.getFriendRequests { (myRequests) in
            guard
                let currentUser = FIRAuth.auth()?.currentUser,
                let myUsername = currentUser.displayName,
                let profileUsername = self.profileInfo?["username"]
            else {
                self.profileOptionsButton.isEnabled = true
                return
            }
            
            var mySentRequests = myRequests["sent"] ?? [String]()
            var profileReceivedRequests = self.friendRequests?["received"] ?? [String]()
            
            mySentRequests.insert(profileUsername, at: 0)
            profileReceivedRequests.insert(myUsername, at: 0)
            
            let databaseRef = FIRDatabase.database().reference().child("friendRequests")
            databaseRef.child("\(myUsername)/sent").setValue(mySentRequests, withCompletionBlock: { (error, reference) in
                if error == nil {
                    databaseRef.child("\(profileUsername)/received").setValue(profileReceivedRequests, withCompletionBlock: { (error, reference) in
                        if error == nil {
                            self.profileOptionsButton.isEnabled = true
                            self.profileType = Constants.ProfileTypes.PendingFriend
                        }
                    })
                }
            })
        }
    }
    
    func cancelFriendRequest() {
        profileOptionsButton.isEnabled = false
        
        IgnusBackend.getFriendRequests { (myRequests) in
            guard
                let currentUser = FIRAuth.auth()?.currentUser,
                let myUsername = currentUser.displayName,
                let profileUsername = self.profileInfo?["username"]
                else {
                    self.profileOptionsButton.isEnabled = true
                    return
            }
            
            var mySentRequests = myRequests["sent"] ?? [String]()
            var profileReceivedRequests = self.friendRequests?["received"] ?? [String]()
            
            mySentRequests = mySentRequests.filter { $0 != profileUsername }
            profileReceivedRequests = profileReceivedRequests.filter { $0 != myUsername }
            
            let databaseRef = FIRDatabase.database().reference().child("friendRequests")
            databaseRef.child("\(myUsername)/sent").setValue(mySentRequests)
            databaseRef.child("\(profileUsername)/received").setValue(profileReceivedRequests)
            
            self.profileOptionsButton.isEnabled = true
            self.profileType = Constants.ProfileTypes.User
        }
    }
    
    func respondToFriendRequest(_ response: String) {
        profileOptionsButton.isEnabled = false
        
        // Deletes the friend requests first
        IgnusBackend.getFriendRequests { (myRequests) in
            guard
                let currentUser = FIRAuth.auth()?.currentUser,
                let myUsername = currentUser.displayName,
                let profileUsername = self.profileInfo?["username"]
                else {
                    self.profileOptionsButton.isEnabled = true
                    return
            }
            
            var myReceivedRequests = myRequests["received"] ?? [String]()
            var profileSentRequests = self.friendRequests?["sent"] ?? [String]()
            
            myReceivedRequests = myReceivedRequests.filter { $0 != profileUsername }
            profileSentRequests = profileSentRequests.filter { $0 != myUsername }
            
            let databaseRef = FIRDatabase.database().reference()
            databaseRef.child("friendRequests/\(myUsername)/received").setValue(myReceivedRequests)
            databaseRef.child("friendRequests/\(profileUsername)/sent").setValue(profileSentRequests)
            
            // Now adds as a friend, if friend request was accepted
            if response == Constants.FriendRequestResponses.Accepted {
                IgnusBackend.getFriends(with: { (myFriendsData) in
                    
                    var myFriends = myFriendsData
                    var profileFriends = self.friends ?? [String]()
                    
                    myFriends.insert(profileUsername, at: 0)
                    profileFriends.insert(myUsername, at: 0)
                    
                    databaseRef.child("friends/\(myUsername)").setValue(myFriends)
                    databaseRef.child("friends/\(profileUsername)").setValue(profileFriends)
                    
                    self.profileOptionsButton.isEnabled = true
                    self.profileType = Constants.ProfileTypes.Friend
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
                })
            }
            else {
                self.profileOptionsButton.isEnabled = true
                self.profileType = Constants.ProfileTypes.User
            }
        }
    }
    
    func unfriend() {
        // Removes friends
        IgnusBackend.getFriends { (myFriendsData) in
            guard
                let currentUser = FIRAuth.auth()?.currentUser,
                let myUsername = currentUser.displayName,
                let profileUsername = self.profileInfo?["username"]
                else {
                    self.profileOptionsButton.isEnabled = true
                    return
            }
            
            var myFriends = myFriendsData
            var profileFriends = self.friends ?? [String]()
            
            myFriends = myFriends.filter { $0 != profileUsername }
            profileFriends = profileFriends.filter { $0 != myUsername }
            
            print(myFriends)
            print(profileFriends)
            
            let databaseRef = FIRDatabase.database().reference().child("friends")
            databaseRef.child("\(myUsername)").setValue(myFriends)
            databaseRef.child("\(profileUsername)").setValue(profileFriends)
            
            self.profileType = Constants.ProfileTypes.User
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
        }
    }
    
    func requestPayment() {
        // TODO
        print("should request payment")
    }
    
    func message() {
        // TODO
        print("should message")
    }

    // MARK: - Transitioning delegate methods
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is ProfileOptionsViewController {
            let buttonCenter = self.view.convert(profileOptionsButton.center, from: profileInfoView)
            return ProfileOptionsAnimation(presenting: true, initialPoint: buttonCenter)
        }
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is ProfileOptionsViewController {
            let buttonCenter = self.view.convert(profileOptionsButton.center, from: profileInfoView)
            return ProfileOptionsAnimation(presenting: false, initialPoint: buttonCenter)
        }
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented is ProfileOptionsViewController {
            return ProfileOptionsPresentation(presentedViewController: presented, presenting: presenting)
        }
        return nil
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
    }
}
