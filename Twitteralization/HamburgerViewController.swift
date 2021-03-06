//
//  HamburgerViewController.swift
//  Twitteralization
//
//  Created by Dinh Quang Hieu on 7/28/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {

    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
    var originLeftMargin:CGFloat!
    
    var menuViewController: UIViewController! {
        didSet {
            view.layoutIfNeeded()
            menuView.addSubview(menuViewController.view)
        }
    }
    
    var contentViewController: UIViewController! {
        didSet(oldContentViewController) {
            view.layoutIfNeeded()
            
            if oldContentViewController != nil {
                oldContentViewController.willMoveToParentViewController(nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMoveToParentViewController(nil)
            }
            
            contentViewController.willMoveToParentViewController(self)
            contentView.addSubview(contentViewController.view)
            contentViewController.didMoveToParentViewController(self)
            
            UIView.animateWithDuration(0.3) { 
                self.leftMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initNavigationBar()
    }
    
    func initNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33.0 / 255.0, green: 141.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0)
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "twitter_navbar"))
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
    }
    
    @IBAction func onPanGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            originLeftMargin = leftMarginConstraint.constant
        }
        else if sender.state == UIGestureRecognizerState.Changed {
            if translation.x < 0 {
                return
            }
            leftMarginConstraint.constant = originLeftMargin + translation.x
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            UIView.animateWithDuration(0.3, animations: {
                if velocity.x > 0 {
                    self.leftMarginConstraint.constant = self.view.frame.size.width - 100
                }
                else {
                    self.leftMarginConstraint.constant = 0
                }
                self.view.layoutIfNeeded()
            })
        }
    }

    
}
