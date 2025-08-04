//
//  MessageCell.swift
//  MessageApp
//
//  Created by NokNokMac on 01.08.25.
//


import UIKit

final class MessageCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "MessageCollectionViewCell"

    private let messageView = MessageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
//        setup()

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    //    setup()
    }
    
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

    func configure(with message: MessageEntity) {
        messageView.configure(message: message)
        self.layoutIfNeeded()
    }
}
