//
//  NewMessageCell.swift
//  Spotsound
//
//  Created by Rafa Asencio on 22/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit

class NewMessageCell: UITableViewCell {

    //MARK: - Properties
    
    var user: User? {
        
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            guard let username = user?.username else { return }
            guard let fullname = user?.name else { return }
            
            profilemageView.loadImage(with: profileImageUrl)
            textLabel?.text = username
            detailTextLabel?.text = fullname
        }
    }
    
    let profilemageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(profilemageView)
        profilemageView.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profilemageView.layer.cornerRadius = 50 / 2
        profilemageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        textLabel?.text = "algoo"
        detailTextLabel?.text = "blablabal"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
         
        // position for label and detail text
        textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: (textLabel!.frame.height))
        detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y + 2, width: self.frame.width - 108, height: (detailTextLabel!.frame.height))
        
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        detailTextLabel?.textColor = .lightGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
