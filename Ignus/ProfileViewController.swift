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
    var currentUserFriendRequests: [String: [String]]?
    var currentUserFriends: [String]?
    
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
            let myFriendRequests = currentUserFriendRequests,
            let myFriends = currentUserFriends
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
        
        let myFriendRequestsSent = myFriendRequests["sent"] ?? [String]()
        let myFriendRequestsReceived = myFriendRequests["received"] ?? [String]()
        
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
        else if myFriends.contains(username) {
            profileType = Constants.ProfileTypes.Friend
        }
        else if myFriendRequestsSent.contains(username) {
            profileType = Constants.ProfileTypes.PendingFriend
        }
        else if myFriendRequestsReceived.contains(username) {
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
        guard
            let currentUser = FIRAuth.auth()?.currentUser,
            let myUsername = currentUser.displayName,
            let profileUsername = self.profileInfo?["username"]
        else {
            return
        }
        
        profileOptionsButton.isEnabled = false
        
        // Gets friend requests data for profile user
        let databaseRef = FIRDatabase.database().reference().child("friendRequests")
        databaseRef.child("\(profileUsername)/received").observeSingleEvent(of: .value, with: { (snapshot) in
            var profileReceivedRequests = (snapshot.value as? [String]) ?? [String]()
            var mySentRequests = self.currentUserFriendRequests?["sent"] ?? [String]()
            
            mySentRequests.insert(profileUsername, at: 0)
            profileReceivedRequests.insert(myUsername, at: 0)
            
            databaseRef.child("\(myUsername)/sent").setValue(mySentRequests, withCompletionBlock: { (error, database) in
                databaseRef.child("\(profileUsername)/received").setValue(profileReceivedRequests, withCompletionBlock: { (error2, database2) in
                    self.profileOptionsButton.isEnabled = true
                    self.profileType = Constants.ProfileTypes.PendingFriend
                    
                    self.currentUserFriendRequests?["sent"] = mySentRequests
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
                })
            })
        })
    }
    
    func cancelFriendRequest() {
        guard
            let currentUser = FIRAuth.auth()?.currentUser,
            let myUsername = currentUser.displayName,
            let profileUsername = self.profileInfo?["username"]
            else {
                return
        }
        
        profileOptionsButton.isEnabled = false
        
        // Gets friend requests data for profile user
        let databaseRef = FIRDatabase.database().reference().child("friendRequests")
        databaseRef.child("\(profileUsername)/received").observeSingleEvent(of: .value, with: { (snapshot) in
            var profileReceivedRequests = (snapshot.value as? [String]) ?? [String]()
            var mySentRequests = self.currentUserFriendRequests?["sent"] ?? [String]()
            
            
            mySentRequests = mySentRequests.filter { $0 != profileUsername }
            profileReceivedRequests = profileReceivedRequests.filter { $0 != myUsername }
            
            databaseRef.child("\(myUsername)/sent").setValue(mySentRequests, withCompletionBlock: { (error, database) in
                databaseRef.child("\(profileUsername)/received").setValue(profileReceivedRequests, withCompletionBlock: { (error2, database2) in
                    self.profileOptionsButton.isEnabled = true
                    self.profileType = Constants.ProfileTypes.User
                    
                    self.currentUserFriendRequests?["sent"] = mySentRequests
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
                })
            })
        })
    }
    
    func respondToFriendRequest(_ response: String) {
        guard
            let currentUser = FIRAuth.auth()?.currentUser,
            let myUsername = currentUser.displayName,
            let profileUsername = self.profileInfo?["username"]
            else {
                return
        }
        
        profileOptionsButton.isEnabled = false
        
        // Gets friend requests data for profile user
        let requestsDatabaseRef = FIRDatabase.database().reference().child("friendRequests")
        requestsDatabaseRef.child("\(profileUsername)/sent").observeSingleEvent(of: .value, with: { (snapshot) in
            // Deletes friend requests first
            var profileSentRequests = (snapshot.value as? [String]) ?? [String]()
            var myReceivedRequests = self.currentUserFriendRequests?["received"] ?? [String]()
            
            myReceivedRequests = myReceivedRequests.filter { $0 != profileUsername }
            profileSentRequests = profileSentRequests.filter { $0 != myUsername }
            
            requestsDatabaseRef.child("\(myUsername)/received").setValue(myReceivedRequests, withCompletionBlock: { (error, database) in
                requestsDatabaseRef.child("\(profileUsername)/sent").setValue(profileSentRequests, withCompletionBlock: { (error2, database2) in
                    self.currentUserFriendRequests?["received"] = myReceivedRequests
                    
                    // Now adds as a friend, if friend request was accepted
                    if response == Constants.FriendRequestResponses.Accepted {
                        let friendsDatabaseRef = FIRDatabase.database().reference().child("friends")
                        friendsDatabaseRef.child(profileUsername).observeSingleEvent(of: .value, with: { (snapshot) in
                            var profileFriends = (snapshot.value as? [String]) ?? [String]()
                            var myFriends = self.currentUserFriends ?? [String]()
                            
                            profileFriends.insert(myUsername, at: 0)
                            myFriends.insert(profileUsername, at: 0)
                            
                            friendsDatabaseRef.child(myUsername).setValue(myFriends, withCompletionBlock: { (error3, database3) in
                                friendsDatabaseRef.child(profileUsername).setValue(profileFriends, withCompletionBlock: { (error4, database4) in
                                    self.profileOptionsButton.isEnabled = true
                                    self.profileType = Constants.ProfileTypes.Friend
                                    
                                    self.currentUserFriends = myFriends
                                    
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
                                })
                            })
                        })
                    }
                    else {
                        self.profileOptionsButton.isEnabled = true
                        self.profileType = Constants.ProfileTypes.User
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
                    }
                })
            })
        })
    }
    
    func unfriend() {
        guard
            let currentUser = FIRAuth.auth()?.currentUser,
            let myUsername = currentUser.displayName,
            let profileUsername = self.profileInfo?["username"]
        else {
            return
        }
        
        self.profileOptionsButton.isEnabled = false
        
        // Deletes friends
        let friendsDatabaseRef = FIRDatabase.database().reference().child("friends")
        friendsDatabaseRef.child(profileUsername).observeSingleEvent(of: .value, with: { (snapshot) in
            var profileFriends = (snapshot.value as? [String]) ?? [String]()
            var myFriends = self.currentUserFriends ?? [String]()
            
            profileFriends = profileFriends.filter { $0 != myUsername }
            myFriends = myFriends.filter { $0 != profileUsername }
            
            
            friendsDatabaseRef.child(myUsername).setValue(myFriends, withCompletionBlock: { (error, database) in
                friendsDatabaseRef.child(profileUsername).setValue(profileFriends, withCompletionBlock: { (error2, database) in
                    self.profileOptionsButton.isEnabled = true
                    self.profileType = Constants.ProfileTypes.User
                    
                    self.currentUserFriends = myFriends
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
                })
            })
        })
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
