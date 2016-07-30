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
    
    func userTimeline(since_id: NSNumber, userID:NSNumber, screenname: String, success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        var params :[String: AnyObject] = [:]
        params["user_id"] = userID
        params["screen_name"] = screenname
        params["count"] = 20
        if since_id != 0 {
            params["since_id"] = since_id
        }
        
        
        GET("1.1/statuses/user_timeline.json", parameters: params, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            //print(response)
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries)
            
            success(tweets)
            
            
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
        })
    }
    
    
    func userShow(userID:NSNumber, screenname: String, success: (User) -> (), failure: (NSError) -> ()) {
        var params :[String: AnyObject] = [:]
        params["user_id"] = userID
        params["screen_name"] = screenname
        
        
        GET("1.1/users/show.json", parameters: params, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            //print(response)
            let dictionary = response as! NSDictionary
            let user = User(dictionary: dictionary)
            
            success(user)
            
            
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
                print("SavecurrentUser")
                self.loginSeccuess?()
                }, failure: { (error: NSError) -> () in
                    self.loginFailure?(error)
            })
            
        }) { (error: NSError!) in
            self.loginFailure?(error)
        }
        
    }
    
    func reTweet(id: NSNumber, success: () -> (), failure: (NSError) -> ()) {
        
        POST("1.1/statuses/retweet/\(id).json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response) in
            print("Retweeted")
            success()
        }) { (task: NSURLSessionDataTask?, error: NSError) in
                print(error.localizedDescription)
            failure(error)
        }
    }
    
    func unRetweet(id: NSNumber, success: () -> (), failure: (NSError) -> ()) {
        POST("1.1/statuses/unretweet/\(id).json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response) in
            print("Unretweeted")
            success()
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            print(error.localizedDescription)
            failure(error)
        }
    }
    
    func loveTweet(id: NSNumber, success: () -> (), failure: (NSError) -> ()) {
        POST("1.1/favorites/create.json", parameters: ["id":id], progress: nil, success: { (task: NSURLSessionDataTask, response) in
            print("Love tweet")
            success()
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            print(error.localizedDescription)
            failure(error)
        }
    }
    
    func unLoveTweet(id: NSNumber, success: () -> (), failure: (NSError) -> ()) {
        POST("1.1/favorites/destroy.json", parameters: ["id":id], progress: nil, success: { (task: NSURLSessionDataTask, response) in
            print("Unlove tweet")
            success()
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            print(error.localizedDescription)
            failure(error)
        }
    }
    
    func reply(text: String, id: NSNumber, success: () -> (), failure: (NSError) -> ()) {
        var params :[String: AnyObject] = [:]
        params["status"] = text
        params["in_reply_to_status_id"] = id
        
        POST("1.1/statuses/update.json", parameters: params, progress: nil, success: { (task: NSURLSessionDataTask, response) in
            success()
            print("Reply")
        }) { (task: NSURLSessionDataTask?, error: NSError) in
                print(error.localizedDescription)
            failure(error)
        }
    }
    
    func postStatus(text: String, success: () -> (), failure: (NSError) -> ()) {
        var params :[String: AnyObject] = [:]
        params["status"] = text
        
        POST("1.1/statuses/update.json", parameters: params, progress: nil, success: { (task: NSURLSessionDataTask, response) in
            
            print("Post status")
            success()
        }) { (task: NSURLSessionDataTask?, error: NSError) in
            print(error.localizedDescription)
            failure(error)
        }
    }
}
