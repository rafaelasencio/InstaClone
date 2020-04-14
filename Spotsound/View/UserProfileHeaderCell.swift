//
//  UserProfileHeaderCell.swift
//  Spotsound
//
//  Created by Rafa Asencio on 13/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase


class UserProfileHeaderCell: UICollectionViewCell {
    
    
    //MARK: - Properties
    
    var delegate: UserProfileHeaderCellDelegate?
    
    var user: User? {
        didSet {

            configureEditProfileFollowButton()
            setUserStats(for: user)
            let fullname = user?.name
            fullnameLabel.text = fullname
            
            guard let profileImage = user?.profileImageUrl else {return}
            profileImageView.loadImage(with: profileImage)
        }
    }
    
    let profileImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let fullnameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 12)
        return lbl
    }()
    
    let postLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        lbl.attributedText = attributedText
        return lbl
    }()
    
    lazy var followersLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        lbl.attributedText = attributedText
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        gesture.numberOfTapsRequired = 1
        lbl.isUserInteractionEnabled = true
        lbl.addGestureRecognizer(gesture)
        return lbl
    }()
    
    lazy var followingLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        lbl.attributedText = attributedText
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        gesture.numberOfTapsRequired = 1
        lbl.isUserInteractionEnabled = true
        lbl.addGestureRecognizer(gesture)
        return lbl
    }()
    
    let followLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Follow"
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.font = UIFont.boldSystemFont(ofSize: 12)
        return lbl
    }()
    
    lazy var editProfileFollowButton: UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        return button
    }()

    
    let grindButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        return btn
    }()
    
    let listButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        return btn
    }()
    
    let bookmarkButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        return btn
    }()
    
    func configureUserStats(){
        let stackView = UIStackView(arrangedSubviews: [postLabel, followersLabel, followingLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        self.addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    func setUserStats(for user: User?){
        delegate?.handleSetUserStats(for: self)
    }
    
    func configureBottomToolBar(){
        let topDividerView = UIView()
        topDividerView.backgroundColor = .lightGray
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .lightGray
        let stackView = UIStackView(arrangedSubviews: [grindButton, listButton, bookmarkButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        self.addSubview(stackView)
        self.addSubview(topDividerView)
        self.addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        topDividerView.anchor(top: stackView.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    func configureEditProfileFollowButton(){
        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        guard let user = self.user else {return}
        
        if currentUserUid == user.uid {
            // Configure button for current user
            editProfileFollowButton.setTitle("Edit Profile", for: .normal)
        } else {
            editProfileFollowButton.setTitleColor(.white, for: .normal)
            editProfileFollowButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            // Perform task before set button title
            user.checkIfUserIsFollowed { (followed) in
                if followed {
                    self.editProfileFollowButton.setTitle("Following", for: .normal)
                } else {
                    self.editProfileFollowButton.setTitle("Follow", for: .normal)
                }
            }
        }
    }
    
    //MARK: - Handlers
    
    @objc func handleFollowersTapped() {
        delegate?.handleFollowersButtonTapped(for: self)
    }
    
    @objc func handleFollowingTapped() {
        delegate?.handleFollowingButtonTapped(for: self)
    }

    @objc func handleEditProfileFollow() {
        delegate?.handleEditProfileButtonTapped(for: self)
    }
    
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(profileImageView)
        profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        self.addSubview(fullnameLabel)
        fullnameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        configureUserStats()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postLabel.bottomAnchor, left: postLabel.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 12, width: 0, height: 30)
        
        configureBottomToolBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
