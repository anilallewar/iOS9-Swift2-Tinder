//
//  SwipeViewController.swift
//  Tinder
//
//  Created by Anil Allewar on 10/23/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class SwipeViewController: UIViewController {

    
    @IBOutlet var userImage: UIImageView!
    
    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet var rejectSwipeImage: UIImageView!
    
    @IBOutlet var acceptSwipeImage: UIImageView!
    
    var rejectSwipeImageCenterX: CGFloat!
    var rejectSwipeImageCenterY: CGFloat!
    
    var acceptSwipeImageCenterX: CGFloat!
    var acceptSwipeImageCenterY: CGFloat!
    
    var displayedUserId:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the original X/Y coordinates of the images so that they can be placed after dragging
        self.rejectSwipeImageCenterX = rejectSwipeImage.center.x
        self.rejectSwipeImageCenterY = rejectSwipeImage.center.y
        
        self.acceptSwipeImageCenterX = acceptSwipeImage.center.x
        self.acceptSwipeImageCenterY = acceptSwipeImage.center.y
       
        self.addPanGestureToAcceptRejectImages()
       
        self.getLoggedInUserLocation()
        
        self.getNextUserForDisplay()
        
    }

    private func addPanGestureToAcceptRejectImages() -> Void {
        // Make tha accept/reject image circular and have border
        self.rejectSwipeImage.layer.cornerRadius = self.rejectSwipeImage.frame.size.width / 2
        self.rejectSwipeImage.clipsToBounds = true
        self.rejectSwipeImage.layer.borderWidth = 3.0
        self.rejectSwipeImage.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.acceptSwipeImage.layer.cornerRadius = self.acceptSwipeImage.frame.size.width / 2
        self.acceptSwipeImage.clipsToBounds = true
        self.acceptSwipeImage.layer.borderWidth = 3.0
        self.acceptSwipeImage.layer.borderColor = UIColor.whiteColor().CGColor
        
        let panRejectGesture = UIPanGestureRecognizer(target: self, action: Selector("rejectDragged:"))
        rejectSwipeImage.addGestureRecognizer(panRejectGesture)
        rejectSwipeImage.userInteractionEnabled = true
        
        let panAcceptGesture = UIPanGestureRecognizer(target: self, action: Selector("acceptDragged:"))
        acceptSwipeImage.addGestureRecognizer(panAcceptGesture)
        acceptSwipeImage.userInteractionEnabled = true
    }
    
    /*
        Function to get the next user which the current user might be interested in accepting/rejecting.
    
        This is called both on load and when the user accept/reject the currently displayed user so as to show the next user.
    */
    private func getNextUserForDisplay() -> Void {
        
        let userQuery = PFUser.query()
        if PFUser.currentUser()?["interestedInWomen"] as! Bool == true {
            userQuery?.whereKey("gender", equalTo: "female")
        } else {
            userQuery?.whereKey("gender", equalTo: "male")
        }
        
        // Create a set to be used for getting only those user's already not in accepted/rejected
        // If you use an array then the objectId object is constrained only against the last array
        var alreadySeenUsersSet = Set<String>()
        
        if let acceptedArray = PFUser.currentUser()?["accepted"] as? [String]{
            for item in acceptedArray {
                alreadySeenUsersSet.insert(item)
            }
        }
        
        if let rejectedArray = PFUser.currentUser()?["rejected"] as? [String]{
            for item in rejectedArray {
                alreadySeenUsersSet.insert(item)
            }
        }
        if alreadySeenUsersSet.isEmpty == false {
            userQuery?.whereKey("objectId", notContainedIn: Array(alreadySeenUsersSet))
        }
        
        userQuery?.whereKey("objectId", notEqualTo: (PFUser.currentUser()?.objectId!)!)
        
        // Setup geofencing based on lat/long
        if let latitude = PFUser.currentUser()?["location"]?.latitude {
            if let longitude = PFUser.currentUser()?["location"]?.longitude{
                    userQuery?.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: latitude - 1, longitude: longitude - 1), toNortheast: PFGeoPoint(latitude: latitude + 1, longitude: longitude + 1))
            }
        }
        
        userQuery!.limit = 1
        
        userQuery?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error != nil {
                print(error)
            } else if let objects = objects as? [PFObject] {
                if objects.isEmpty == false {
                    for object in objects {
                        self.displayedUserId = object.objectId!
                        
                        let imageFile = object["image"] as! PFFile
                        
                        imageFile.getDataInBackgroundWithBlock { (data, error ) -> Void in
                            if let downloadedImage = UIImage(data : data!) {
                                self.userImage.image = downloadedImage
                            }
                        }
                    }
                } else {
                    // No user's found
                    self.infoLabel.text = "No more matching users found!"
                    self.userImage.image = UIImage(named: "no_more.jpeg")
                    self.acceptSwipeImage.userInteractionEnabled = false
                    self.rejectSwipeImage.userInteractionEnabled = false
                }
            }
        })
    }
    
    // Get the location for the current user
    private func getLoggedInUserLocation () {
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) -> Void in
            if let geoPoint = geoPoint {
                PFUser.currentUser()?["location"] = geoPoint
                // Need sync operation for the getNextUser to work
                PFUser.currentUser()?.save()
            }
        }
    }
    
    // Function called when the reject button is dragged
    func rejectDragged(gesture:UIPanGestureRecognizer) {
        let rejectImageView = gesture.view! as! UIImageView
        let transalation = gesture.translationInView(self.view)
        
        // The transalation gives the value relative to the original position of the view; hence x will be negative if moved forward and vice versa. Hence we always add the translation value.
        rejectImageView.center = CGPoint(x: self.rejectSwipeImageCenterX + transalation.x , y: self.rejectSwipeImageCenterY + transalation.y)
        
        let xFromCenter = rejectImageView.center.x - self.view.bounds.width / 2
        var rotation = CGAffineTransformMakeRotation(xFromCenter/200)
        let scale = min(100 / abs(xFromCenter), 1)
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        
        rejectImageView.transform = stretch
        
        // Find if the lable was dragged left with margin of 100 pixels
        if gesture.state == UIGestureRecognizerState.Ended {
            if rejectImageView.center.x < 100 {
                PFUser.currentUser()?.addUniqueObjectsFromArray([displayedUserId], forKey: "rejected")
                PFUser.currentUser()?.saveInBackgroundWithBlock({ (result, error) -> Void in
                    if error != nil {
                        print(error)
                    } else if result == true {
                        // Get the next user to display
                        self.getNextUserForDisplay()
                    }
                })
            }
            
            //Reset the lable to center
            rejectImageView.center = CGPoint(x: self.rejectSwipeImageCenterX, y: self.rejectSwipeImageCenterY)
            
            // Reset the rotation and stretch
            rotation = CGAffineTransformMakeRotation(0)
            stretch = CGAffineTransformScale(rotation, 1.0, 1.0)
            rejectImageView.transform = stretch
            
        }
    }

    // Function called when the accept button is dragged
    func acceptDragged(gesture:UIPanGestureRecognizer) {
        let acceptImageView = gesture.view! as! UIImageView
        let transalation = gesture.translationInView(self.view)
        
        // The transalation gives the value relative to the original position of the view; hence x will be negative if moved forward and vice versa. Hence we always add the translation value.
        acceptImageView.center = CGPoint(x: self.acceptSwipeImageCenterX + transalation.x , y: self.acceptSwipeImageCenterY + transalation.y)
        
        let xFromCenter = acceptImageView.center.x - self.view.bounds.width / 2
        var rotation = CGAffineTransformMakeRotation(xFromCenter/200)
        let scale = min(100 / abs(xFromCenter), 1)
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        
        acceptImageView.transform = stretch
        
        // Find if the lable was dragged left with margin of 100 pixels
        if gesture.state == UIGestureRecognizerState.Ended {
            if acceptImageView.center.x > self.view.bounds.width - 100 {
                PFUser.currentUser()?.addUniqueObjectsFromArray([displayedUserId], forKey: "accepted")
                PFUser.currentUser()?.saveInBackgroundWithBlock({ (result, error) -> Void in
                    if error != nil {
                        print(error)
                    } else if result == true {
                        // Get the next user to display
                        self.getNextUserForDisplay()
                    }
                })
            }
            
            //Reset the lable to center
            acceptImageView.center = CGPoint(x: self.acceptSwipeImageCenterX, y: self.acceptSwipeImageCenterY)
            
            // Reset the rotation and stretch
            rotation = CGAffineTransformMakeRotation(0)
            stretch = CGAffineTransformScale(rotation, 1.0, 1.0)
            acceptImageView.transform = stretch
       }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logOut" {
            PFUser.logOut()
        }
    }
}
