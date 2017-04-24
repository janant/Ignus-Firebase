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
    
    // The user's payment requests, included completed ones.
    private static var paymentRequests: [String: [[String: Any]]]?
    
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
        let paymentsDatabaseRef = databaseRef.child("paymentRequests/\(username)")
        paymentsDatabaseRef.observe(.value, with: { (snapshot) in
            if var paymentRequestsData = snapshot.value as? [String: [[String: Any]]] {
                if paymentRequestsData["sent"] == nil {
                    paymentRequestsData["sent"] = [[String: Any]]()
                }
                if paymentRequestsData["received"] == nil {
                    paymentRequestsData["received"] = [[String: Any]]()
                }
                
                self.paymentRequests = paymentRequestsData
            }
            else {
                self.paymentRequests = ["sent":      [[String: Any]](),
                                       "received":  [[String: Any]]()]
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
        paymentRequests         = nil
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
    
    static func getCurrentUserPaymentRequests(with completionHandler: @escaping ([String: [[String: Any]]]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            while self.paymentRequests == nil {
                usleep(100000)
            }
            
            DispatchQueue.main.async {
                completionHandler(self.paymentRequests!)
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
    
    static func getPaymentRequests(forUser username: String, with completionHandler: @escaping ([String: [[String: Any]]]) -> Void) {
        databaseRef.child("paymentRequests/\(username)").observeSingleEvent(of: .value, with: { (snapshot) in
            if var paymentRequestsData = snapshot.value as? [String: [[String: Any]]] {
                if paymentRequestsData["sent"] == nil {
                    paymentRequestsData["sent"] = [[String: Any]]()
                }
                if paymentRequestsData["received"] == nil {
                    paymentRequestsData["received"] = [[String: Any]]()
                }
                
                completionHandler(paymentRequestsData)
            }
            else {
                let blankPaymentRequestsData = ["sent":      [[String: Any]](),
                                                "received":  [[String: Any]]()]
                completionHandler(blankPaymentRequestsData)
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
        databaseRef.child("friendRequests/\(username)").observeSingleEvent(of: .value, with: { (snapshot) in
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
    
    // Sets the current user's sent payment requests
    static func setCurrentUserSentPaymentRequests(_ paymentRequests: [[String: Any]], with completionHandler: @escaping (Error?) -> Void) {
        if let currentUsername = currentUserUsername {
            setSentPaymentRequests(paymentRequests, forUser: currentUsername, with: completionHandler)
        }
        else {
            completionHandler(Errors.CurrentUserNotLoggedIn)
        }
    }
    
    // Sets the specified user's sent payment requests
    static func setSentPaymentRequests(_ paymentRequests: [[String: Any]], forUser user: String, with completionHandler: @escaping (Error?) -> Void) {
        databaseRef.child("paymentRequests/\(user)/sent").setValue(paymentRequests) { (error, databaseReference) in
            completionHandler(error)
        }
    }
    
    // Sets the current user's received payment requests
    static func setCurrentUserReceivedPaymentRequests(_ paymentRequests: [[String: Any]], with completionHandler: @escaping (Error?) -> Void) {
        if let currentUsername = currentUserUsername {
            setReceivedPaymentRequests(paymentRequests, forUser: currentUsername, with: completionHandler)
        }
        else {
            completionHandler(Errors.CurrentUserNotLoggedIn)
        }
    }
    
    // Sets the specified user's received payment requests
    static func setReceivedPaymentRequests(_ paymentRequests: [[String: Any]], forUser user: String, with completionHandler: @escaping (Error?) -> Void) {
        databaseRef.child("paymentRequests/\(user)/received").setValue(paymentRequests) { (error, databaseReference) in
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
    
    // MARK: - Friend operations
    
    static func sendFriendRequest(toUser user: String, with completionHandler: @escaping (Error?) -> Void) {
        
        guard let currentUser = currentUserUsername else {
            completionHandler(Errors.CurrentUserNotLoggedIn)
            return
        }
        
        // Gets friend requests data for user
        IgnusBackend.getFriendRequests(forUser: user) { (userFriendRequests) in
            IgnusBackend.getCurrentUserFriendRequests(with: { (currentUserFriendRequests) in
                guard
                    var userReceivedRequests = userFriendRequests["received"],
                    var mySentRequests = currentUserFriendRequests["sent"]
                else {
                    return
                }
                
                // Deletes user first, in case of backend errors
                mySentRequests = mySentRequests.filter { $0 != user }
                userReceivedRequests = userReceivedRequests.filter { $0 != currentUser }
                
                // Now adds the users to friend requests
                mySentRequests.insert(user, at: 0)
                userReceivedRequests.insert(currentUser, at: 0)
                
                IgnusBackend.setCurrentUserSentFriendRequests(mySentRequests, with: { (error) in
                    IgnusBackend.setReceivedFriendRequests(userReceivedRequests, forUser: user, with: { (error) in
                        completionHandler(nil)
                    })
                })
            })
        }
    }
    
    static func cancelFriendRequest(toUser user: String, with completionHandler: @escaping (Error?) -> Void) {
        
        guard let currentUser = currentUserUsername else {
            completionHandler(Errors.CurrentUserNotLoggedIn)
            return
        }
        
        // Gets friend requests data for user
        IgnusBackend.getFriendRequests(forUser: user) { (userFriendRequests) in
            IgnusBackend.getCurrentUserFriendRequests(with: { (currentUserFriendRequests) in
                guard
                    var userReceivedRequests = userFriendRequests["received"],
                    var mySentRequests = currentUserFriendRequests["sent"]
                else {
                    return
                }
                
                // Removes usernames from friend requests
                mySentRequests = mySentRequests.filter { $0 != user }
                userReceivedRequests = userReceivedRequests.filter { $0 != currentUser }
                
                IgnusBackend.setCurrentUserSentFriendRequests(mySentRequests, with: { (error) in
                    IgnusBackend.setReceivedFriendRequests(userReceivedRequests, forUser: user, with: { (error) in
                        completionHandler(nil)
                    })
                })
            })
        }
    }
    
    static func handleFriendRequest(fromUser user: String, response: String, with completionHandler: @escaping (Error?) -> Void) {
        
        guard let currentUser = currentUserUsername else {
            completionHandler(Errors.CurrentUserNotLoggedIn)
            return
        }
        
        // Gets friend requests data for sender user
        IgnusBackend.getFriendRequests(forUser: user) { (userFriendRequest) in
            IgnusBackend.getCurrentUserFriendRequests(with: { (currentUserFriendRequests) in
                guard
                    var userSentRequests = userFriendRequest["sent"],
                    var myReceivedRequests = currentUserFriendRequests["received"]
                else {
                    return
                }
                
                myReceivedRequests = myReceivedRequests.filter { $0 != user }
                userSentRequests = userSentRequests.filter { $0 != currentUser }
                
                IgnusBackend.setCurrentUserReceivedFriendRequests(myReceivedRequests, with: { (error) in
                    IgnusBackend.setSentFriendRequests(userSentRequests, forUser: user, with: { (error) in
                        // Now adds as a friend, if friend request was accepted
                        if response == Constants.FriendRequestResponses.Accepted {
                            IgnusBackend.getFriends(forUser: user, with: { (userFriendsData) in
                                IgnusBackend.getCurrentUserFriends(with: { (currentUserFriendsData) in
                                    var userFriends = userFriendsData
                                    var myFriends = currentUserFriendsData
                                    
                                    // Deletes users first, in case of backend errors
                                    myFriends = myFriends.filter { $0 != user }
                                    userFriends = userFriends.filter { $0 != currentUser }
                                    
                                    // Now adds the user
                                    userFriends.insert(currentUser, at: 0)
                                    myFriends.insert(user, at: 0)
                                    
                                    IgnusBackend.setCurrentUserFriends(myFriends, with: { (error) in
                                        IgnusBackend.setFriends(userFriends, forUser: user, with: { (error) in
                                            completionHandler(nil)
                                        })
                                    })
                                })
                            })
                        }
                        else {
                            completionHandler(nil)
                        }
                    })
                })
            })
        }
    }
    
    static func unfriendUser(withUsername user: String, with completionHandler: @escaping (Error?) -> Void) {
        
        guard let currentUser = currentUserUsername else {
            completionHandler(Errors.CurrentUserNotLoggedIn)
            return
        }
        
        // Deletes friends
        IgnusBackend.getFriends(forUser: user) { (userFriendsData) in
            IgnusBackend.getCurrentUserFriends(with: { (currentUserFriendsData) in
                var userFriends = userFriendsData
                var myFriends = currentUserFriendsData
                
                // Removes usernames from friends
                userFriends = userFriends.filter { $0 != currentUser }
                myFriends = myFriends.filter { $0 != user }
                
                // Stores new friends data in Firebase
                IgnusBackend.setCurrentUserFriends(myFriends, with: { (error) in
                    IgnusBackend.setFriends(userFriends, forUser: user, with: { (error) in
                        completionHandler(nil)
                    })
                })
            })
        }
    }
    
    // MARK: - Payment operations
    
    static func sendPaymentRequest(toUser user: String, dollars: Int, cents: Int, memo: String, with completionHandler: @escaping (Error?) -> Void) {
        
        guard let currentUser = currentUserUsername else {
            completionHandler(Errors.CurrentUserNotLoggedIn)
            return
        }
        
        // Creates new payment request data object
        var paymentRequest = [String: Any]()
        paymentRequest["sender"] = currentUser
        paymentRequest["recipient"] = user
        paymentRequest["dollars"] = dollars
        paymentRequest["cents"] = cents
        paymentRequest["memo"] = memo
        paymentRequest["paymentMethod"] = Constants.PaymentMethodTypes.Other
        paymentRequest["unread"] = true
        paymentRequest["status"] = Constants.PaymentRequestStatus.Active
        paymentRequest["rating"] = Constants.PaymentRating.None
        paymentRequest["createdTimestamp"] = FIRServerValue.timestamp()
        paymentRequest["completedTimestamp"] = 0
        
        // Updates user received requests and current user sent requests
        getPaymentRequests(forUser: user) { (userPaymentRequests) in
            if var userReceivedPayments = userPaymentRequests["received"] {
                userReceivedPayments.insert(paymentRequest, at: 0)
                
                // Gets current user payment requests
                getCurrentUserPaymentRequests(with: { (currentUserPaymentRequests) in
                    if var currentUserSentPaymentRequests = currentUserPaymentRequests["sent"] {
                        currentUserSentPaymentRequests.insert(paymentRequest, at: 0)
                        
                        // Sets the user's received payment requests
                        setReceivedPaymentRequests(userReceivedPayments, forUser: user, with: { (error) in
                            if error == nil {
                                // Sets the current user's sent payment requests
                                setCurrentUserSentPaymentRequests(currentUserSentPaymentRequests, with: { (error) in
                                    completionHandler(error)
                                })
                            }
                            else {
                                completionHandler(error)
                            }
                        })
                    }
                })
            }
        }
    }
    
    static func completePaymentRequest(_ paymentRequest: [String: Any], withRating rating: String, with completionHandler: @escaping (Error?) -> Void) {
        
        guard let recipientUsername = paymentRequest["recipient"] as? String else {
            completionHandler(Errors.PaymentRequestDataError)
            return
        }
        
        // Creates completed payment request data
        var completedPaymentRequest = paymentRequest
        completedPaymentRequest["rating"] = rating;
        completedPaymentRequest["status"] = Constants.PaymentRequestStatus.Completed
        completedPaymentRequest["completedTimestamp"] = FIRServerValue.timestamp()
        
        // Get's the current user's sent payment requests
        getCurrentUserPaymentRequests { (currentUserPaymentRequests) in
            guard
                var currentUserSentPaymentRequests = currentUserPaymentRequests["sent"]
            else {
                completionHandler(Errors.PaymentRequestDataError)
                return
            }
            
            // Updates the payment request
            for i in 0..<(currentUserSentPaymentRequests.count) {
                let currentRequest = currentUserSentPaymentRequests[i]
                
                // Updates data
                if paymentRequestsAreEqual(paymentRequest, currentRequest) {
                    currentUserSentPaymentRequests[i]["rating"] = rating
                    currentUserSentPaymentRequests[i]["status"] = Constants.PaymentRequestStatus.Completed
                    currentUserSentPaymentRequests[i]["completedTimestamp"] = FIRServerValue.timestamp()
                }
            }
            
            // Gets the recipient's received payment requests
            getPaymentRequests(forUser: recipientUsername, with: { (recipientPaymentRequests) in
                guard
                    var recipientReceivedPaymentRequests = recipientPaymentRequests["received"]
                else {
                    completionHandler(Errors.PaymentRequestDataError)
                    return
                }
                
                // Updates the payment request
                for i in 0..<(recipientReceivedPaymentRequests.count) {
                    let currentRequest = recipientReceivedPaymentRequests[i]
                    
                    // Updates data
                    if paymentRequestsAreEqual(paymentRequest, currentRequest) {
                        recipientReceivedPaymentRequests[i]["rating"] = rating
                        recipientReceivedPaymentRequests[i]["status"] = Constants.PaymentRequestStatus.Completed
                        recipientReceivedPaymentRequests[i]["completedTimestamp"] = FIRServerValue.timestamp()
                    }
                }
                
                // Saves the current user's data
                setCurrentUserSentPaymentRequests(currentUserSentPaymentRequests, with: { (error) in
                    if error == nil {
                        // Saves the recipient user's data
                        setReceivedPaymentRequests(recipientReceivedPaymentRequests, forUser: recipientUsername, with: { (error) in
                            completionHandler(error)
                        })
                    }
                    else {
                        completionHandler(error)
                    }
                })
            })
            
        }
    }
    
    static func deletePaymentRequest(_ paymentRequest: [String: Any], with completionHandler: @escaping (Error?) -> Void) {
        
        guard let recipientUsername = paymentRequest["recipient"] as? String else {
            completionHandler(Errors.PaymentRequestDataError)
            return
        }
        
        // Gets current payment requests
        getCurrentUserPaymentRequests { (currentUserPaymentRequests) in
            if var currentUserSentPaymentRequests = currentUserPaymentRequests["sent"] {
                
                // Deletes if the timestamp matches
                currentUserSentPaymentRequests = currentUserSentPaymentRequests.filter({ (request) -> Bool in
                    return !paymentRequestsAreEqual(paymentRequest, request)
                })
                
                // Gets the recipient's payment requests
                getPaymentRequests(forUser: recipientUsername, with: { (recipientPaymentRequests) in
                    
                    guard var recipientReceivedPaymentRequests = recipientPaymentRequests["received"] else {
                        completionHandler(Errors.PaymentRequestDataError)
                        return
                    }
                    
                    // Deletes if the timestamp matches
                    recipientReceivedPaymentRequests = recipientReceivedPaymentRequests.filter({ (request) -> Bool in
                        return !paymentRequestsAreEqual(paymentRequest, request)
                    })
                    
                    // Sets current user's payment requests
                    setCurrentUserSentPaymentRequests(currentUserSentPaymentRequests, with: { (error) in
                        if error == nil {
                            // Sets recipient's payment requests
                            setReceivedPaymentRequests(recipientReceivedPaymentRequests, forUser: recipientUsername, with: { (error) in
                                completionHandler(error)
                            })
                        }
                        else {
                            completionHandler(error)
                            return
                        }
                    })
                    
                })
            }
        }
    }
    
    static func markPaymentRequestAsRead(_ paymentRequest: [String: Any], with completionHandler: @escaping (Error?) -> Void) {
        // Gets current user payments
        getCurrentUserPaymentRequests { (currentUserPaymentRequests) in
            if var currentUserReceivedPaymentRequests = currentUserPaymentRequests["received"] {
                // Updates the payment request
                for i in 0..<(currentUserReceivedPaymentRequests.count) {
                    let currentRequest = currentUserReceivedPaymentRequests[i]
                    
                    // Updates data
                    if paymentRequestsAreEqual(paymentRequest, currentRequest) {
                        currentUserReceivedPaymentRequests[i]["unread"] = false
                        break
                    }
                }
                
                // Saves payment requests
                setCurrentUserReceivedPaymentRequests(currentUserReceivedPaymentRequests, with: { (error) in
                    completionHandler(nil)
                })
            }
        }
    }
    
    private static func paymentRequestsAreEqual(_ paymentRequest1: [String: Any], _ paymentRequest2: [String: Any]) -> Bool {
        // Gets all attributes to check
        guard
            let sender1 = paymentRequest1["sender"] as? String,
            let sender2 = paymentRequest2["sender"] as? String,
            let recipient1 = paymentRequest1["recipient"] as? String,
            let recipient2 = paymentRequest2["recipient"] as? String,
            let dollars1 = paymentRequest1["dollars"] as? Int,
            let dollars2 = paymentRequest2["dollars"] as? Int,
            let cents1 = paymentRequest1["cents"] as? Int,
            let cents2 = paymentRequest2["cents"] as? Int,
            let memo1 = paymentRequest1["memo"] as? String,
            let memo2 = paymentRequest2["memo"] as? String,
            let status1 = paymentRequest1["status"] as? String,
            let status2 = paymentRequest2["status"] as? String,
            let rating1 = paymentRequest1["rating"] as? String,
            let rating2 = paymentRequest2["rating"] as? String
        else {
            return false
        }
        
        // Checks if the attributes are equal
        return (sender1 == sender2)
            && (recipient1 == recipient2)
            && (dollars1 == dollars2)
            && (cents1 == cents2)
            && (memo1 == memo2)
            && (status1 == status2)
            && (rating1 == rating2)
    }
    
    // MARK: - Message operations
    
    static func sendMessage(message: String, toUser user: String, with completionHandler: @escaping (Error?) -> Void) {
        
        guard let currentUser = currentUserUsername else {
            completionHandler(Errors.CurrentUserNotLoggedIn)
            return
        }
        
        // Creates new message data
        var newMessageData = [String: Any]()
        newMessageData["sender"] = currentUser
        newMessageData["recipient"] = user
        newMessageData["message"] = message
        newMessageData["unread"] = true
        newMessageData["timestamp"] = FIRServerValue.timestamp()
        
        // Gets current messages, add new message, saves messages
        getMessages(forUser: user) { (messages) in
            var recipientMessages = messages
            recipientMessages.insert(newMessageData, at: 0)
            
            setMessages(recipientMessages, forUser: user, with: { (error) in
                completionHandler(error)
            })
        }
    }
    
//    static func markMessageAsRead(_ message: [String: Any], with completionHandler: @escaping (Error?) -> Void) {
//        // Gets current user messages
//        getCurrentUserMessages { (currentUserMessages) in
//            var currentUserMessages = currentUserMessages
//            
//            
//        }
//        getCurrentUserPaymentRequests { (currentUserPaymentRequests) in
//            if var currentUserReceivedPaymentRequests = currentUserPaymentRequests["received"] {
//                // Updates the payment request
//                for i in 0..<(currentUserReceivedPaymentRequests.count) {
//                    let currentRequest = currentUserReceivedPaymentRequests[i]
//                    
//                    // Updates data
//                    if paymentRequestsAreEqual(paymentRequest, currentRequest) {
//                        currentUserReceivedPaymentRequests[i]["unread"] = false
//                        break
//                    }
//                }
//                
//                // Saves payment requests
//                setCurrentUserReceivedPaymentRequests(currentUserReceivedPaymentRequests, with: { (error) in
//                    completionHandler(nil)
//                })
//            }
//        }
//    }
    
}
