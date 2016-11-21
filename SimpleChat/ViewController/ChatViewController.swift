//
//  ChatViewController.swift
//  SimpleChat
//
//  Created by hartlco on 15/11/2016.
//  Copyright © 2016 Martin Hartl. All rights reserved.
//

import UIKit
import Typist

class ChatViewController: UIViewController {
    
    static let OwnMessageCellIdentifier = "OwnMessageCellIdentifier"
    static let MessageCellidentifier = "MessageCellidentifier"
    
    let inputBarOffset: CGFloat = 16.0
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "OwnMessageTableViewCell", bundle: nil), forCellReuseIdentifier: ChatViewController.OwnMessageCellIdentifier)
            tableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: ChatViewController.MessageCellidentifier)
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 44.0
        }
    }
    
    @IBOutlet weak var messageTextField: UITextField! {
        didSet {
            messageTextField.delegate = self
        }
    }
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    fileprivate let username: String
    fileprivate let messageStore: MessageStore
    
    init(username: String) {
        self.username = username
        self.messageStore = MessageStore()
        super.init(nibName: String(describing: ChatViewController.self), bundle: nil)
        
        self.messageStore.messageInsertBlock = insertRow
        
        // Keyboard notifications with support for external keyboards
        Typist.shared.on(event: .willShow) { (options) in
            let y = (self.view.frame.size.height - options.endFrame.origin.y) + self.inputBarOffset
            self.moveInputBar(toY: y, duration: options.animationDuration, animationCurveRaw: options.animationCurve)
        }.on(event: .willHide) { (options) in
            let y = self.inputBarOffset
            self.moveInputBar(toY: y, duration: options.animationDuration, animationCurveRaw: options.animationCurve)
        }.start()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func insertRow() {
        let messages = messageStore.messages
        let latestIndexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [latestIndexPath], with: .automatic)
    }
    
    // MARK: - Keyboard animation
    
    internal func moveInputBar(toY y: CGFloat, duration: Double, animationCurveRaw: UIViewAnimationCurve) {
        bottomConstraint?.constant = y
        UIView.animate(withDuration: duration, delay: TimeInterval(0), options: UIViewAnimationOptions(rawValue: UInt(animationCurveRaw.rawValue)), animations: { self.view.layoutIfNeeded() },
                       completion: nil)
    }

}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageStore.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messageStore.messages[indexPath.row]
        guard let messageCell = tableView.dequeueReusableCell(withIdentifier: ChatViewController.MessageCellidentifier, for: indexPath) as? MessageTableViewCell else { return UITableViewCell() }
        
        messageCell.ownMessage = message.ownMessage
        messageCell.username = message.username
        messageCell.message = message.message
        return messageCell
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let messageText = textField.text else { return false }
        
        let message = Message(username: username, message: messageText, date: Date(), ownMessage: true)
        messageStore.send(message: message)
        
        textField.text = ""
        textField.resignFirstResponder()
        
        return true
    }
}
