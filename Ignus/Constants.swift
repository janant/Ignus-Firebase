//
//  Constants.swift
//  Ignus
//
//  Created by Anant Jain on 12/21/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import Foundation

struct Constants {
    
    // Automatic login options
    struct LoginOptions {
        static let RequirePassword  = "RequirePassword"
        static let TouchID          = "TouchID"
        static let FaceID           = "FaceID"
        static let AutomaticLogin   = "AutomaticLogin"
        static let None             = "None"
    }
    
    // User profile types
    struct ProfileTypes {
        static let CurrentUser = "CurrentUser"
        static let Friend = "Friend"
        static let User = "User"
        static let PendingFriend = "PendingFriend"
        static let RequestedFriend = "RequestedFriend"
    }
    
    struct NotificationNames {
        static let ReloadProfileImages = "ReloadProfileImages"
        static let ReloadFriends = "ReloadFriends"
        static let ReloadPayments = "ReloadPayments"
    }
    
    struct UserInfoKeys {
        static let Profile = "Profile"
        static let Cover = "Cover"
    }
    
    struct NoFriendsLabelText {
        static let FriendsTitle = "No Friends"
        static let FriendsDetail = "Add some by tapping +."
        static let RequestsTitle = "No Friend Requests"
        static let RequestsDetail = "Incoming friend requests will appear here."
    }
    
    struct ProfileScope {
        static let Ratings = 0
        static let Payments = 1
    }
    
    struct PaymentSegueInfoKeys {
        static let Username = "username"
        static let PaymentRequest = "paymentRequest"
    }
    
    struct PaymentMethodTypes {
        static let Cash = "Cash"
        static let Other = "Other"
    }
    
    struct PaymentRequestStatus {
        static let Active = "Active"
        static let Completed = "Completed"
    }
    
    struct PaymentRating {
        static let Red = "Red"
        static let Yellow = "Yellow"
        static let Green = "Green"
        static let None = "None"
    }
    
    struct PaymentsScope {
        static let Active = 0
        static let Completed = 1
    }
    
    struct FriendsScope {
        static let MyFriends = 0
        static let FriendRequests = 1
    }
    
    struct AddFriendsSearchBar {
        static let SearchByNameIndex = 0
        static let SearchByUsernameIndex = 1
        static let SearchByNamePlaceholderText = "Search by name"
        static let SearchByUsernamePlaceholderText = "Search by username"
    }
    
    struct ProfileSegueSenderKeys {
        static let ProfileData = "ProfileData"
        static let FriendRequestsData = "FriendRequestsData"
    }
    
    struct FriendRequestResponses {
        static let Accepted = "Accepted"
        static let Declined = "Declined"
    }
}

struct IgnusUtility {
    
    // Appearance calls
    static func customizeAppearance(_ custom: Bool) {
        if custom {
            // Sets fonts/colors of various stuff
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Gotham-Medium", size: 18)!]
            UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Gotham-Medium", size: 32)!]
            UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Gotham-Book", size: 14)!], for: .normal)
            UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Gotham-Book", size: 14)!], for: .disabled)
            UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Gotham-Book", size: 14)!], for: .selected)
            UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Gotham-Book", size: 14)!], for: .highlighted)
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Gotham-Medium", size: 17)!], for: .normal)
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Gotham-Medium", size: 17)!], for: .disabled)
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Gotham-Medium", size: 17)!], for: .selected)
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Gotham-Medium", size: 17)!], for: .highlighted)
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Gotham-Book", size: 11)!], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Gotham-Book", size: 11)!], for: .disabled)
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Gotham-Book", size: 11)!], for: .selected)
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Gotham-Book", size: 11)!], for: .highlighted)
        }
        else {
            // Resets fonts/colors of various stuff
            UINavigationBar.appearance().titleTextAttributes = nil
            UINavigationBar.appearance().largeTitleTextAttributes = nil
            UISegmentedControl.appearance().setTitleTextAttributes(nil, for: .normal)
            UISegmentedControl.appearance().setTitleTextAttributes(nil, for: .disabled)
            UISegmentedControl.appearance().setTitleTextAttributes(nil, for: .selected)
            UISegmentedControl.appearance().setTitleTextAttributes(nil, for: .highlighted)
            UIBarButtonItem.appearance().setTitleTextAttributes(nil, for: .normal)
            UIBarButtonItem.appearance().setTitleTextAttributes(nil, for: .disabled)
            UIBarButtonItem.appearance().setTitleTextAttributes(nil, for: .selected)
            UIBarButtonItem.appearance().setTitleTextAttributes(nil, for: .highlighted)
            UITabBarItem.appearance().setTitleTextAttributes(nil, for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes(nil, for: .disabled)
            UITabBarItem.appearance().setTitleTextAttributes(nil, for: .selected)
            UITabBarItem.appearance().setTitleTextAttributes(nil, for: .highlighted)
        }
    }
    
}

enum Errors: Error {
    case UserDoesNotExist
    case ImageLoadFailed
    case CurrentUserNotLoggedIn
    case PaymentRequestDataError
}
