//
//  DetailViewController.swift
//  Twitteralization
//
//  Created by Dinh Quang Hieu on 7/24/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit

@objc protocol DetailViewControllerDelegate {
    optional func detailViewController(detailViewController: DetailViewController, didRetweet status: Bool)
    optional func detailViewController(detailViewController: DetailViewController, didLove status: Bool)
}

@objc protocol DetailViewControllerReplyDelegate {
    optional func detailViewController(detailViewController: DetailViewController, didReply text: String, atIndexPath indexPath: NSIndexPath)
}

class DetailViewController: UIViewController {

    @IBOutlet weak var imgViewAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblScreenName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgViewPhoto: UIImageView!
    @IBOutlet weak var lblTimeStamp: UILabel!
    @IBOutlet weak var btnRetweet: UIButton!
    @IBOutlet weak var lblRetweet: UILabel!
    @IBOutlet weak var btnLove: UIButton!
    @IBOutlet weak var lblLove: UILabel!
    
    @IBOutlet weak var imgConstraintHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnReply: UIButton!
    @IBOutlet weak var lblCharCount: UILabel!
    @IBOutlet weak var lblText: UITextField!
    weak var delegate: DetailViewControllerDelegate?
    weak var replyDelegate: DetailViewControllerReplyDelegate?
    
    var tweet:Tweet!
    var indexPath: NSIndexPath!
    
    @IBOutlet weak var keyBoardHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = tweet.user {
            if let userAvatarUrl = user.profileUrl  {
                self.imgViewAvatar.setImageWithURL(userAvatarUrl)
                self.imgViewAvatar.layer.cornerRadius = 4
            }
            if let userName = user.name as? String {
                self.lblName.text = userName
            }
            if let userScreenName = user.screenname as? String {
                self.lblScreenName.text = "@\(userScreenName)"
            }
        }
        
        if let description = tweet.text as? String {
            self.lblDescription.text = description
        }
        
        
        
        if let photoUrl = tweet.imageUrl {
            
            imgConstraintHeight.constant = self.imgViewPhoto.frame.width * 9 / 16
            
            let request = NSURLRequest(URL: photoUrl)
            
            imgViewPhoto.setImageWithURLRequest(request, placeholderImage: nil, success: { (requets: NSURLRequest, response: NSHTTPURLResponse?, image: UIImage) in
                let scale = image.size.width / self.imgViewPhoto.frame.width
                self.imgViewPhoto.image = image.resize(CGSize(width: self.imgViewPhoto.frame.width, height: self.imgConstraintHeight.constant * scale)).crop169()
                
                }, failure: nil)
            self.imgViewPhoto.layer.cornerRadius = 4
            
        }
        else {
            imgConstraintHeight.constant = 0
        }
        
        self.lblTimeStamp.text = tweet.timeSinceCreated()
        
        self.lblRetweet.text = String(tweet.retweetCount)
        self.lblLove.text = String(tweet.favoritesCount)
        
        reTweet()
        favorite()

        btnReply.layer.cornerRadius = 4
        lblCharCount.layer.cornerRadius = 4
        lblText.text = "\(lblScreenName.text!) "
        lblCharCount.text = String(140 - (lblText.text?.characters.count)!)
        lblText.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailViewController.onShowKeyboard(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailViewController.onHideKeyboard), name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func onShowKeyboard(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        let keyboardHeight = keyboardRectangle.height
        
        keyBoardHeightConstraint.constant = keyboardHeight
    }
    
    func onHideKeyboard() {
        keyBoardHeightConstraint.constant = 0
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        if tweet.retweeted {
            tweet.retweetCount -= 1
        }
        else {
            tweet.retweetCount += 1
        }
        tweet.retweeted = !tweet.retweeted
        reTweet()
        delegate?.detailViewController!(self, didRetweet: tweet.retweeted)
        

    }
    
    @IBAction func onLove(sender: AnyObject) {
        if tweet.favorited {
            tweet.favoritesCount -= 1
        }
        else {
            tweet.favoritesCount += 1
        }
        tweet.favorited = !tweet.favorited
        favorite()
        delegate?.detailViewController!(self, didLove: tweet.favorited)
        
    }
    
    @IBAction func onReply(sender: AnyObject) {
        TwitterClient.sharedInstance.reply(lblText.text!, id: tweet.id!, success: {
            // dosomething here
            self.navigationController?.popViewControllerAnimated(true)
            self.replyDelegate?.detailViewController!(self, didReply: self.lblText.text!, atIndexPath: self.indexPath)
        }) { (error: NSError) in
                print(error.localizedDescription)
        }
        
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

    @IBAction func onTextChanged(sender: AnyObject) {
        lblCharCount.text = String(140 - (lblText.text?.characters.count)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension DetailViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentText:NSString = lblText.text!
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:string)
        
        if updatedText.characters.count < 140 {
            return true
        }
        return false
    }
}
