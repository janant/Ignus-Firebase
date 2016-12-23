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
    }
    
    struct UserInfoKeys {
        static let Profile = "Profile"
        static let Cover = "Cover"
    }
    
}
