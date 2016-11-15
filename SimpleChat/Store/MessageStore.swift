//
//  MessageStore.swift
//  SimpleChat
//
//  Created by mhaddl on 15/11/2016.
//  Copyright © 2016 Martin Hartl. All rights reserved.
//

import Foundation
import CloudKit

class MessageStore {
    private let username: String
    private var messages = [Message]()
    
    init(username: String) {
        self.username = username
        messages.append(Message(username: username, message: "Test1", date: Date()))
    }
    
    func loadMessages() -> [Message] {
        return messages
    }
    
}
