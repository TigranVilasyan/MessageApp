//
//  MessageView.swift
//  MessageApp
//


import UIKit

/// A view responsible for displaying a chat message, supporting both sender and author message layouts.
final class MessageView: UIView {
    
    // MARK: - UI Outlets for Author Message
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var authorMessageView: UIView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var authorMessageLabel: UILabel!
    @IBOutlet weak var authorMessageImage: UIImageView!
    @IBOutlet weak var authorMessageSendTimeLabel: UILabel!
    
    // MARK: - UI Outlets for Sender Message
    
    @IBOutlet weak var senderMesageView: UIView!
    @IBOutlet weak var senderMessageLabel: UILabel!
    @IBOutlet weak var senderMessageSenTimeLabel: UILabel!
    
    // MARK: - Public Properties for UI customization
    
    /// Background color of the message bubble
    var backgroundColorCustom: UIColor = .lightGray {
        didSet {
            contentView.backgroundColor = backgroundColorCustom
        }
    }

    /// Corner radius for the message bubble
    var cornerRadius: CGFloat = 16 {
        didSet {
            contentView.layer.cornerRadius = cornerRadius
        }
    }

    /// Font size for message text labels
    var textSize: CGFloat = 16 {
        didSet {
            authorMessageLabel.font = UIFont.systemFont(ofSize: textSize)
            senderMessageLabel.font = UIFont.systemFont(ofSize: textSize)
        }
    }
    
    // MARK: - Private Properties
    
    private let nibName = "MessageView"
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    /// Loads the nib file and sets up the content view
    private func commonInit() {
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    /// Extracts "HH:mm" from a timestamp string formatted as "YYYY-MM-DDTHH:mm:ss.ssssss"
    /// - Parameter timestamp: The timestamp string to parse
    /// - Returns: A string representing hour and minute, or nil if invalid
    private func extractHourMinute(from timestamp: String) -> String? {
        // Expected format: "2025-06-30T21:37:38.673753"
        guard timestamp.count >= 16 else { return nil }
        
        let hourStart = timestamp.index(timestamp.startIndex, offsetBy: 11)
        let minuteEnd = timestamp.index(hourStart, offsetBy: 5)
        
        return String(timestamp[hourStart..<minuteEnd])
    }
    
    // MARK: - Configuration
    
    /// Configures the view to display a message, differentiating between sender and author messages
    /// - Parameter message: The message entity to display
    func configure(message: MessageEntity) {
        senderMesageView.isHidden = !message.isSender
        authorMessageView.isHidden = message.isSender
        
        if message.isSender {
            senderMessageLabel.text = message.text
            senderMessageSenTimeLabel.text = extractHourMinute(from: message.timestamp)
        } else {
            authorNameLabel.text = message.author
            authorMessageLabel.text = message.text
            authorMessageSendTimeLabel.text = extractHourMinute(from: message.timestamp)
        }
    }
}

