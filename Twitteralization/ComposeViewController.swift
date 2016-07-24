//
//  ComposeViewController.swift
//  Twitteralization
//
//  Created by Dinh Quang Hieu on 7/24/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit
import AFNetworking

@objc protocol ComposeViewControllerDelegate {
    optional func composeViewController(composeViewController: ComposeViewController, didPostStatus status:String)
}

class ComposeViewController: UIViewController {
    
    var user:User = User.currentUser!
    
    @IBOutlet weak var imgViewAvatar: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lblCharCount: UILabel!
    @IBOutlet weak var btnTweet: UIButton!
    
    @IBOutlet weak var keyBoardHeightConstraint: NSLayoutConstraint!

    weak var delegate:ComposeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let profileUrl = user.profileUrl  {
            imgViewAvatar.setImageWithURL(profileUrl)
        }
        imgViewAvatar.layer.cornerRadius = 4
        
        textView.text = "What's happending?"
        textView.textColor = UIColor.lightGrayColor()
        textView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ComposeViewController.onShowKeyboard(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ComposeViewController.onHideKeyboard), name: UIKeyboardDidHideNotification, object: nil)
    }

    @IBAction func onTweet(sender: AnyObject) {
        TwitterClient.sharedInstance.postStatus(textView.text, success: { 
            self.delegate?.composeViewController!(self, didPostStatus: self.textView.text)
            self.dismissViewControllerAnimated(true, completion: nil)
        }) { (error: NSError) in
            
        }
        
    }
   
    @IBAction func onClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
    
}

extension ComposeViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What's happending?"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.text != "What's happending?" && textView.text != "" {
            lblCharCount.text = String(140 - textView.text.characters.count)
            btnTweet.userInteractionEnabled = true
            btnTweet.backgroundColor = UIColor(red: 33.0 / 255.0, green: 141.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0)
            btnTweet.layer.cornerRadius = 4
        }
        else {
            btnTweet.userInteractionEnabled = false
            btnTweet.backgroundColor = UIColor.clearColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        if updatedText.characters.count < 140 {
            return true
        }
        return false
    }
}