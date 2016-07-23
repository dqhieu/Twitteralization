//
//  ViewController.swift
//  Twitteralization
//
//  Created by Dinh Quang Hieu on 7/22/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogin(sender: UIButton) {
        TwitterClient.sharedInstance.login({ () -> () in
            print("I have logged in")
            self.performSegueWithIdentifier("segueLogin", sender: nil)
        }) { (error: NSError) in
            print(error.localizedDescription)
        }
        
        
    }

}

