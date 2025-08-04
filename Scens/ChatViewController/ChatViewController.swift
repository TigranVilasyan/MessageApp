//
//  ChatViewController.swift
//  MessageApp
//
//  Created by NokNokMac on 01.08.25.
//



import UIKit
import Combine

class ChatViewController: UIViewController {

    private enum ChatSection {
        case main
    }
    var viewModel: ChatViewModelType?
    
    private let inputTextView = InputTextView()
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<ChatSection, MessageEntity>!
    private var cancellables = Set<AnyCancellable>()
    private var isInitialLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupInputView()
        setupCollectionView()
        configureDataSource()
        bindViewModel()
        viewModel?.outputs.loadMessages()
    }
    
    
    func inejct(viewModel: ChatViewModelType) {
        self.viewModel = viewModel
    }

    private func setupInputView() {
        inputTextView.attachToView(view)

        inputTextView.onSend = { [weak self] message in
            self?.viewModel?.outputs.addMessage(text: message, isSender: true , author: "ME")
            self?.isInitialLoad = true
        }

        inputTextView.adjustmentHandler = { [weak self] offset in
            self?.inputTextView.updateBottomConstraint(constant: offset)
        }
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createSectionLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MessageCollectionViewCell.self, forCellWithReuseIdentifier: MessageCollectionViewCell.reuseIdentifier)
        collectionView.keyboardDismissMode = .interactive
        collectionView.backgroundColor = .systemBackground
        collectionView.prefetchDataSource = self
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: inputTextView.topAnchor)
        ])

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideInput))
        tapGesture.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(tapGesture)
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<ChatSection, MessageEntity>(
            collectionView: collectionView
        ) { collectionView, indexPath, message in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MessageCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? MessageCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.setup()
            cell.configure(with: message)
            return cell
        }

        collectionView.dataSource = dataSource
    }

    private func bindViewModel() {
        viewModel?.outputs.messagesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                guard let self = self else { return }

                var snapshot = NSDiffableDataSourceSnapshot<ChatSection, MessageEntity>()
                snapshot.appendSections([.main])
                let uniqueMessages = messages.reduce(into: [String: MessageEntity]()) { dict, message in
                    dict[message.id] = message
                }.values.sorted(by: { $0.timestamp < $1.timestamp }) // or your preferred order

                snapshot.appendItems(Array(uniqueMessages))
                self.dataSource.apply(snapshot, animatingDifferences: !self.isInitialLoad)

                if self.isInitialLoad && !messages.isEmpty {
                    self.scrollToBottom()
                    self.isInitialLoad = false
                }
            }
            .store(in: &cancellables)
    }

    private func scrollToBottom() {
        let count = self.viewModel?.inputs.numberOfMessages() ?? 0
        guard count > 0 else { return }
        let indexPath = IndexPath(item: count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }

    @objc private func handleTapOutsideInput() {
        view.endEditing(true)
    }

    private func createSectionLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

            return section
        }
    }
}

// MARK: - Prefetching for Pagination

extension ChatViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard indexPaths.contains(where: { $0.item < 20 }) else { return }
        self.viewModel?.outputs.loadNextPage()
    }
}
