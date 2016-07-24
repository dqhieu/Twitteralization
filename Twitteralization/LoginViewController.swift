//
//  ViewController.swift
//  Twitteralization
//
//  Created by Dinh Quang Hieu on 7/22/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import PulsingHalo
import SVProgressHUD

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initHalo()
    }

    func initHalo() {
        let halo = PulsingHaloLayer()
        halo.haloLayerNumber = 2
        halo.radius = self.view.frame.width / 2
        halo.backgroundColor = UIColor.whiteColor().CGColor
        halo.position = view.center
        view.layer.addSublayer(halo)
        halo.start()
    }
    
    @IBAction func onLogin(sender: UIButton) {
        showLoadingProgress(nil)
        TwitterClient.sharedInstance.login({ () -> () in
            print("I have logged in")
            self.hideLoadingProgress()
            self.performSegueWithIdentifier("segueLogin", sender: nil)
        }) { (error: NSError) in
            self.hideLoadingProgress()
            print(error.localizedDescription)
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
