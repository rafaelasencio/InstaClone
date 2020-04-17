//
//  UserProfileVC.swift
//  Spotsound
//
//  Created by Rafa Asencio on 12/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "cellId"
private let userProfileHeaderCell = "UserProfileHeaderCell"

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    
    var user: User?
    var posts = [Post]()
    
    override func viewDidLoad() {
        self.collectionView.backgroundColor = .white
        self.collectionView!.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: userProfileHeaderCell)
        
        //fetch is user is not current user.
        if self.user == nil {
            fetchCurrentUserData()
        }
        
        //fetch posts
        fetchPost()
    }
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1 
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    
    // MARK: UICollectionView

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCell
    
        cell.post = posts[indexPath.row]
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: userProfileHeaderCell, for: indexPath) as! UserProfileHeaderCell
        
        // set delegate
        header.delegate = self
        
        header.user = self.user
        
        navigationItem.title = user?.username
        
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.post = posts[indexPath.row]

        navigationController?.pushViewController(feedVC, animated: true)
    }

    
    //MARK: - Api
    
    func fetchPost(){
        
        var uid: String!
        
        if let user = self.user {
            uid = user.uid
        } else {
            uid = Auth.auth().currentUser?.uid
        }

        
        //.childAdded to know when post get added to the structure
        USER_POST_REF.child(uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            
            Database.fetchPost(with: postId) { (post) in
                self.posts.append(post)
                self.posts.sort(by: {$0.creationDate > $1.creationDate})
                self.collectionView.reloadData()
            }
        }
    }
    
    func fetchCurrentUserData(){
        // set user property in UserProfileHeaderCell
        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        
        Database.database().reference().child("users").child(currentUserUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictValues = snapshot.value as? Dictionary<String, AnyObject> else {return}
            
            let uid = snapshot.key
            let user = User(uid: uid, dict: dictValues)
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView.reloadData()
        }
    }

}

extension UserProfileVC: UserProfileHeaderCellDelegate {
    
    //MARK: - Handlers
    
    func handleFollowersButtonTapped(for header: UserProfileHeaderCell) {
        let followVC = FollowVC()
        followVC.viewFollowers = true
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleFollowingButtonTapped(for header: UserProfileHeaderCell) {
        let followVC = FollowVC()
        followVC.viewFollowing = true
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleEditProfileButtonTapped(for header: UserProfileHeaderCell) {
        guard let user = header.user else {return}
        
        if header.editProfileFollowButton.titleLabel?.text == "Edit Profile" {
            print("go to EditProfileVC")
            
        } else {
            if header.editProfileFollowButton.titleLabel?.text == "Follow" {
                header.editProfileFollowButton.setTitle("Following", for: .normal)
                
                user.follow()
            } else {
                header.editProfileFollowButton.setTitle("Follow", for: .normal)
                
                user.unfollow()
            }
        }
    }
    
    func handleSetUserStats(for header: UserProfileHeaderCell) {
        var numberOfFollowers: Int!
        var numberOfFollowings: Int!
        guard let uid = header.user?.uid else {return}
        
        //observe instead observeSingleEvent to update data in realtime
        USER_FOLLOWER_REF.child(uid).observe(.value) { (snapshot) in
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject>{
                numberOfFollowers = snapshot.count
            } else {
                numberOfFollowers = 0
            }
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowers!)\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            header.followersLabel.attributedText = attributedText
        }
        
        
        USER_FOLLOWING_REF.child(uid).observe(.value) { (snapshot) in
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject>{
                numberOfFollowings = snapshot.count
            } else {
                numberOfFollowings = 0
            }
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowings!)\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            header.followingLabel.attributedText = attributedText
        }
    }
    
    
    
    
}
