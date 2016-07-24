//
//  TweetsViewController.swift
//  Twitteralization
//
//  Created by Dinh Quang Hieu on 7/23/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit
import SVProgressHUD

class TweetsViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var tweets: [Tweet] = []
    let refreshControl = UIRefreshControl()
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        initScrollView()
        loadData(0)
    }

    func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sizeToFit()
    }
    
    func loadData(since_id: NSNumber) {
        showLoadingProgress(nil)
        if !isMoreDataLoading {
            tweets.removeAll()
        }
        TwitterClient.sharedInstance.homeTimeLine(since_id, success: { (tweets: [Tweet]) -> () in
            if self.isMoreDataLoading {
                if tweets.count > 0 {
                    self.tweets.appendContentsOf(tweets)
                }
            }
            else {
                self.tweets = tweets
            }
            
            self.isMoreDataLoading = false
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.loadingMoreView?.stopAnimating()
            self.hideLoadingProgress()
        }) { (error: NSError) -> () in
            print("error: \(error.localizedDescription)")
        }
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
    
    @IBAction func onLogout(sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
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

extension TweetsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
        cell.tweet = tweets[indexPath.row]
        return cell
    }
    
}

class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .Gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.hidden = true
    }
    
    func startAnimating() {
        self.hidden = false
        self.activityIndicatorView.startAnimating()
    }
}

extension TweetsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
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
                print((tweets.last?.id)!)
                // Code to load more results
                loadData((tweets.last?.id)!)
                
            }
        }
    }
}