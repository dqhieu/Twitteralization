//
//  User.swift
//  Twitteralization
//
//  Created by Dinh Quang Hieu on 7/23/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var name: NSString?
    var screenname: NSString?
    var profileUrl: NSURL?
    var tagline: NSString?
    var bannerUrl: NSURL?
    var tweetCount: Int?
    var followingCount: Int?
    var followerCount: Int?
    var userID: NSNumber?
    
    
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        userID = dictionary["id"] as? NSNumber ?? 0
        
        self.name = dictionary["name"] as? String
        self.screenname = dictionary["screen_name"] as? String
        
        if let profileUrlString = dictionary["profile_image_url_https"] as? String {
            self.profileUrl = NSURL(string: profileUrlString)
        }
        
        self.tagline = dictionary["description"] as? String
        
        if let bannerUrlString = dictionary["profile_banner_url"] as? String {
            self.bannerUrl = NSURL(string: bannerUrlString)
        }
        
        self.tweetCount = dictionary["statuses_count"] as? Int
        self.followerCount = dictionary["followers_count"] as? Int
        self.followingCount = dictionary["friends_count"] as? Int
    }
    static let userDidLogoutNotification = "UserDidLogout"
    static  var _currentUser: User?
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defautls = NSUserDefaults.standardUserDefaults()
                let userData = defautls.objectForKey("currentUserData")
                
                if let userData = userData {
                    let dictionary = try! NSJSONSerialization.JSONObjectWithData(userData as! NSData, options: [])
                    _currentUser = User(dictionary: dictionary as! NSDictionary)
                }
                
                
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            
            let defautls = NSUserDefaults.standardUserDefaults()
            
            if let user = user {
                let data = try! NSJSONSerialization.dataWithJSONObject(user.dictionary!, options: [])
                defautls.setObject(data, forKey: "currentUserData")
            }
            else {
                defautls.setObject(nil, forKey: "currentUserData")
            }
            
            defautls.synchronize()
        }
    }
}
