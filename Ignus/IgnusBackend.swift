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
    
    // The user's current payments.
    // TODO
    
    // The usernames of the current user's friends and friend requests
    private static var friends: [String]?
    private static var friendRequests: [String: [String]]?
    
    // The user's current messages inbox
    private static var messages: [[String: Any]]?
    
    // Variables for accessing Firebase
    private static var databaseRef = FIRDatabase.database().reference()
    
    // MARK: - State configuration methods
    
    // Called when a user logs in, so data can be loaded from Firebase.
    static func configureState(forUser user: FIRUser) {
        guard let username = user.displayName else {
            fatalError("Configured state for user without display name")
        }
        
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
        // TODO
        
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
            if let friendRequestsData = snapshot.value as? [String: [String]] {
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
        friends                 = nil
        friendRequests          = nil
        messages                = nil
        
        // TODO: nullify payment data
    }
    
    // MARK: - User state data accessor methods
    
    // Methods for accessing user state data.
    // Basically, they check in a background thread if the data requested is nil.
    // If it is, it waits 0.1 secs and checks again. Once it does, it calls the completionHandler
    // provided by the caller, which has the data as a parameter.
    
    static func getCurrentUserInfo(with completionHandler: @escaping ([String: String]) -> Void) {
        DispatchQueue.main.async {
            while self.currentUserInfo == nil {
                usleep(100000)
            }
            completionHandler(self.currentUserInfo!)
        }
    }
    
    static func getFriends(with completionHandler: @escaping ([String]) -> Void) {
        DispatchQueue.main.async {
            while self.friends == nil {
                usleep(100000)
            }
            completionHandler(self.friends!)
        }
    }
    
    static func getFriendRequests(with completionHandler: @escaping ([String: [String]]) -> Void) {
        DispatchQueue.main.async {
            while self.friendRequests == nil {
                usleep(100000)
            }
            completionHandler(self.friendRequests!)
        }
    }
    
    static func getMessages(with completionHandler: @escaping ([[String: Any]]) -> Void) {
        DispatchQueue.main.async {
            while self.messages == nil {
                usleep(100000)
            }
            completionHandler(self.messages!)
        }
    }
    
}
