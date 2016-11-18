//
//  Message.swift
//  SimpleChat
//
//  Created by mhaddl on 15/11/2016.
//  Copyright © 2016 Martin Hartl. All rights reserved.
//

import Foundation

struct Message {
    
    static let UsernameKey = "Username"
    static let MessageKey = "Message"
    static let DateKey = "Date"
    
    let username: String
    let message: String
    let date: Date
    let ownMessage: Bool
}
