//
//  SignInViewController.swift
//  Tinder
//
//  Created by Anil Allewar on 10/21/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class SignInViewController: UIViewController {

    @IBOutlet var userImage: UIImageView!

    @IBOutlet var interestedInWomen: UISwitch!
    
    
    @IBAction func signUpClicked(sender: AnyObject) {
        PFUser.currentUser()?["interestedInWomen"] = self.interestedInWomen.on
        PFUser.currentUser()?.save()
        self.performSegueWithIdentifier("showSwipeAfterSignUp", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the label
        // self.showDragLabel()
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name, gender, email"])
        graphRequest.startWithCompletionHandler { (connection, object, error) -> Void in
            if error != nil {
                print("Error while making Graph Request to FB: \(error)")
            } else if let result = object {
                PFUser.currentUser()?["gender"] = result["gender"]
                PFUser.currentUser()?["name"] = result["name"]
                PFUser.currentUser()?["email"] = result["email"]
                
                PFUser.currentUser()?.save()
                
                let facebookUserId = result["id"] as! String
                let facebookProfileUrl = "http://graph.facebook.com/" + facebookUserId + "/picture?type=large"
                
                if let fbPicUrl = NSURL(string: facebookProfileUrl) {
                    if let data = NSData(contentsOfURL: fbPicUrl) {
                        self.userImage.image = UIImage(data: data)
                        let imageFile:PFFile = PFFile(data: data)
                        PFUser.currentUser()?["image"] = imageFile
                        PFUser.currentUser()?.save()
                    }
                }
            }
        }
        
        // Use one time to load users
        // self.loadUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func showDragLabel () -> Void {
        let label = UILabel(frame: CGRectMake(self.view.bounds.width / 2 - 100, self.view.bounds.height / 2 - 50, 200, 100))
        label.text = "Drag Me"
        label.textAlignment = NSTextAlignment.Center
        
        self.view.addSubview(label)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("labelDragged:"))
        label.addGestureRecognizer(panGesture)
        
        label.userInteractionEnabled = true
    }
    
    func labelDragged(gesture:UIPanGestureRecognizer) -> Void {
        let label = gesture.view! as! UILabel
        let transalation = gesture.translationInView(self.view)
        
        // The transalation gives the value relative to the original position of the view; hence x will be negative if moved forward and vice versa. Hence we always add the translation value.
        label.center = CGPoint(x: self.view.bounds.width / 2 + transalation.x , y: self.view.bounds.height / 2 + transalation.y)
        
        let xFromCenter = label.center.x - self.view.bounds.width / 2
        var rotation = CGAffineTransformMakeRotation(xFromCenter/200)
        let scale = min(100 / abs(xFromCenter), 1)
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        
        label.transform = stretch
        
        // Find if the lable was dragged left/right with margin of 100 pixels
        if gesture.state == UIGestureRecognizerState.Ended {
            if label.center.x < 100 {
                print("Not chosen, swiped to left")
            } else if label.center.x > self.view.bounds.width - 100 {
                print("Chosen, swiped to right")
            }
            //Reset the lable to center
            label.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            
            // Reset the rotation and stretch
            rotation = CGAffineTransformMakeRotation(0)
            stretch = CGAffineTransformScale(rotation, 1.0, 1.0)
            label.transform = stretch
        }
    }
    
    private func loadUsers () {
        let urlArray = ["http://i.dailymail.co.uk/i/pix/2012/04/06/article-2126050-127DC75C000005DC-157_306x462.jpg","http://images5.fanpop.com/image/answers/2239000/2239640_1323724716758.36res_265_221.jpg","http://4.bp.blogspot.com/_Unxl7Bz-1Ww/TEnBZ3Zh29I/AAAAAAAAAuU/zowccz_xo-4/s1600/tinkerbell.jpg","http://allcartooncharacters.com/wp-content/uploads/2014/05/Ariel-The-Little-Mermaid.jpg","http://www.ves.lv/wp-content/uploads/2015/03/youloveit_ru_disney_princess_mulan47.jpg","http://magicdisneyheros.altervista.org/images/midl/97.jpg"]
        
        var counter = 1
        
        for url in urlArray {
            if let imageUrl = NSURL(string: url){
                if let data = NSData(contentsOfURL: imageUrl){
                    let imageFile:PFFile = PFFile(data: data)
                    
                    let user:PFUser = PFUser()
                    user.username = "user\(counter)"
                    user.password = "password"
                    user["gender"] = "female"
                    user["interestedInWomen"] = false
                    user["image"] = imageFile
                    user["name"] = "User \(counter)"
                    
                    counter++
                    
                    user.signUpInBackground()
                }
            }
        }
    }
}
