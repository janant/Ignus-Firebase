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
            let username = profileInfo["username"],
            
            let friendRequestsSent = friendRequests["sent"],
            let friendRequestsReceived = friendRequests["received"]
        else {
            return
        }
        
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
        print("should send friend request")
    }
    
    func cancelFriendRequest() {
        print("should cancel friend request")
    }
    
    func respondToFriendRequest(_ response: String) {
        print("should respond to friend request \(response)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
    }
    
    func unfriend() {
        print("should unfriend")
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadFriends), object: nil)
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
