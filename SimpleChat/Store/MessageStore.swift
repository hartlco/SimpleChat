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
    private(set) var messages = [Message]()
    
    private var publicDatabase: CKDatabase
    private var recordZone = CKRecordZone(zoneName: "MessageZone")
    
    init(username: String) {
        self.username = username
        self.publicDatabase = CKContainer.default().publicCloudDatabase
        messages.append(Message(username: username, message: "Test1", date: Date(), ownMessage: true))
    }
    
    func sendMessage(message: Message) {
        let messageRecord = CKRecord(message: message)
        
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [messageRecord], recordIDsToDelete: nil)
        modifyOperation.modifyRecordsCompletionBlock = { records, recordIDs, error in
            print("error: \(error)")
        }
        publicDatabase.add(modifyOperation)
    }
    
}

extension CKRecord {
    convenience init(message: Message) {
        self.init(recordType: "Message", zoneID: CKRecordZone(zoneName: "MessageZone").zoneID)
        self.setObject(message.date as CKRecordValue?, forKey: "Date")
        self.setObject(message.username as CKRecordValue?, forKey: "Username")
        self.setObject(message.message as CKRecordValue?, forKey: "Message")
    }
}
