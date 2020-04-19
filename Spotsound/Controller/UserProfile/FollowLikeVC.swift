//
//  FollowLikeVC.swift
//  Spotsound
//
//  Created by Rafa Asencio on 14/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "FollowCell"

class FollowLikeVC: UITableViewController {
    
    //MARK: - Properties
    
    enum ViewingMode: Int {
        case Following
        case Followers
        case Likes
        
        init(index: Int){
            switch index {
            case 0: self = .Following
            case 1: self = .Followers
            case 2: self = .Likes
            default: self = .Following
            }
        }
    }
    
    var postId: String!
    var viewingMode: ViewingMode!
    var uid: String?
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register cell
        tableView.register(FollowLikeCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        //configure nav controller and fetch users
        if let viewingMode = self.viewingMode {
            configureNavTitle(for: viewingMode)
            fetchUsers(by: viewingMode)
        }
        tableView.separatorColor = .clear
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowLikeCell
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
    
    //MARK: - Handlers
    
    func configureNavTitle(for viewingMode: ViewingMode) {
        switch viewingMode {
            case .Followers: self.navigationItem.title = "Followers"
            case .Following: self.navigationItem.title = "Following"
            case .Likes: self.navigationItem.title = "Likes"
        }
    }
    
    //MARK: - Api
    
    func getDatabaseReference() -> DatabaseReference? {
        
        guard let viewingMode = viewingMode else {return nil}
        
        switch viewingMode {
            case .Followers: return USER_FOLLOWER_REF
            case .Following: return USER_FOLLOWING_REF
            case .Likes: return POST_LIKES_REF
        }
        
    }
    func fetchUsers(by viewingMode: ViewingMode){
        
        guard let ref = getDatabaseReference() else {return}
        
        switch viewingMode {
            
            case .Followers, .Following: //fetching users by currentUserUid
                
                guard let currentUserUid = self.uid else {return}
                
                ref.child(currentUserUid).observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                    allObjects.forEach { (snapshot) in
                        
                        let userId = snapshot.key
                        
                        Database.fetchUser(with: userId) { (user) in
                            
                            self.users.append(user)
                            self.tableView.reloadData()
                        }
                    }
                }
            
            case .Likes: //fetching users by postId
            
                guard let postId = self.postId else {return}
                ref.child(postId).observe(.childAdded) { (snapshot) in
                    let uid = snapshot.key
                    Database.fetchUser(with: uid) { (user) in
                        self.users.append(user)
                        self.tableView.reloadData()
                    }
                    
            }
        }
        
        
    }
}

extension FollowLikeVC: FollowCellDelegate {
    
    func handleFollowTapped(for cell: FollowLikeCell) {
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
