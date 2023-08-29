//
//  EmojiCell.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 14.08.23.
//

import Foundation

import UIKit

protocol SelectionCellProtocol {
    func select()
    func deselect()
}

final class EmojiCell: UICollectionViewCell {
    
    static let identifier = "EmojiCell"
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
        
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func configure(with label: String) {
        emojiLabel.text = label
    }
}

private extension EmojiCell {
    func configureViews() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.addSubview(emojiLabel)
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}

extension EmojiCell: SelectionCellProtocol {
    func select() {
        contentView.backgroundColor = .LightGray
    }
    
    func deselect() {
        contentView.backgroundColor = .clear
    }
}
