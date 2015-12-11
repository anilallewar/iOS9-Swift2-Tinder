//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInButtonClicked(sender: AnyObject) {
        // Setup Facebook login
        let permissions = ["public_profile", "email"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions, block: {
            (user: PFUser?, error: NSError?) -> Void in
            
            if let error = error {
                print(error)
            } else {
                if let user = user {
                    if let _ = user["interestedInWomen"] {
                        self.performSegueWithIdentifier("showSwipeScreen", sender: self)
                    } else {
                        self.performSegueWithIdentifier("showSignedInScreen", sender: self)
                    }
                }
            }
        })
    }
    
    // Show the correct view based on whether the user is signed in or not
    override func viewDidAppear(animated: Bool) {
       if let logggedInUserName = PFUser.currentUser()?.username {
            print("The current logged in user: \(logggedInUserName) and interestedInWomen:")
        if let _ = PFUser.currentUser()?["interestedInWomen"] {
                self.performSegueWithIdentifier("showSwipeScreen", sender: self)
            } else {
                self.performSegueWithIdentifier("showSignedInScreen", sender: self)
            }
        }
    }
}

