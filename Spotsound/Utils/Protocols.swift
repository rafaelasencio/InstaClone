//
//  Protocols.swift
//  Spotsound
//
//  Created by Rafa Asencio on 13/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//



protocol UserProfileHeaderCellDelegate {
    func handleFollowersButtonTapped(for header: UserProfileHeaderCell)
    func handleFollowingButtonTapped(for header: UserProfileHeaderCell)
    func handleEditProfileButtonTapped(for header: UserProfileHeaderCell)
    func handleSetUserStats(for header: UserProfileHeaderCell)
}
