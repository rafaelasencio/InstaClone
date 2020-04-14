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
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = user
        navigationController?.pushViewController(userProfileVC, animated: true)
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
        //.childAdded is going to observe every time value is added
        ref.child(currentUserID).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
            
            allObjects.forEach { (snapshot) in
                
                let userId = snapshot.key
                
                Database.fetchUser(with: userId) { (user) in
                    self.users.append(user)
                    self.tableView.reloadData()
                }
            }
        }
        
    }
}

extension FollowVC: FollowCellDelegate {
    
    func handleFollowTapped(for cell: FollowCell) {
        guard let user = cell.user else {return}
        
        if user.isFollowed {
            print("unfollow")
            user.unfollow()
            
            cell.followButton.setTitle("Follow", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.layer.borderWidth = 0
            cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        } else {
            print("following")
            user.follow()
            
            cell.followButton.setTitle("Following", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.backgroundColor = .white
        }
    }
    
    
}
