//
//  TweetCell.swift
//  Twitteralization
//
//  Created by Dinh Quang Hieu on 7/23/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit
import AFNetworking

class TweetCell: UITableViewCell {

    @IBOutlet weak var imgViewUserAvatar: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserScreenName: UILabel!
    @IBOutlet weak var lblTimeStamp: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnReply: UIButton!
    @IBOutlet weak var imgViewPhoto: UIImageView!
    
    @IBOutlet weak var constraintImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnRetweet: UIButton!
    @IBOutlet weak var lblRetweet: UILabel!
    @IBOutlet weak var btnLove: UIButton!
    @IBOutlet weak var lblLove: UILabel!
    
    var tweet: Tweet! {
        didSet {
            if let user = tweet.user {
                if let userAvatarUrl = user.profileUrl  {
                    self.imgViewUserAvatar.setImageWithURL(userAvatarUrl)
                    self.imgViewUserAvatar.layer.cornerRadius = 4
                }
                if let userName = user.name as? String {
                    self.lblUserName.text = userName
                }
                if let userScreenName = user.screenname as? String {
                    self.lblUserScreenName.text = "@\(userScreenName)"
                }
            }
            
            if let description = tweet.text as? String {
                self.lblDescription.text = description
            }
            
            
            
            if let photoUrl = tweet.imageUrl {
                
                constraintImageHeight.constant = self.imgViewPhoto.frame.width * 9 / 16
                
                let request = NSURLRequest(URL: photoUrl)
                
                imgViewPhoto.setImageWithURLRequest(request, placeholderImage: nil, success: { (requets: NSURLRequest, response: NSHTTPURLResponse?, image: UIImage) in
                    let scale = image.size.width / self.imgViewPhoto.frame.width
                    self.imgViewPhoto.image = image.resize(CGSize(width: self.imgViewPhoto.frame.width, height: self.constraintImageHeight.constant * scale)).crop169()
                    
                    }, failure: nil)
               self.imgViewPhoto.layer.cornerRadius = 4
                
            }
            else {
                constraintImageHeight.constant = 0
            }
            
            self.lblTimeStamp.text = tweet.timeSinceCreated()
            
            self.lblRetweet.text = String(tweet.retweetCount)
            self.lblLove.text = String(tweet.favoritesCount)
            
            reTweet()
            favorite()
            
            
        }
    }
    
    
    @IBAction func onReply(sender: UIButton) {
        print("reply")
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        print("retweet")
        
        
        if tweet.retweeted {
            TwitterClient.sharedInstance.unRetweet(tweet.id!)
            tweet.retweetCount -= 1
        }
        else {
            TwitterClient.sharedInstance.reTweet(tweet.id!)
            tweet.retweetCount += 1
        }
        tweet.retweeted = !tweet.retweeted
        reTweet()
    }
    
    @IBAction func onLove(sender: AnyObject) {
        print("love")
        
        if tweet.favorited {
            TwitterClient.sharedInstance.unLoveTweet(tweet.id!)
            tweet.favoritesCount -= 1
        }
        else {
            TwitterClient.sharedInstance.loveTweet(tweet.id!)
            tweet.favoritesCount += 1
        }
        tweet.favorited = !tweet.favorited
        favorite()
    }
    
    func reTweet() {
        lblRetweet.text = String(tweet.retweetCount)
        if tweet.retweeted {
            btnRetweet.setImage(UIImage(named: "retweet-action-on"), forState: .Normal)
            lblRetweet.textColor = UIColor.greenColor()
        }
        else {
            btnRetweet.setImage(UIImage(named: "retweet-action"), forState: .Normal)
            lblRetweet.textColor = UIColor.grayColor()
        }
    }

    func favorite() {
        self.lblLove.text = String(tweet.favoritesCount)
        if tweet.favorited {
            btnLove.setImage(UIImage(named: "like-action-on"), forState: .Normal)
            lblLove.textColor = UIColor.redColor()
        }
        else {
            btnLove.setImage(UIImage(named: "like-action"), forState: .Normal)
            lblLove.textColor = UIColor.grayColor()
        }
    }
}

extension UIImage {
    public func crop169() -> UIImage {
        let crop = CGRectMake(0, 0, self.size.width, self.size.width * 9 / 16)
        let cgImage = CGImageCreateWithImageInRect(self.CGImage, crop)
        let image: UIImage = UIImage(CGImage: cgImage!)
        return image
    }
    
    public func resize(size: CGSize) -> UIImage {
        let newSize = CGSizeMake(size.width, size.height)
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}