//
//  SearchUserCell.swift
//  Spotsound
//
//  Created by Rafa Asencio on 13/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {

    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else {return}
            guard let fullname = user?.name else {return}
            guard let username = user?.username else {return}
            
            profileImageView.loadImage(with: profileImageUrl)
            self.textLabel?.text = username
            self.detailTextLabel?.text = fullname
        }
    }
    let profileImageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        //add profile imageview
        self.addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48 / 2

        self.textLabel?.text = "Header"
        self.detailTextLabel?.text = "Detail"
        
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y - 2, width: self.frame.width - 100, height: detailTextLabel!.frame.height)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        detailTextLabel?.textColor = .lightGray
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
