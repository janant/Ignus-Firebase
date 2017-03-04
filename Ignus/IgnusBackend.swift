//
//  IgnusBackend.swift
//  Ignus
//
//  Created by Anant Jain on 1/12/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import Foundation
import Firebase

struct IgnusBackend {
    
    // MARK: - Data variables
    
    // All these variables are private since the public interface to access
    // the variables is through methods with callbacks. (Since the variables
    // might still be null and still loading from Firebase)
    
    // User info, such as name, username, email, and profile/cover photos
    private static var currentUserInfo: [String: String]?
    static var currentUserUsername: String?
    
    // The user's current payments.
    private static var payments: [[String: Any]]?
    
    // The usernames of the current user's friends and friend requests
    private static var friends: [String]?
    private static var friendRequests: [String: [String]]?
    
    // The user's current messages inbox
    private static var messages: [[String: Any]]?
    
    // Variables for accessing Firebase
    private static let databaseRef = FIRDatabase.database().reference()
    private static let storageRef = FIRStorage.storage().reference()
    
    // MARK: - State configuration methods
    
    // Called when a user logs in, so data can be loaded from Firebase.
    static func configureState(forUser user: FIRUser) {
        guard let username = user.displayName else {
            fatalError("Configured state for user without display name")
        }
        
        // Sets current username
        currentUserUsername = username
        
        // Set up observer for current user info
        let currentUserInfoDatabaseRef = databaseRef.child("users/\(username)")
        currentUserInfoDatabaseRef.observe(.value, with: { (snapshot) in
            if let currentUserInfoData = snapshot.value as? [String: String] {
                self.currentUserInfo = currentUserInfoData
            }
            else {
                self.currentUserInfo = [String: String]()
            }
        })
        
        // Set up observer for payments
        let paymentsDatabaseRef = databaseRef.child("payments/\(username)")
        paymentsDatabaseRef.observe(.value, with: { (snapshot) in
            if let paymentsData = snapshot.value as? [[String: Any]] {
                self.payments = paymentsData
            }
            else {
                self.payments = [[String: Any]]()
            }
        })
        
        // Set up observer for friends
        let friendsDatabaseRef = databaseRef.child("friends/\(username)")
        friendsDatabaseRef.observe(.value, with: { (snapshot) in
            if let friendsData = snapshot.value as? [String] {
                self.friends = friendsData
            }
            else {
                self.friends = [String]()
            }
        })
        
        // Set up observers for friend requests (both sent and received)
        let friendRequestsDatabaseRef = databaseRef.child("friendRequests/\(username)")
        friendRequestsDatabaseRef.observe(.value, with: { (snapshot) in
            if var friendRequestsData = snapshot.value as? [String: [String]] {
                
                if friendRequestsData["sent"] == nil {
                    friendRequestsData["sent"] = [String]()
                }
                if friendRequestsData["received"] == nil {
                    friendRequestsData["received"] = [String]()
                }
                
                self.friendRequests = friendRequestsData
                
            }
            else {
                self.friendRequests = ["sent":      [String](),
                                       "received":  [String]()]
            }
        })
        
        // Set up observer for messages
        let messagesDatabaseRef = databaseRef.child("messages/\(username)")
        messagesDatabaseRef.observe(.value, with: { (snapshot) in
            if let messagesData = snapshot.value as? [[String: Any]] {
                self.messages = messagesData
            }
            else {
                self.messages = [[String: Any]]()
            }
        })
    }
    
    // Called when a user logs out, or when the app is quit.
    static func resetState() {
        // Remove all handles
        databaseRef.removeAllObservers()
        
        // Nullifies all data
        currentUserInfo         = nil
        payments                = nil
        friends                 = nil
        friendRequests          = nil
        messages                = nil
        
        // Rests current user
        currentUserUsername = nil
    }
    
    // MARK: - User state data accessor methods
    
    // Methods for accessing user state data.
    // Basically, they check in a background thread if the data requested is nil.
    // If it is, it waits 0.1 secs and checks again. Once it does, it calls the completionHandler
    // provided by the caller, which has the data as a parameter.
    
    static func getCurrentUserInfo(with completionHandler: @escaping ([String: String]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            while self.currentUserInfo == nil {
                usleep(100000)
            }
            completionHandler(self.currentUserInfo!)
        }
    }
    
    static func getCurrentUserPayments(with completionHandler: @escaping ([[String: Any]]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            while self.payments == nil {
                usleep(100000)
            }
            
            DispatchQueue.main.async {
                completionHandler(self.payments!)
            }
            
        }
    }
    
    static func getCurrentUserFriends(with completionHandler: @escaping ([String]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            while self.friends == nil {
                usleep(100000)
            }
            
            DispatchQueue.main.async {
                completionHandler(self.friends!)
            }
            
        }
    }
    
    static func getCurrentUserFriendRequests(with completionHandler: @escaping ([String: [String]]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            while self.friendRequests == nil {
                usleep(100000)
            }
            
            DispatchQueue.main.async {
                completionHandler(self.friendRequests!)
            }
        }
    }
    
    static func getCurrentUserMessages(with completionHandler: @escaping ([[String: Any]]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            while self.messages == nil {
                usleep(100000)
            }
            DispatchQueue.main.async {
                completionHandler(self.messages!)
            }
        }
    }
    
    // MARK: - Other user data accessor methods
    
    static func getPayments(forUser username: String, with completionHandler: @escaping ([[String: Any]]) -> Void) {
        databaseRef.child("payments/\(username)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let paymentsData = snapshot.value as? [[String: Any]] {
                completionHandler(paymentsData)
            }
            else {
                let blankPaymentsData = [[String: Any]]()
                completionHandler(blankPaymentsData)
            }
        })
    }
    
    static func getFriends(forUser username: String, with completionHandler: @escaping ([String]) -> Void) {
        databaseRef.child("friends/\(username)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let friendsData = snapshot.value as? [String] {
                completionHandler(friendsData)
            }
            else {
                let blankFriendsData = [String]()
                completionHandler(blankFriendsData)
            }
        })
    }
    
    static func getFriendRequests(forUser username: String, with completionHandler: @escaping ([String: [String]]) -> Void) {
        databaseRef.child("friendsRequests/\(username)").observeSingleEvent(of: .value, with: { (snapshot) in
            if var friendRequestsData = snapshot.value as? [String: [String]] {
                if friendRequestsData["sent"] == nil {
                    friendRequestsData["sent"] = [String]()
                }
                if friendRequestsData["received"] == nil {
                    friendRequestsData["received"] = [String]()
                }
                
                completionHandler(friendRequestsData)
            }
            else {
                let blankFriendRequestsData = ["sent":      [String](),
                                        "received":  [String]()]
                completionHandler(blankFriendRequestsData)
            }
        })
    }
    
    static func getMessages(forUser username: String, with completionHandler: @escaping ([[String: Any]]) -> Void) {
        databaseRef.child("messages/\(username)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let messagesData = snapshot.value as? [[String: Any]] {
                completionHandler(messagesData)
            }
            else {
                let blankMessagesData = [[String: Any]]()
                completionHandler(blankMessagesData)
            }
        })
    }
    
    // MARK: - Profile data accessor methods
    
    // Gets user information for the given username
    static func getUserInfo(forUser username: String, with completionHandler: @escaping (Error?, [String: String]?) -> Void) {
        databaseRef.child("users/\(username)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let userInfo = snapshot.value as? [String: String] {
                completionHandler(nil, userInfo)
            }
            else {
                completionHandler(Errors.UserDoesNotExist, nil)
            }
        })
    }
    
    // Gets the current user's profile image
    static func getCurrentUserProfileImage(with completionHandler: @escaping (Error?, UIImage?) -> Void) {
        if let currentUsername = currentUserUsername {
            getProfileImage(forUser: currentUsername, with: { (error, image) in
                completionHandler(error, image)
            })
        }
        else {
            completionHandler(Errors.CurrentUserNotLoggedIn, nil)
        }
    }
    
    // Gets the current user's cover photo
    static func getCurrentUserCoverPhoto(with completionHandler: @escaping (Error?, UIImage?) -> Void) {
        if let currentUsername = currentUserUsername {
            getCoverPhoto(forUser: currentUsername, with: { (error, image) in
                completionHandler(error, image)
            })
        }
        else {
            completionHandler(Errors.CurrentUserNotLoggedIn, nil)
        }
    }
    
    // Gets the profile image for the given username
    static func getProfileImage(forUser username: String, with completionHandler: @escaping (Error?, UIImage?) -> Void) {
        storageRef.child("User_Pictures/\(username)/profile.jpg").data(withMaxSize: INT64_MAX) { (data, error) in
            if error == nil {
                if let imageData = data {
                    let profileImage = UIImage(data: imageData)
                    completionHandler(nil, profileImage)
                }
                else {
                    completionHandler(Errors.ImageLoadFailed, nil)
                }
            }
            else {
                completionHandler(Errors.UserDoesNotExist, nil)
            }
        }
    }
    
    // Gets the cover photo for the given username
    static func getCoverPhoto(forUser username: String, with completionHandler: @escaping (Error?, UIImage?) -> Void) {
        storageRef.child("User_Pictures/\(username)/cover.jpg").data(withMaxSize: INT64_MAX) { (data, error) in
            if error == nil {
                if let imageData = data {
                    let profileImage = UIImage(data: imageData)
                    completionHandler(nil, profileImage)
                }
                else {
                    completionHandler(Errors.ImageLoadFailed, nil)
                }
            }
            else {
                completionHandler(Errors.UserDoesNotExist, nil)
            }
        }
    }
    
    // MARK: - Data mutator methods
    
    // Used to create a new user info entry when signing up
    static func createUserInfo(_ userInfo: [String: String], forUser user: String, with completionHandler: @escaping (Error?) -> Void) {
        databaseRef.child("users/\(user)").setValue(messages) { (error, databaseReference) in
            completionHandler(error)
        }
    }
    
    // Sets the current user's friends
    static func setCurrentUserFriends(_ friends: [String], with completionHandler: @escaping (Error?) -> Void) {
        if let currentUsername = currentUserUsername {
            setFriends(friends, forUser: currentUsername, with: completionHandler)
        }
        else {
            completionHandler(Errors.CurrentUserNotLoggedIn)
        }
    }
    
    // Sets the specified user's friends
    static func setFriends(_ friends: [String], forUser user: String, with completionHandler: @escaping (Error?) -> Void) {
        databaseRef.child("friends/\(user)").setValue(friends) { (error, databaseReference) in
            completionHandler(error)
        }
    }
    
    // Sets the current user's sent friend requests
    static func setCurrentUserSentFriendRequests(_ friendRequests: [String], with completionHandler: @escaping (Error?) -> Void) {
        if let currentUsername = currentUserUsername {
            setSentFriendRequests(friendRequests, forUser: currentUsername, with: completionHandler)
        }
        else {
            completionHandler(Errors.CurrentUserNotLoggedIn)
        }
    }
    
    // Sets the specified user's sent friend requests
    static func setSentFriendRequests(_ friendRequests: [String], forUser user: String, with completionHandler: @escaping (Error?) -> Void) {
        databaseRef.child("friendRequests/\(user)/sent").setValue(friendRequests) { (error, databaseReference) in
            completionHandler(error)
        }
    }
    
    // Sets the current user's received friend requests
    static func setCurrentUserReceivedFriendRequests(_ friendRequests: [String], with completionHandler: @escaping (Error?) -> Void) {
        if let currentUsername = currentUserUsername {
            setReceivedFriendRequests(friendRequests, forUser: currentUsername, with: completionHandler)
        }
        else {
            completionHandler(Errors.CurrentUserNotLoggedIn)
        }
    }
    
    // Sets the specified user's received friend requests
    static func setReceivedFriendRequests(_ friendRequests: [String], forUser user: String, with completionHandler: @escaping (Error?) -> Void) {
        databaseRef.child("friendRequests/\(user)/received").setValue(friendRequests) { (error, databaseReference) in
            completionHandler(error)
        }
    }
    
    // Sets the current user's messages
    static func setCurrentUserMessages(_ messages: [[String: Any]], with completionHandler: @escaping (Error?) -> Void) {
        if let currentUsername = currentUserUsername {
            setMessages(messages, forUser: currentUsername, with: completionHandler)
        }
        else {
            completionHandler(Errors.CurrentUserNotLoggedIn)
        }
    }
    
    // Sets the specified user's messages
    static func setMessages(_ messages: [[String: Any]], forUser user: String, with completionHandler: @escaping (Error?) -> Void) {
        databaseRef.child("messages/\(user)").setValue(messages) { (error, databaseReference) in
            completionHandler(error)
        }
    }
    
    static func setCurrentUserProfileImage(withImageData data: Data, with completionHandler: @escaping (Error?, FIRStorageMetadata?) -> Void) {
        if let currentUsername = currentUserUsername {
            let profileStorageRef = storageRef.child("User_Pictures/\(currentUsername)/profile.jpg")
            profileStorageRef.put(data, metadata: nil, completion: { (metadata, error) in
                completionHandler(error, metadata)
            })
        }
        else {
            completionHandler(Errors.CurrentUserNotLoggedIn, nil)
        }
    }
    
    static func setCurrentUserCoverPhoto(withImageData data: Data, with completionHandler: @escaping (Error?, FIRStorageMetadata?) -> Void) {
        if let currentUsername = currentUserUsername {
            let profileStorageRef = storageRef.child("User_Pictures/\(currentUsername)/cover.jpg")
            profileStorageRef.put(data, metadata: nil, completion: { (metadata, error) in
                completionHandler(error, metadata)
            })
        }
        else {
            completionHandler(Errors.CurrentUserNotLoggedIn, nil)
        }
    }
    
}
