//
//  Protocols.swift
//  Spotsound
//
//  Created by Rafa Asencio on 13/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//



protocol UserProfileHeaderCellDelegate {
    func followersButtonTapped(for header: UserProfileHeaderCell)
    func followingButtonTapped(for header: UserProfileHeaderCell)
    func editProfileButtonTapped(for header: UserProfileHeaderCell)
    func setUserStats(for header: UserProfileHeaderCell)
}
