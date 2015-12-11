//
//  UserInfoObject.swift
//  Tinder
//
//  Created by Anil Allewar on 12/8/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation

class UserInfoObject {
    private var userName: String!
    private var userImage: UIImage?
    private var email: String?
    
    func getUserName() -> String {
        return self.userName
    }
    
    func setUserName(userName:String) -> Void {
        self.userName = userName
    }
    
    func getUserImage() -> UIImage? {
        return self.userImage
    }
    
    func setUserImage(userImage:UIImage) -> Void {
        self.userImage = userImage
    }
    
    func getEmail() -> String? {
        return self.email
    }
    
    func setEmail(userEmail:String) -> Void {
        self.email = userEmail
    }

}