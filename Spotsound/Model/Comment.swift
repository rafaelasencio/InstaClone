//
//  Comment.swift
//  Spotsound
//
//  Created by Rafa Asencio on 19/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import Foundation
import Firebase

class Comment {
    
    var uid: String!
    var commentText: String!
    var creationDate: Date!
    var user: User?
    
    init(dictionary: Dictionary <String, AnyObject>) {
        
        if let uid = dictionary["uid"] as? String {
            Database.fetchUser(with: uid) { (user) in
                self.user = user
            }
        }
        
        if let commentText = dictionary["commentText"] as? String {
            self.commentText = commentText
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
}
