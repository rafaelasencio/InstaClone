//
//  User.swift
//  Spotsound
//
//  Created by Rafa Asencio on 13/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import Foundation

class User {
    var username: String!
    var name: String!
    var profileImageUrl: String!
    var uid: String!
    
    init(username: String, name: String, profileImageUrl: String, uid: String) {
        self.username = username
        self.name = name
        self.profileImageUrl = profileImageUrl
        self.uid = uid
    }
    
    init(uid: String, dict: Dictionary<String, AnyObject>) {
        self.uid = uid
        
        if let username = dict["username"] as? String {
            self.username = username
        }
        if let name = dict["name"] as? String {
            self.name = name
        }
        if let profileImageUrl = dict["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl
        }
    }
}
