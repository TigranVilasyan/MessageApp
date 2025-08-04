//
//  MessageCell.swift
//  MessageApp
//
//  Created by NokNokMac on 01.08.25.
//


import UIKit

/// A UICollectionViewCell subclass that displays a single chat message using MessageView.
/// Handles cell configuration and layout for message presentation in a chat interface.

/// Reusable cell representing a single chat message. Embeds MessageView for layout and styling.
final class MessageCollectionViewCell: UICollectionViewCell {
    
    /// Identifier
    static let reuseIdentifier = "MessageCollectionViewCell"
    
    /// Embedded view that renders the message's UI elements.
    private let messageView = MessageView()

    /// Initializes the cell with a frame.
    override init(frame: CGRect) {
        super.init(frame: frame)
//        setup()

    }
    
    /// Initializes the cell from a storyboard or nib.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    //    setup()
    }
    
    /// Sets up the cell by adding and constraining the messageView.
    func setup() {
        contentView.addSubview(messageView)
        messageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        messageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    /// Configures the cell with a MessageEntity.
    /// - Parameter message: The message object containing data to display.
    func configure(with message: MessageEntity) {
        messageView.configure(message: message)
        self.layoutIfNeeded()
    }
}

