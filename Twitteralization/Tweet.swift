//
//  Tweet.swift
//  Twitteralization
//
//  Created by Dinh Quang Hieu on 7/23/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit

class Tweet: NSObject {

    var id: NSNumber?
    var text: NSString?
    var createdAt: NSDate?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var imageUrl: NSURL?
    var retweeted: Bool = false
    var favorited: Bool = false
    
    var user: User?
    
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        id = (dictionary["id"] as? NSNumber) ?? 0
        
        text = dictionary["text"] as? String
        
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        
        let timeCreatedString = dictionary["created_at"] as? String
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        if timeCreatedString != nil {
            createdAt = formatter.dateFromString(timeCreatedString!)
        }
        
        if let userDictionary = dictionary["user"] as? NSDictionary {
            self.user = User(dictionary: userDictionary)
        }
        
        if let media = dictionary["extended_entities"] as? NSDictionary {
            if let medias = media["media"] as? NSArray {
                if medias[0]["type"] as! String  == "photo" {
                    self.imageUrl = NSURL(string: medias[0]["media_url_https"] as! String)
                }
            }
        }
        
        if let retweeted = dictionary["retweeted"] as? Bool {
            self.retweeted = retweeted
        }
        
        if let favorited = dictionary["favorited"] as? Bool {
            self.favorited = favorited
        }
    }
    
    func timeSinceCreated() -> String {
        if createdAt != nil {
            let totalTime = NSDate().timeIntervalSinceDate(createdAt!)
            if totalTime < 60 {
                return String(Int(totalTime)) + "s"
            } else if totalTime < 3600 {
                return String(Int(totalTime / 60)) + "m"
            } else if totalTime < 24*3600 {
                return String(Int(totalTime / 60 / 60)) + "h"
            } else {
                return String(Int(totalTime / 60 / 60 / 24)) + "d"
            }
        }
        return ""
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
            
        }
        
        return tweets
    }
    
}
