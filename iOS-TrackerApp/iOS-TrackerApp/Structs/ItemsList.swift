//
//  ItemList.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 31.07.23.
//

import UIKit

final class ListOfItems: UIView {
    // MARK: - Layout elements

    private let border: UIView = {
        let view = UIView()
        view.backgroundColor = .Gray
        view.isHidden = true
        return view
    }()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods
    func configure(with position: Position = .middle) {
        layer.masksToBounds = true
        layer.cornerRadius = 10

        switch position {
        case .first:
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            border.isHidden = false
        case .middle:
            layer.cornerRadius = 0
            border.isHidden = false
        case .last:
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .alone:
            break
        }
    }
}
// MARK: - EXTENSIONS
//MARK: - Layout methods
extension ListOfItems {
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        backgroundColor = .BackgroundDay

        addSubview(border)
        border.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            border.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            border.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            border.bottomAnchor.constraint(equalTo: bottomAnchor),
            border.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

extension ListOfItems {
    enum Position {
        case first, middle, last, alone
    }
    static let height: CGFloat = 75
}
