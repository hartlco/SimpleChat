//
//  MessageStore.swift
//  SimpleChat
//
//  Created by hartlco on 15/11/2016.
//  Copyright © 2016 Martin Hartl. All rights reserved.
//

import Foundation
import CloudKit

class MessageStore {
    
    var messageInsertBlock: (() -> ())? = nil
    
    private(set) var messages = [Message]()
    private var publicDatabase: CKDatabase
    
    init() {
        self.publicDatabase = CKContainer.default().publicCloudDatabase
        self.subscribeToItemUpdates()
        
        NotificationCenter.default.addObserver(forName: AppDelegate.CloudKitNotificationName, object: nil, queue: nil) { notification in
            guard let queryNotification = notification.object as? CKQueryNotification else { return }
            self.fetchAndAppendMessage(fromQueryNotification: queryNotification)
        }
    }
    
    // MARK: - Send and fetch message
    
    func send(message: Message) {
        let messageRecord = CKRecord(message: message)
        
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [messageRecord], recordIDsToDelete: nil)
        modifyOperation.modifyRecordsCompletionBlock = { records, recordIDs, error in
            // Error & completion handling maybe
        }
        publicDatabase.add(modifyOperation)
        messages.append(message)
        messageInsertBlock?()
    }
    
    private func fetchAndAppendMessage(fromQueryNotification notification: CKQueryNotification) {
        guard let recordID = notification.recordID else { return }
        let fetchOperation = CKFetchRecordsOperation(recordIDs: [recordID])
        fetchOperation.perRecordCompletionBlock = { record, recordID, error in
            guard let record = record,
            let message = Message(record: record) else { return }
            self.messages.append(message)
            DispatchQueue.main.async {
                self.messageInsertBlock?()
            }
        }
        publicDatabase.add(fetchOperation)
    }
    
    // MARK: - CloudKitNotification
    
    private func subscribeToItemUpdates() {
        self.saveSubscriptionWithIdent("create", options: .firesOnRecordCreation)
        self.saveSubscriptionWithIdent("update", options: .firesOnRecordUpdate)
        self.saveSubscriptionWithIdent("delete", options: .firesOnRecordDeletion)
    }
    
    private func notificationInfo() -> CKNotificationInfo {
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldBadge = false
        notificationInfo.shouldSendContentAvailable = true
        return notificationInfo
    }
    
    private func saveSubscriptionWithIdent(_ ident: String, options: CKQuerySubscriptionOptions) {
        let subscription = CKQuerySubscription(recordType: "Message", predicate: NSPredicate(value: true), subscriptionID: ident, options: options)
        subscription.notificationInfo = self.notificationInfo();
        publicDatabase.save(subscription) { (subscription, error) -> Void in
            // Error handling 
        }
    }
    
}

extension CKRecord {
    convenience init(message: Message) {
        self.init(recordType: String(describing: Message.self), zoneID: CKRecordZone.default().zoneID)
        self[Message.DateKey] = message.date as CKRecordValue
        self[Message.UsernameKey] = message.username as CKRecordValue
        self[Message.MessageKey] = message.message as CKRecordValue
    }
}

extension Message {
    init?(record: CKRecord) {
        guard let username = record[Message.UsernameKey] as? String,
        let message = record[Message.MessageKey] as? String,
        let date = record[Message.DateKey] as? Date else { return nil }
        
        self.username = username
        self.message = message
        self.date = date
        
        // It would be possible to compare CloudKit userIDs here to determine if it's an own
        // message sent from a different device
        self.ownMessage = false
    }
}
