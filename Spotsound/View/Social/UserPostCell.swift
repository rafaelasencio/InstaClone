//
//  UserPostCell.swift
//  Spotsound
//
//  Created by Rafa Asencio on 16/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit

class UserPostCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            guard let imageUrl = post?.imageUrl else {return}
            self.postImageView.loadImage(with: imageUrl)
        }
    }
    
    let postImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(postImageView)
        self.postImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
