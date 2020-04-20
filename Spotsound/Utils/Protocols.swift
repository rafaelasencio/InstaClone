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

protocol FollowCellDelegate {
    func handleFollowTapped(for cell: FollowLikeCell)
}

protocol FeedCellDelegate {
    func handleUsernameTapped(for cell: FeedCell)
    func handleOptionsTapped(for cell: FeedCell)
    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool)
    func handleCommentTapped(for cell: FeedCell)
    func handleConfigureLikeButton(for cell: FeedCell)
    func handleShowLikes(for cell: FeedCell)
}

protocol Printable {
    
    var description: String {get}
}
