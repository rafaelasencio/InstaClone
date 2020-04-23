//
//  HashtagController.swift
//  Spotsound
//
//  Created by Rafa Asencio on 24/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "HashtagCell"

class HashtagController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Properties
    var posts = [Post]()
    var hashtag: String?
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNagitationBar()
                
        self.collectionView.backgroundColor = .white
        
        self.collectionView.register(HashtagCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //fetch post
        fetchPost()
    }
    
    //MARK: - UICollectionViewFlowLayout
    
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
    
    //MARK: - UICollectionView Data Source

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HashtagCell
        cell.post = posts[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let post = posts[indexPath.row]
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.post = post
        feedVC.viewSinglePost = true
        self.navigationController?.pushViewController(feedVC, animated: true)
    }
    
    //MARK: - Handlers
    
    func configureNagitationBar(){
        
        guard let hashtag = self.hashtag else { return }
        navigationItem.title = hashtag
    }
    
    //MARK: - Api
    
    func fetchPost(){
        
        guard let hashtag = self.hashtag else { return }
        
        HASHTAG_POST_REF.child(hashtag).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            
            Database.fetchPost(with: postId) { (post) in
                self.posts.append(post)
                self.collectionView.reloadData()
            }
        }
    }
    
    
}