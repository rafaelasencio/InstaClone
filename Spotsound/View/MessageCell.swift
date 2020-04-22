//
//  MessageCell.swift
//  Spotsound
//
//  Created by Rafa Asencio on 22/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    //MARK: - Properties
    
    let profilemageView: CustomImageView = {
       let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let timeStampLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textColor = .darkGray
        lbl.text = "rafa"
        return lbl
    }()
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.addSubview(profilemageView)
        profilemageView.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profilemageView.layer.cornerRadius = 50 / 2
        profilemageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        self.addSubview(timeStampLabel)
        timeStampLabel.anchor(top: self.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        textLabel?.text = "usernameee"
        detailTextLabel?.text = "somedetailss details"
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


