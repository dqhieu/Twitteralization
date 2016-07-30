//
//  ProfileViewController.swift
//  Twitteralization
//
//  Created by Dinh Quang Hieu on 7/30/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit
import AFNetworking

class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tweets:[Tweet] = []
    
    var screenname:String!
    
    var userID:NSNumber!
    
    var user:User! {
        didSet {
            screenname = user.screenname as! String
            userID = user.userID! as NSNumber
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initTableView()
        loadUser()
    }
    
    func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sizeToFit()
    }

    func loadUser() {
        TwitterClient.sharedInstance.userShow(userID, screenname: screenname, success: { (user: User) in
            self.user = user
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            TwitterClient.sharedInstance.userTimeline(0, userID: self.userID, screenname: self.screenname, success: { (tweets: [Tweet]) in
                self.tweets = tweets
                self.tableView.reloadData()
                }, failure: { (error: NSError) in
                    print(error.localizedDescription)
            })
        }) { (error: NSError) in
                print(error.localizedDescription)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueDetailFromProfile" {
            let detailViewController = segue.destinationViewController as! DetailViewController
            let cell = sender as! TweetCell
            let indexPath = tableView.indexPathForCell(cell)
            detailViewController.tweet = tweets[indexPath!.row]
            detailViewController.delegate = cell
            detailViewController.indexPath = indexPath
            
        }
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return tweets.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
            cell.user = user
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
            let tweet = tweets[indexPath.row]
            tweet.user = self.user
            cell.tweet = tweet
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
