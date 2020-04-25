//
//  SearchVC.swift
//  Spotsound
//
//  Created by Rafa Asencio on 12/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "SearchUserCell"
private let searchPostCell = "SearchPostCell"

class SearchVC: UITableViewController {

    //MARK: - Properties
    
    var users = [User]()
    var filteredUser = [User]()
    var searchBar = UISearchBar()
    var inSearchMode = false
    var collectionView: UICollectionView!
    var collectionViewEnabled = true
    var posts = [Post]()
    var currentKey: String?
    var userCurrentKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure search bar
        configureSearchBar()
        
        
        self.tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // separator inset
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        
        // configure search bar
        configureSearchBar()
        
        // configure collection view
        configureCollectionView()
        
        //fetch posts
        fetchPosts()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if posts.count > 20 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return inSearchMode ? filteredUser.count : users.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if users.count > 3 {
            if indexPath.item == users.count - 1 {
                fetchUser()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        
        var user: User!
        
        if inSearchMode {
            user = filteredUser[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        cell.user = user
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var user: User!
        
        if inSearchMode {
            user = filteredUser[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        //pass user to UserProfileVC
        userProfileVC.user = user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    
    //MARK: - Api
    
    func fetchUser(){
        
        if userCurrentKey == nil {
            USER_REF.queryLimited(toLast: 4).observeSingleEvent(of: .value) { (snapshot) in
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { (snapshot) in
                    
                    let uid = snapshot.key
                    
                    Database.fetchUser(with: uid) { (user) in
                        self.users.append(user)
                        self.tableView.reloadData()
                    }
                }
                self.userCurrentKey = first.key
            }
        } else {
            USER_REF.queryOrderedByKey().queryEnding(atValue: userCurrentKey).queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { (snapshot) in
                    let uid = snapshot.key
                    if uid != self.userCurrentKey {
                        
                        Database.fetchUser(with: uid) { (user) in
                            self.users.append(user)
                            self.tableView.reloadData()
                        }
                    }
                }
                self.userCurrentKey = first.key
            }
        }
        
    }
    
    func fetchPosts(){
        
        if currentKey == nil {
            
            // initial data pull
            POSTS_REF.queryLimited(toLast: 21).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { (snapshot) in
                    let postId = snapshot.key
                    
                    Database.fetchPost(with: postId) { (post) in
                        self.posts.append(post)
                        self.collectionView.reloadData()
                    }
                }
                self.currentKey = first.key
            }
        } else {
            // pagination
            POSTS_REF.queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 10).observeSingleEvent(of: .value) { (snapshot) in
                print(snapshot)
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { (snapshot) in
                    let postId = snapshot.key
                    
                    if postId != self.currentKey {
                        Database.fetchPost(with: postId) { (post) in
                            self.posts.append(post)
                            self.collectionView.reloadData()
                        }
                    }
                }
                self.currentKey = first.key
            }
        }
    }
    
    
}

extension SearchVC: UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - UICollectionView
    
    
    func configureCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height -
            (tabBarController?.tabBar.frame.height)! - (navigationController?.navigationBar.frame.height)!)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        
        tableView.addSubview(collectionView)
        collectionView.register(SearchPostCell.self, forCellWithReuseIdentifier: searchPostCell)
        tableView.separatorColor = .clear
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: searchPostCell, for: indexPath) as! SearchPostCell
        cell.post = posts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let post = posts[indexPath.row]
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.post = post
        feedVC.viewSinglePost = true 
        self.navigationController?.pushViewController(feedVC, animated: true)
    }
    
    
    
    
    //MARK: - UISearchBar
    
    func configureSearchBar(){
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        searchBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        searchBar.tintColor = .black
    }
         
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchBar.showsCancelButton = true
        fetchUser()
        collectionView.isHidden = true
        collectionViewEnabled = false
        
        tableView.separatorColor = .lightGray
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // handle search text change
        let searchText = searchText.lowercased()
        
        if searchText.isEmpty || searchText == "" {
            inSearchMode = false
            self.tableView.reloadData()
        } else {
            inSearchMode = true
            filteredUser = users.filter({ (user) -> Bool in
                return user.username.contains(searchText)
            })
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        
        inSearchMode = false
        searchBar.text = nil
        
        collectionViewEnabled = true
        collectionView.isHidden = false
        
        tableView.separatorColor = .clear
        
        tableView.reloadData()
    }
}
