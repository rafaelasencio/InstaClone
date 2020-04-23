//
//  FeedCell.swift
//  Spotsound
//
//  Created by Rafa Asencio on 17/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase
import ActiveLabel

class FeedCell: UICollectionViewCell {
    
    var delegate: FeedCellDelegate?
    
    var post: Post? {
        
        didSet {
            guard let ownerUid = post?.ownerId else {return}
            guard let imageURL = post?.imageUrl else {return}
            
            Database.fetchUser(with: ownerUid) { (user) in
                self.profileImageView.loadImage(with: user.profileImageUrl)
                self.usernameButton.setTitle(user.username, for: .normal)
                self.configurePostCaption(user: user)
            }
            
            self.postImageView.loadImage(with: imageURL)
            guard let likes = post?.likes else {return}
            self.likesLabel.text = "\(likes) likes"
            configureLikeButton()
        }
    }
    
    let profileImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    lazy var postImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapLike))
        gesture.numberOfTapsRequired = 2
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(gesture)
        return iv
    }()
    
    lazy var usernameButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("username", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        btn.addTarget(self, action: #selector(handleUsernameTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var optionsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("•••", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(handleOptionTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var likeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var commentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var messageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "send2"), for: .normal)
        btn.tintColor = .black
        return btn
    }()
    
    let savePostButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        btn.tintColor = .black
        return btn
    }()
    
    lazy var likesLabel: UILabel = {
       let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 12)
        lbl.text = "3 likes"
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleShowLikes))
        gesture.numberOfTouchesRequired = 1
        lbl.isUserInteractionEnabled = true
        lbl.addGestureRecognizer(gesture)
        return lbl
    }()
    
    let captionLabel: ActiveLabel = {
        let lbl = ActiveLabel()
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let postTimeLabel: UILabel = {
       let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 10)
        lbl.textColor = .lightGray
        lbl.text = "2 DAYS AGO"
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(profileImageView)
        profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        self.addSubview(usernameButton)
        self.usernameButton.anchor(top: nil, left: self.profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.usernameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        self.addSubview(optionsButton)
        self.optionsButton.anchor(top: nil, left: nil, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        self.usernameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
         self.addSubview(postImageView)
        postImageView.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.postImageView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1).isActive = true
        
        configureActionButtons()
        
        self.addSubview(likesLabel)
        self.likesLabel.anchor(top: self.likeButton.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: -4, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.addSubview(captionLabel)
        self.captionLabel.anchor(top: likesLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        self.addSubview(postTimeLabel)
        self.postTimeLabel.anchor(top: self.captionLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func configureActionButtons() {
        
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, messageButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        self.addSubview(stackView)
        stackView.anchor(top: self.postImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        
        self.addSubview(savePostButton)
        savePostButton.anchor(top: self.postImageView.bottomAnchor, left: nil, bottom: nil, right: self.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 20, height: 24)
        
    }
    
    func configurePostCaption(user: User) {
        
        guard let post = self.post else {return}
        guard let caption = post.caption else {return}
        guard let username = post.user.username else { return }
        
        // look for username as pattern
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        // enable username as custom type
        captionLabel.enabledTypes = [.mention, .hashtag, .url, customType]
        captionLabel.configureLinkAttribute = { (type, attributes, isSelected) in
            var atts = attributes
            switch type {
            case .custom: atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
            default: ()
            }
            return atts
        }
        captionLabel.customize { (label) in
            label.text = "\(username) \(caption)"
            label.customColor[customType] = .black
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .black
            captionLabel.numberOfLines = 2
        }
        
        postTimeLabel.text = " 2 Days Ago"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Handlers
    
    @objc func handleUsernameTapped(){
        delegate?.handleUsernameTapped(for: self)
    }
    
    @objc func handleOptionTapped(){
        delegate?.handleOptionsTapped(for: self)
    }
    
    @objc func handleCommentTapped(){
        delegate?.handleCommentTapped(for: self)
    }
    
    @objc func handleLikeTapped(){
        delegate?.handleLikeTapped(for: self, isDoubleTap: false)
    }
    
    @objc func handleShowLikes(){
        delegate?.handleShowLikes(for: self)
    }
    
    @objc func handleDoubleTapLike(){
        delegate?.handleLikeTapped(for: self, isDoubleTap: true)
    }
    
    func configureLikeButton(){
        delegate?.handleConfigureLikeButton(for: self)
    }
}
