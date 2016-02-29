import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {

    // private properties
    private var userTypingQuery: FQuery!
    private var messages: [JSQMessage] = []
    private var outgoingBubbleImageView: JSQMessagesBubbleImage!
    private var incomingBubbleImageView: JSQMessagesBubbleImage!
    private var localTyping = false
    
    var userIsTypingRef: Firebase!
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ChatChat"
        setupBubbles()
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeMessages()
        observeTyping()
    }
  
    // Collection Data Source delegate
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
            as! JSQMessagesCollectionViewCell
        if messages[indexPath.item].senderId == senderId {
            cell.textView?.textColor = UIColor.whiteColor()
        } else {
            cell.textView?.textColor = UIColor.blackColor()
        }
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let messageSenderId = messages[indexPath.item].senderId
        if messageSenderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let itemRef = FirebaseHelper.shared.messagesRef.childByAutoId()
        let messageItem = ["text": text, "senderId": senderId]
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }

    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = !textView.text.isEmpty
    }
    // Helpers
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    private func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message)
    }
    private func observeMessages() {
        let messagesQuery = FirebaseHelper.shared.messagesRef.queryLimitedToLast(25)
        messagesQuery.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) -> Void in
            let id = snapshot.value["senderId"] as? String ?? ""
            let text = snapshot.value["text"] as? String ?? ""
            self.addMessage(id, text: text)
            self.finishSendingMessage()
        }
    }
    private func observeTyping() {
        let typingRef = FirebaseHelper.shared.rootRef.childByAppendingPath("typingIndicator")
        userIsTypingRef = typingRef.childByAppendingPath(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        userTypingQuery = typingRef.queryOrderedByValue().queryEqualToValue(true)
        userTypingQuery.observeEventType(FEventType.Value) { (snapshot: FDataSnapshot!) -> Void in
            if snapshot.childrenCount == 1 && self.isTyping {
                return // You're the only typing, don't show the indicator
            }
            
            // Are there others typing
            self.showTypingIndicator = snapshot.childrenCount > 0
            self.scrollToBottomAnimated(true)
        }
    }
}