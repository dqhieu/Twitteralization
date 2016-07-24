//
//  TwitterClient.swift
//  Twitteralization
//
//  Created by Dinh Quang Hieu on 7/23/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com"), consumerKey: "PaPSflDpb485EWtYGwzPU0MeJ", consumerSecret: "vrQUaJvHjmVPU6qI6clkiKcavVnj0pBDwOiIAQwhWNhV0Fq1Ky")
    
    var loginSeccuess: (() -> ())?
    var loginFailure: ((NSError) -> ())?
    
    func login(success: () -> (), failure: (NSError) -> ()) {
        loginSeccuess = success
        loginFailure = failure
        
        deauthorize()
        fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "MyTwitteralization://oauth"), scope: nil, success: { (request: BDBOAuth1Credential!) in
            print("I got a token")
            
            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(request.token)")!
            UIApplication.sharedApplication().openURL(url)
        }) { (error: NSError!) in
            print("error: \(error.localizedDescription)")
            self.loginFailure?(error)
        }
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(User.userDidLogoutNotification, object: nil)
    }
    
    func homeTimeLine(since_id: NSNumber, success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        
        var params :[String: AnyObject] = [:]
        params["count"] = 10
        if since_id != 0 {
            params["since_id"] = since_id
        }
        
        
        GET("1.1/statuses/home_timeline.json", parameters: params, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            //print(response)
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries)
            
            success(tweets)
            
            
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
        })
        
    }
    
    func currentAccount(success: (User) -> (), failure: (NSError) -> ()) {
        GET("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            
            success(user)
            
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
        })
    }
    
    func handleOpenUrl(url :NSURL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) in
            print("I got the access token: \(accessToken.token)")
            
            self.currentAccount({ (user: User) -> () in
                User.currentUser = user
                self.loginSeccuess?()
                }, failure: { (error: NSError) -> () in
                    self.loginFailure?(error)
            })
            
        }) { (error: NSError!) in
            self.loginFailure?(error)
        }
        
    }
    
    func reTweet(id: NSNumber) {
        
        POST("1.1/statuses/retweet/\(id).json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response) in
            print("Retweeted")
        }) { (task: NSURLSessionDataTask?, error: NSError) in
                print(error.localizedDescription)
        }
    }
    
    func unRetweet(id: NSNumber) {
        POST("1.1/statuses/unretweet/\(id).json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response) in
            print("Unretweeted")
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            print(error.localizedDescription)
        }
    }
    
    func loveTweet(id: NSNumber) {
        POST("1.1/favorites/create.json", parameters: ["id":id], progress: nil, success: { (task: NSURLSessionDataTask, response) in
            print("Love tweet")
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            print(error.localizedDescription)
        }
    }
    
    func unLoveTweet(id: NSNumber) {
        POST("1.1/favorites/destroy.json", parameters: ["id":id], progress: nil, success: { (task: NSURLSessionDataTask, response) in
            print("Unlove tweet")
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            print(error.localizedDescription)
        }
    }
}
