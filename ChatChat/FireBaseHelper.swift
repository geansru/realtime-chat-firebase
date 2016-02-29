//
//  FireBaseHelper.swift
//  ChatChat
//
//  Created by Dmitry Roytman on 29.02.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation
import Firebase

class FirebaseHelper {
    static let shared = FirebaseHelper()
    // Setting Up the Firebase Reference
    let rootRef: Firebase
    let messagesRef: Firebase
    
    init() {
        rootRef = Firebase(url: "https://glowing-heat-1954.firebaseio.com")
        messagesRef = rootRef.childByAppendingPath("messages")
    }
}