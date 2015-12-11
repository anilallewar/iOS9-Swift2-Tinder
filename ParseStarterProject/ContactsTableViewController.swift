//
//  ContactsTableViewController.swift
//  Tinder
//
//  Created by Anil Allewar on 12/8/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ContactsTableViewController: UITableViewController {

    var userObjectArray = [UserInfoObject]()
    
    @IBOutlet var contactsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userQuery = PFUser.query()
        
        userQuery!.whereKey("accepted", equalTo: (PFUser.currentUser()?.objectId)!)
        userQuery!.whereKey("objectId", containedIn: PFUser.currentUser()?["accepted"] as! [String])
        
        userQuery?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error != nil {
                print(error)
            } else if let results = objects as? [PFUser]{
                for object in results {
                    let userInfo:UserInfoObject = UserInfoObject()
                    userInfo.setUserName(object.username!)
                    
                    
                    if let email = object.email {
                         userInfo.setEmail(email)
                    }
                    
                    if let imageFile = object["image"] as? PFFile {
                        
                        imageFile.getDataInBackgroundWithBlock { (data, error ) -> Void in
                            if let downloadedImage = UIImage(data : data!) {
                                userInfo.setUserImage(downloadedImage)
                                self.contactsTable.reloadData()
                            }
                        }
                        
                    }
                    
                    self.userObjectArray.append(userInfo)
                    self.contactsTable.reloadData()
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userObjectArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        // Configure the cell...
        var textToBeShown = userObjectArray[indexPath.row].getUserName()
        
        if let userEmail = userObjectArray[indexPath.row].getEmail() {
            textToBeShown += " - " + userEmail
        }
        
        cell.textLabel?.text = textToBeShown
        
        if let userImage = userObjectArray[indexPath.row].getUserImage(){
            cell.imageView?.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            cell.imageView?.image = userImage
        }

        return cell
    }
    
    // Send an email when user taps on the cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let userEmail = userObjectArray[indexPath.row].getEmail() {
            let emailUrl = NSURL(string: "mailto:" + userEmail)
            UIApplication.sharedApplication().openURL(emailUrl!)
        }
    }
    
}
