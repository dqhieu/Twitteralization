//
//  ProfileViewController.swift
//  Twitteralization
//
//  Created by Dinh Quang Hieu on 7/30/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tweets:[Tweet] = []
    
    var screenname:String!
    
    var userID:NSNumber!
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    let refreshControl = UIRefreshControl()
    
    weak var delegate: ProfileViewControllerDelegate?
    
    var user:User! {
        didSet {
            screenname = user.screenname as! String
            userID = user.userID! as NSNumber
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initTableView()
        initScrollView()
        loadUser()
    }
    
    
    func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sizeToFit()
    }
    
    func initScrollView() {
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadData(0)
    }

    func loadUser() {
        showLoadingProgress(nil)
        TwitterClient.sharedInstance.userShow(userID, screenname: screenname, success: { (user: User) in
            self.user = user
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            self.loadData(0)
        }) { (error: NSError) in
                print(error.localizedDescription)
        }
    }
    
    func loadData(since_id: NSNumber) {
        showLoadingProgress(nil)
        
        
        TwitterClient.sharedInstance.userTimeline(since_id, userID: self.userID, screenname: self.screenname, success: { (tweets: [Tweet]) in
            if tweets.count > 0 {
                if self.isMoreDataLoading {
                    if tweets[0].createdAt?.compare((self.tweets.last?.createdAt)!) == NSComparisonResult.OrderedAscending {
                        self.tweets.appendContentsOf(tweets)
                    }
                }
                else {
                    self.tweets.removeAll()
                    self.tweets = tweets
                }
            }
            
            self.isMoreDataLoading = false
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.loadingMoreView?.stopAnimating()
            self.hideLoadingProgress()
            }, failure: { (error: NSError) in
                self.refreshControl.endRefreshing()
                self.loadingMoreView?.stopAnimating()
                self.hideLoadingProgress()
                print(error.localizedDescription)
        })
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
    
    func showLoadingProgress(text: String?) {
        if let text = text {
            SVProgressHUD.showWithStatus(text)
        }
        else {
            SVProgressHUD.show()
        }
        
    }
    
    func hideLoadingProgress() {
        SVProgressHUD.dismiss()
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
            delegate = cell
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

extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        delegate?.profileViewController(self, didScroll: tableView.contentOffset.y)
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                // Code to load more results
                loadData((tweets.last?.id)!)
                
            }
        }
    }
}

protocol ProfileViewControllerDelegate: class {
    func profileViewController(profileViewController: ProfileViewController, didScroll y: CGFloat)
}
