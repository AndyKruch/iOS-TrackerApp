//
//  StatisticsViewController.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 31.07.23.
//

import UIKit

final class StatisticViewController: UIViewController {
    
    // MARK: - Layout elements
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "EmptyStat")
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = "Анализировать пока нечего"
        label.textColor = .BlackDay
        return label
    }()
    
    private let emptyStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
    }
    
}

// MARK: - EXTENSIONS
// MARK: - Layout methods
private extension StatisticViewController {
    func configureViews() {
        view.backgroundColor = .WhiteDay
        [nameLabel, emptyStack].forEach { view.addSubview($0) }
        emptyStack.addArrangedSubview(emptyImageView)
        emptyStack.addArrangedSubview(emptyLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStack.translatesAutoresizingMaskIntoConstraints = false

    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

