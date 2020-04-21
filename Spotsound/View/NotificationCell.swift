//
//  NotificationCell.swift
//  Spotsound
//
//  Created by Rafa Asencio on 20/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    
    //MARK: - Properties
    var delegate: NotificationCellDelegate!
    
    var notification: Notification? {
        
        didSet {
            guard let user = notification?.user else { return }
            guard let profileImageUrl = user.profileImageUrl else { return }
            
            // configure notification label
            configureNotificationLabel()
            
            // configure notification type
            configureNotificationType()
            
            profileImageView.loadImage(with: profileImageUrl)
            
            if let post = notification?.post {
                postImageView.loadImage(with: post.imageUrl)
            }
        }
    }
    
    let profileImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let notificationLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 2
        return lbl
    }()
    
    lazy var followButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Loading", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        btn.layer.cornerRadius = 3
        btn.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var postImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handlePostTapped))
        gesture.numberOfTouchesRequired = 1
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(gesture)
        return iv
    }()
    
    
    // MARK: - Handlers
    
    @objc func handleFollowTapped(){
        delegate.handleFollowTapped(for: self)
    }
    
    @objc func handlePostTapped(){
        delegate.handlePostTapped(for: self)
    }
    
    func configureNotificationLabel(){
        
        guard let notification = self.notification else { return }
        guard let user = notification.user else { return }
        guard let username = user.username else { return }
        let notificationMessage = notification.notificationType.description
        
        let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: " " + notificationMessage, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)]))
        attributedText.append(NSAttributedString(string: " 2d", attributes: [
        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        notificationLabel.attributedText = attributedText
    }
    
    func configureNotificationType(){
        
        guard let notification = self.notification else { return }
        guard let user = notification.user else { return }
        
        var anchor: NSLayoutXAxisAnchor!
        
        if notification.notificationType != .Follow {
            
            // notification for comment or like
            self.addSubview(postImageView)
            postImageView.anchor(top: nil, left: nil, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 40, height: 40)
            postImageView .centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            anchor = postImageView.leftAnchor
            
        } else {
            // notification for follow

            addSubview(followButton)
            followButton.anchor(top: nil, left: nil, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
            followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            followButton.layer.cornerRadius = 3
            anchor = followButton.leftAnchor
            
            user.checkIfUserIsFollowed { (followed) in
                if followed {
                    //confg follow button for followed user
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.setTitleColor(.black, for: .normal)
                    self.followButton.layer.borderColor = UIColor.lightGray.cgColor
                    self.followButton.layer.borderWidth = 0.5
                    self.followButton.backgroundColor = .white
                } else {
                    //confg follow button for non followed user
                    self.followButton.setTitle("Follow", for: .normal)
                    self.followButton.setTitleColor(.white, for: .normal)
                    self.followButton.layer.borderWidth = 0
                    self.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
                }
            }
        }
        
        self.addSubview(notificationLabel)
        notificationLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: anchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        notificationLabel .centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        self.addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 40 / 2
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
