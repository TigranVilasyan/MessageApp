//
//  MessageView.swift
//  MessageApp
//
//  Created by NokNokMac on 01.08.25.
//


import UIKit

final class MessageView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var authorMessageView: UIView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var authorMessageLabel: UILabel!
    @IBOutlet weak var authorMessageImage: UIImageView!
    @IBOutlet weak var authorMessageSendTimeLabel: UILabel!
    
    
    @IBOutlet weak var senderMesageView: UIView!
    @IBOutlet weak var senderMessageLabel: UILabel!
    @IBOutlet weak var senderMessageSenTimeLabel: UILabel!
    
    // MARK: - Public Properties
    var backgroundColorCustom: UIColor = .lightGray {
        didSet {
            contentView.backgroundColor = backgroundColorCustom
        }
    }

    var cornerRadius: CGFloat = 16 {
        didSet {
            contentView.layer.cornerRadius = cornerRadius
        }
    }

    var textSize: CGFloat = 16 {
        didSet {
            authorMessageLabel.font = UIFont.systemFont(ofSize: textSize)
            senderMessageLabel.font = UIFont.systemFont(ofSize: textSize)
        }
    }
    
    // MARK: - Private Properties
    private let nibName = "MessageView"
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func extractHourMinute(from timestamp: String) -> String? {
        // Expected format: "2025-06-30T21:37:38.673753"
        guard timestamp.count >= 16 else { return nil }
        
        let hourStart = timestamp.index(timestamp.startIndex, offsetBy: 11)
        let minuteEnd = timestamp.index(hourStart, offsetBy: 5)
        
        return String(timestamp[hourStart..<minuteEnd])
    }
    
    // MARK: - Configuration
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
