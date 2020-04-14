//
//  FollowVC.swift
//  Spotsound
//
//  Created by Rafa Asencio on 14/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "FollowCell"

class FollowVC: UITableViewController {
    
    //MARK: - Properties
    var viewFollowers = false
    var viewFollowing = false
    var uid: String?
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register cell
        tableView.register(FollowCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        //configure nav
        if viewFollowers {
            navigationItem.title = "Followers"
        } else {
            navigationItem.title = "Following"
        }
        tableView.separatorColor = .clear
        
        fetchUsers()
    }
    
    //MARK: - TableView
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    func fetchUsers(){
        
        guard let currentUserID = self.uid else {return}
        var ref: DatabaseReference!
        
        //Control flow to determine database section to access
        if viewFollowers {
            ref = USER_FOLLOWER_REF
        } else {
            ref = USER_FOLLOWING_REF
        }
        
        ref.child(currentUserID).observe(.childAdded) { (snapshot) in
            
            let userId = snapshot.key
            
            USER_REF.child(userId).observeSingleEvent(of: .value) { (snapshot) in
                guard let dict = snapshot.value as? Dictionary<String, AnyObject> else {return}
                let user = User(uid: userId, dict: dict)
                self.users.append(user)
                self.tableView.reloadData()
            }
        }
        
    }
}
