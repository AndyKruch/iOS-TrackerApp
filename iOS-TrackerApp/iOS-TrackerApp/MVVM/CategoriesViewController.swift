//
//  CategoriesViewController.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 10.09.23.
//

import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func didConfirm(_ category: TrackerCategory)
}

final class CategoriesViewController: UIViewController {
    // MARK: - Layout elements
    private let categoriesView: UITableView = {
        let table = UITableView()
        table.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        table.separatorStyle = .none
        table.allowsMultipleSelection = false
        table.backgroundColor = .clear
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        return table
    }()
        
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = .BlackDay
        button.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    weak var delegate: CategoriesViewControllerDelegate?
    private let viewModel: CategoriesViewModel
    
    // MARK: - Lifecycle
    init(selectedCategory: TrackerCategory?) {
        viewModel = CategoriesViewModel(selectedCategory: selectedCategory)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        viewModel.delegate = self
        viewModel.loadCategories()
    }
    
    // MARK: - Actions
    @objc
    private func didTapAddButton() {
        viewModel.didTapButton()
    }
}

// MARK: - Layout methods
private extension CategoriesViewController {
    func configureViews() {
        title = "Категория"
        view.backgroundColor = .WhiteDay
        [categoriesView, addButton].forEach { view.addSubview($0) }
        
        categoriesView.dataSource = self
        categoriesView.delegate = self
        
        categoriesView.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            categoriesView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoriesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoriesView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoriesView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            addButton.leadingAnchor.constraint(equalTo: categoriesView.leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: categoriesView.trailingAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}

// MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let categoryCell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier) as? CategoryCell else { return UITableViewCell() }
        let category = viewModel.categories[indexPath.row]
        let isSelected = viewModel.selectedCategory == category
        var position: ListOfItems.Position
        switch indexPath.row {
        case 0:
            position = .first
        case viewModel.categories.count - 1:
            position = .last
        default:
            position = .middle
        }
        categoryCell.configure(with: category.label,
                               isSelected: isSelected,
                               position: position)
        
        return categoryCell
    }
}

// MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        ListOfItems.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath)
    }
}

// MARK: - CategoriesViewModelDelegate
extension CategoriesViewController: CategoriesViewModelDelegate {
    func didUpdateCategories() {
        if viewModel.categories.isEmpty {
            addButton.setTitle("Добавить категорию", for: .normal)
        } else {
            addButton.setTitle("Готово", for: .normal)
        }
    }
    
    func didSelectCategory() {
        categoriesView.reloadData()
    }
    
    func didConfirm(_ category: TrackerCategory) {
        delegate?.didConfirm(category)
    }
}
