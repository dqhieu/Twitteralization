//
//  HeaderCell.swift
//  Twitteralization
//
//  Created by Dinh Quang Hieu on 7/30/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit
import AFNetworking

class HeaderCell: UITableViewCell {

    @IBOutlet weak var imgViewCover: UIImageView!
    @IBOutlet weak var imgViewAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblScreenName: UILabel!
    
    @IBOutlet weak var lblTweet: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var lblFollower: UILabel!
    
    @IBOutlet weak var coverHeight: NSLayoutConstraint!
    
    var user: User! {
        didSet {
            if let coverUrl =  user.bannerUrl  {
                imgViewCover.setImageWithURL(coverUrl)
                imgViewCover.layer.cornerRadius = 4
                coverHeight.constant = imgViewCover.frame.width / 3
            }
            
            if let imageUrl = user.profileUrl {
                imgViewAvatar.setImageWithURL(imageUrl)
                imgViewAvatar.layer.backgroundColor = UIColor.clearColor().CGColor
                imgViewAvatar.layer.cornerRadius = 4
            }
            
            if let name = user.name {
                lblName.text = name as String
            }
            
            if let screenname = user.screenname {
                lblScreenName.text = "@\(screenname)"
            }
            
            if let tweets = user.tweetCount {
                lblTweet.text = String(tweets)
            }
            
            if let following = user.followingCount {
                lblFollowing.text = String(following)
            }
            
            if let follower = user.followerCount {
                lblFollower.text = String(follower)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
}
