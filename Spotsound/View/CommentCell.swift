//
//  CommentCell.swift
//  Spotsound
//
//  Created by Rafa Asencio on 19/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    let profileImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let commentLabel: UILabel = {
        let lbl = UILabel()
        let attributedText = NSMutableAttributedString(string: "username", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: " Some text comment", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]))
        attributedText.append(NSAttributedString(string: " 2d", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12),
                                                                             NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        lbl.attributedText = attributedText
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48 / 2
        
        self.addSubview(commentLabel)
        commentLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        commentLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
