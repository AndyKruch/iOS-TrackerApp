//
//  ColorCell.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 14.08.23.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    // MARK: - Layout elements
    private let colorView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    // MARK: - Properties
    static let identifier = "ColorCell"
    private var color: UIColor?
    
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
    func configure(with color: UIColor) {
        colorView.backgroundColor = color
        self.color = color
    }
}

// MARK: - Layout methods
private extension ColorCell {
    func configureViews() {
        contentView.addSubview(colorView)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        colorView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalTo: colorView.widthAnchor),
        ])
    }
}

extension ColorCell: SelectionCellProtocol {
    func select() {
        guard let color else { return }
        contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        contentView.layer.borderWidth = 3
    }
    
    func deselect() {
        contentView.layer.borderWidth = 0
    }
}
