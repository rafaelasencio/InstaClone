//
//  SearchUserCell.swift
//  Spotsound
//
//  Created by Rafa Asencio on 13/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {

    let profileImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        //add profile imageview
        self.addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 40 / 2
        profileImageView.clipsToBounds = true
        self.textLabel?.text = "Header"
        self.detailTextLabel?.text = "Detail"
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
