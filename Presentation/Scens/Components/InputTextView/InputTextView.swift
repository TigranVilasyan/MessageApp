//
//  InputTextView.swift
//  MessageApp
//
//  Created by NokNokMac on 01.08.25.
//

import UIKit

/// A reusable input bar component for composing chat messages.
/// Provides a text input area with a send button and handles keyboard adjustments.

/// A custom input view designed for chat interfaces.
/// Contains a multiline text view and a send button, dynamically resizing and moving with the keyboard.
final class InputTextView: UIView {

    // MARK: - UI Components

    /// The text view where users enter their message text.
    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        tv.layer.cornerRadius = 16
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        return tv
    }()

    /// The button that triggers sending the typed message.
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()

    // MARK: - Public

    /// Called when user taps Send with non-empty text
    var onSend: ((String) -> Void)?

    /// Called with keyboard offset (negative value = move up)
    var adjustmentHandler: ((CGFloat) -> Void)?

    // MARK: - Private

    /// The bottom layout constraint to adjust the input bar position relative to keyboard or safe area.
    private var bottomConstraint: NSLayoutConstraint?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupActions()
        setupKeyboardObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup Methods

    /// Configures view hierarchy and initial appearance.
    private func setupViews() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
        clipsToBounds = true

        addSubview(textView)
        addSubview(sendButton)

        textView.delegate = self
    }

    /// Sets up Auto Layout constraints for subviews.
    private func setupConstraints() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }

    /// Adds target-action for user interactions.
    private func setupActions() {
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    }

    /// Registers for keyboard show/hide notifications.
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - Public Method to Attach to Parent View

    /// Adds self to the parent view and sets up constraints (including bottom constraint).
    func attachToView(_ parentView: UIView) {
        parentView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
        ])

        bottomConstraint = bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor)
        bottomConstraint?.isActive = true
    }

    /// Updates bottom constraint constant (for keyboard offset).
    func updateBottomConstraint(constant: CGFloat) {
        bottomConstraint?.constant = constant
        superview?.layoutIfNeeded()
    }

    // MARK: - Actions

    /// Handles tapping the send button: sends non-empty text and clears input.
    @objc private func handleSend() {
        guard let text = textView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        onSend?(text)
        textView.text = ""
        textViewDidChange(textView)
    }

    // MARK: - Keyboard Notifications

    /// Called when keyboard will show: adjusts bottom constraint to move input bar above keyboard.
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let window = window
        else { return }

        // Adjust for safe area bottom inset to avoid double spacing
        let keyboardHeight = keyboardFrame.height - window.safeAreaInsets.bottom

        adjustmentHandler?(-keyboardHeight)

        UIView.animate(withDuration: duration) {
            self.superview?.layoutIfNeeded()
        }
    }

    /// Called when keyboard will hide: resets bottom constraint.
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }

        adjustmentHandler?(0)

        UIView.animate(withDuration: duration) {
            self.superview?.layoutIfNeeded()
        }
    }
}

// MARK: - UITextViewDelegate

/// Implements UITextViewDelegate methods to auto-resize the input bar as the text changes.
extension InputTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        UIView.setAnimationsEnabled(false)
        invalidateIntrinsicContentSize()
        superview?.layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
    }

    override var intrinsicContentSize: CGSize {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: UIView.noIntrinsicMetric, height: size.height + 16)
    }
}
