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

enum Errors: Error {
    case UserDoesNotExist
    case ImageLoadFailed
    case CurrentUserNotLoggedIn
}
