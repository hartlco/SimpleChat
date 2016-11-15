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
    private(set) var messages = [Message]()
    
    private var publicDatabase: CKDatabase
    private var recordZone = CKRecordZone(zoneName: "MessageZone")
    
    init() {
        self.publicDatabase = CKContainer.default().publicCloudDatabase
        self.subscribeToItemUpdates()
        
        NotificationCenter.default.addObserver(forName: AppDelegate.CloudKitNotificationName, object: nil, queue: nil) { notification in
            guard let queryNotification = notification.object as? CKQueryNotification else { return }
            
        }
    }
    
    func send(message: Message) {
        let messageRecord = CKRecord(message: message)
        
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [messageRecord], recordIDsToDelete: nil)
        modifyOperation.modifyRecordsCompletionBlock = { records, recordIDs, error in
            print("error: \(error)")
        }
        publicDatabase.add(modifyOperation)
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
