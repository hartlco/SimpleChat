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
    
    var messageInsertBlock: (() -> ())? = nil
    
    private(set) var messages = [Message]()
    private var publicDatabase: CKDatabase
    private var recordZone = CKRecordZone(zoneName: "MessageZone")
    
    init() {
        self.publicDatabase = CKContainer.default().publicCloudDatabase
        self.subscribeToItemUpdates()
        
        NotificationCenter.default.addObserver(forName: AppDelegate.CloudKitNotificationName, object: nil, queue: nil) { notification in
            guard let queryNotification = notification.object as? CKQueryNotification else { return }
            self.appendMessage(fromQueryNotification: queryNotification)
        }
    }
    
    func send(message: Message) {
        let messageRecord = CKRecord(message: message)
        
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [messageRecord], recordIDsToDelete: nil)
        modifyOperation.modifyRecordsCompletionBlock = { records, recordIDs, error in
            
        }
        publicDatabase.add(modifyOperation)
        messages.append(message)
        messageInsertBlock?()
    }
    
    private func appendMessage(fromQueryNotification notification: CKQueryNotification) {
        guard let recordID = notification.recordID else { return }
        let fetchOperation = CKFetchRecordsOperation(recordIDs: [recordID])
        fetchOperation.perRecordCompletionBlock = { record, recordID, error in
            guard let record = record,
            let message = Message(record: record) else { return }
            
            print(message)
        }
        publicDatabase.add(fetchOperation)
    }
    
    // MARK: - CloudKitNotification
    
    fileprivate func notificationInfo() -> CKNotificationInfo {
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldBadge = false
        notificationInfo.shouldSendContentAvailable = true
        return notificationInfo
    }
    
    fileprivate func subscribeToItemUpdates() {
        self.saveSubscriptionWithIdent("create", options: .firesOnRecordCreation)
        self.saveSubscriptionWithIdent("update", options: .firesOnRecordUpdate)
        self.saveSubscriptionWithIdent("delete", options: .firesOnRecordDeletion)
    }
    
    fileprivate func saveSubscriptionWithIdent(_ ident: String, options: CKQuerySubscriptionOptions) {
        let subscription = CKQuerySubscription(recordType: "Message", predicate: NSPredicate(value: true), subscriptionID: ident, options: options)
        subscription.notificationInfo = self.notificationInfo();
        publicDatabase.save(subscription) { (subscription, error) -> Void in
            
        }
    }
    
}

extension CKRecord {
    convenience init(message: Message) {
        self.init(recordType: "Message", zoneID: CKRecordZone.default().zoneID)
        self.setObject(message.date as CKRecordValue?, forKey: "Date")
        self.setObject(message.username as CKRecordValue?, forKey: "Username")
        self.setObject(message.message as CKRecordValue?, forKey: "Message")
    }
}

extension Message {
    init?(record: CKRecord) {
        guard let username = record["Username"] as? String,
        let message = record["Message"] as? String,
        let date = record["Date"] as? Date else { return nil }
        
        self.username = username
        self.message = message
        self.date = date
        self.ownMessage = false
    }
}
