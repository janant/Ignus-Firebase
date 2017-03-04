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
            let myUsername = IgnusBackend.currentUserUsername,
            let profileUsername = self.profileInfo?["username"]
        else {
            return
        }
        
        profileOptionsButton.isEnabled = false
        
        // Gets friend requests data for profile user
        IgnusBackend.getFriendRequests(forUser: profileUsername) { (profileFriendRequests) in
            IgnusBackend.getCurrentUserFriendRequests(with: { (currentUserFriendRequests) in
                guard
                    var profileReceivedRequests = profileFriendRequests["received"],
                    var mySentRequests = currentUserFriendRequests["sent"]
                else {
                    return
                }
                
                mySentRequests.insert(profileUsername, at: 0)
                profileReceivedRequests.insert(myUsername, at: 0)
                
                IgnusBackend.setCurrentUserSentFriendRequests(mySentRequests, with: { (error) in
                    IgnusBackend.setReceivedFriendRequests(profileReceivedRequests, forUser: profileUsername, with: { (error) in
                        self.profileOptionsButton.isEnabled = true
                        self.profileType = Constants.ProfileTypes.PendingFriend
                                                
                        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
                    })
                })
            })
        }
    }
    
    func cancelFriendRequest() {
        guard
            let myUsername = IgnusBackend.currentUserUsername,
            let profileUsername = self.profileInfo?["username"]
            else {
                return
        }
        
        profileOptionsButton.isEnabled = false
        
        // Gets friend requests data for profile user
        IgnusBackend.getFriendRequests(forUser: profileUsername) { (profileFriendRequests) in
            IgnusBackend.getCurrentUserFriendRequests(with: { (currentUserFriendRequests) in
                guard
                    var profileReceivedRequests = profileFriendRequests["received"],
                    var mySentRequests = currentUserFriendRequests["sent"]
                else {
                    return
                }
                
                mySentRequests = mySentRequests.filter { $0 != profileUsername }
                profileReceivedRequests = profileReceivedRequests.filter { $0 != myUsername }
                
                IgnusBackend.setCurrentUserSentFriendRequests(mySentRequests, with: { (error) in
                    IgnusBackend.setReceivedFriendRequests(profileReceivedRequests, forUser: profileUsername, with: { (error) in
                        self.profileOptionsButton.isEnabled = true
                        self.profileType = Constants.ProfileTypes.User
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
                    })
                })
            })
        }
    }
    
    func respondToFriendRequest(_ response: String) {
        guard
            let myUsername = IgnusBackend.currentUserUsername,
            let profileUsername = self.profileInfo?["username"]
            else {
                return
        }
        
        profileOptionsButton.isEnabled = false
        
        // Gets friend requests data for profile user
        IgnusBackend.getFriendRequests(forUser: profileUsername) { (profileFriendRequests) in
            IgnusBackend.getCurrentUserFriendRequests(with: { (currentUserFriendRequests) in
                guard
                    var profileSentRequests = profileFriendRequests["sent"],
                    var myReceivedRequests = currentUserFriendRequests["received"]
                else {
                    return
                }
                
                myReceivedRequests = myReceivedRequests.filter { $0 != profileUsername }
                profileSentRequests = profileSentRequests.filter { $0 != myUsername }
                
                IgnusBackend.setCurrentUserReceivedFriendRequests(myReceivedRequests, with: { (error) in
                    IgnusBackend.setSentFriendRequests(profileSentRequests, forUser: profileUsername, with: { (error) in
                        // Now adds as a friend, if friend request was accepted
                        if response == Constants.FriendRequestResponses.Accepted {
                            IgnusBackend.getFriends(forUser: profileUsername, with: { (profileFriendsData) in
                                IgnusBackend.getCurrentUserFriends(with: { (currentUserFriendsData) in
                                    var profileFriends = profileFriendsData
                                    var myFriends = currentUserFriendsData
                                    
                                    profileFriends.insert(myUsername, at: 0)
                                    myFriends.insert(profileUsername, at: 0)
                                    
                                    IgnusBackend.setCurrentUserFriends(myFriends, with: { (error) in
                                        IgnusBackend.setFriends(profileFriends, forUser: profileUsername, with: { (error) in
                                            self.profileOptionsButton.isEnabled = true
                                            self.profileType = Constants.ProfileTypes.Friend
                                            
                                            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
                                        })
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
    }
    
    func unfriend() {
        guard
            let myUsername = IgnusBackend.currentUserUsername,
            let profileUsername = self.profileInfo?["username"]
        else {
            return
        }
        
        self.profileOptionsButton.isEnabled = false
        
        // Deletes friends
        IgnusBackend.getFriends(forUser: profileUsername) { (profileFriendsData) in
            IgnusBackend.getCurrentUserFriends(with: { (currentUserFriendsData) in
                var profileFriends = profileFriendsData
                var myFriends = currentUserFriendsData
                
                profileFriends = profileFriends.filter { $0 != myUsername }
                myFriends = myFriends.filter { $0 != profileUsername }
                
                // Stores new friends data in Firebase
                IgnusBackend.setCurrentUserFriends(myFriends, with: { (error) in
                    IgnusBackend.setFriends(profileFriends, forUser: profileUsername, with: { (error) in
                        self.profileOptionsButton.isEnabled = true
                        self.profileType = Constants.ProfileTypes.User
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
                    })
                })
            })
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
