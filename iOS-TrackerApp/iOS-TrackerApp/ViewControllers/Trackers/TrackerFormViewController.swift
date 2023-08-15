//
//  TrackerFormViewController.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 31.07.23.
//

import UIKit

protocol TrackerFormViewControllerDelegate: AnyObject {
    func didTapCancelButton()
    func didTapConfirmButton(categoryLabel: String, trackerToAdd: Tracker)
}

final class TrackerFormViewController: UIViewController {
    // MARK: - Layout elements
    private lazy var textField: UITextField = {
        let textField = TextField(placeholder: "Введите название трекера")
        textField.addTarget(self, action: #selector(didChangedLabelTextField), for: .editingChanged)
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeybordWithTap))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        return textField
    }()
    
    private let validationMessage: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .Red
        label.text = "Ограничение 38 символов"
        return label
    }()
    
    private let parametersTableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.isScrollEnabled = false
        table.register(ListCell.self, forCellReuseIdentifier: ListCell.identifier)
        return table
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = makeButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.Red, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.Red.cgColor
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = makeButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.WhiteDay, for: .normal)
        button.backgroundColor = .Gray
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    
    private let emojisCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.isScrollEnabled = false
        collection.allowsMultipleSelection = false
        collection.register(
            SelectionTitle.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SelectionTitle.identifier
        )
        collection.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        return collection
    }()
    
    private let colorsCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.isScrollEnabled = false
        collection.allowsMultipleSelection = false
        collection.register(
            SelectionTitle.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SelectionTitle.identifier
        )
        collection.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        return collection
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.keyboardDismissMode = .onDrag
        return scroll
    }()
    
    // MARK: - Properties
    
    weak var delegate: TrackerFormViewControllerDelegate?
    private let type: SetTrackersViewController.TrackerType
    private var data: Tracker.Data {
        didSet {
            checkFromValidation()
        }
    }
    
    private var category: String? = TrackerCategory.mockData[0].label {
        didSet {
            checkFromValidation()
        }
    }
    
    private var scheduleString: String? {
        guard let schedule = data.schedule else { return nil }
        if schedule.count == WeekDay.allCases.count { return "Каждый день" }
        let shortForms: [String] = schedule.map { $0.shortForm }
        return shortForms.joined(separator: ", ")
    }
    
    private var isConfirmButtonEnabled: Bool = false {
        willSet {
            if newValue {
                confirmButton.backgroundColor = .BlackDay
                confirmButton.isEnabled = true
            } else {
                confirmButton.backgroundColor = .Gray
                confirmButton.isEnabled = false
            }
        }
    }
    
    private var isValidationMessageVisible = false {
        didSet {
            checkFromValidation()
            if isValidationMessageVisible {
                validationMessageHeightConstraint?.constant = 22
                parametersTableViewTopConstraint?.constant = 32
            } else {
                validationMessageHeightConstraint?.constant = 0
                parametersTableViewTopConstraint?.constant = 16
            }
        }
    }
    
    private var validationMessageHeightConstraint: NSLayoutConstraint?
    private var parametersTableViewTopConstraint: NSLayoutConstraint?
    private let parameters = ["Категория", "Расписание"]
    private let emojis = emojisArray
    private let colors = UIColor.bunchOfSChoices
    private let geometry = UICollectionView.GeometricParams(cellCount: 6, leftInset: 28, rightInset: 28, topInset: 24, bottomInset: 24, height: 52, cellSpacing: 5)
    
    // MARK: - Lifecycle
    init(type: SetTrackersViewController.TrackerType, data: Tracker.Data = Tracker.Data()) {
        self.type = type
        self.data = data
        switch type {
        case .habit:
            self.data.schedule = []
        case .irregularEvent:
            self.data.schedule = nil
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var collectionViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureConstraints()
        checkFromValidation()
    }
    
    // MARK: - Actions
    
    @objc
    private func didChangedLabelTextField(_ sender: UITextField) {
        guard let text = sender.text else { return }
        data.label = text
        if text.count > 38 {
            isValidationMessageVisible = true
        } else {
            isValidationMessageVisible = false
        }
    }
    
    @objc
    private func didTapCancelButton() {
        delegate?.didTapCancelButton()
    }
    
    @objc
    private func didTapConfirmButton() {
        guard let category, let emoji = data.emoji, let color = data.color else { return }
        
        let newTracker = Tracker(
            label: data.label,
            emoji: emoji,
            color: color,
            schedule: data.schedule
        )
        delegate?.didTapConfirmButton(categoryLabel: category, trackerToAdd: newTracker)
    }
    
    @objc
    private func hideKeybordWithTap() {
        self.view.endEditing(true)
    }
    
    // MARK: - Methods
    private func checkFromValidation() {
        if data.label.count == 0 {
            isConfirmButtonEnabled = false
            return
        }
        if isValidationMessageVisible {
            isConfirmButtonEnabled = false
            return
        }
        if category == nil || data.emoji == nil || data.color == nil {
            isConfirmButtonEnabled = false
            return
        }
        if let schedule = data.schedule, schedule.isEmpty {
            isConfirmButtonEnabled = false
            return
        }
        isConfirmButtonEnabled = true
    }
    
    private func makeButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }
}

// MARK: - Layout methods
private extension TrackerFormViewController {
    func configureViews() {
        switch type {
        case .habit: title = "Новая привычка"
        case .irregularEvent: title = "Новое нерегулярное событие"
        }
        
        parametersTableView.dataSource = self
        parametersTableView.delegate = self
        
        emojisCollection.dataSource = self
        emojisCollection.delegate = self

        colorsCollection.dataSource = self
        colorsCollection.delegate = self
        
        textField.delegate = self
        
        view.backgroundColor = .WhiteDay
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [textField, validationMessage, parametersTableView, emojisCollection, colorsCollection, buttonsStack].forEach { contentView.addSubview($0) }
        
        buttonsStack.addArrangedSubview(cancelButton)
        buttonsStack.addArrangedSubview(confirmButton)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        validationMessage.translatesAutoresizingMaskIntoConstraints = false
        parametersTableView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        emojisCollection.translatesAutoresizingMaskIntoConstraints = false
        colorsCollection.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureConstraints() {
        validationMessageHeightConstraint = validationMessage.heightAnchor.constraint(equalToConstant: 0)
        parametersTableViewTopConstraint = parametersTableView.topAnchor.constraint(equalTo: validationMessage.bottomAnchor, constant: 16)
        validationMessageHeightConstraint?.isActive = true
        parametersTableViewTopConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: ListOfItems.height),
            validationMessage.centerXAnchor.constraint(equalTo: textField.centerXAnchor),
            validationMessage.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            parametersTableView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            parametersTableView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            parametersTableView.heightAnchor.constraint(equalToConstant: data.schedule == nil ? ListOfItems.height : 2 *  ListOfItems.height),
            emojisCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojisCollection.topAnchor.constraint(equalTo: parametersTableView.bottomAnchor, constant: 32),
            emojisCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojisCollection.heightAnchor.constraint(equalToConstant: CGFloat(emojis.count) / geometry.cellCount * geometry.height + 18 + geometry.topInset + geometry.bottomInset),
            colorsCollection.leadingAnchor.constraint(equalTo: emojisCollection.leadingAnchor),
            colorsCollection.topAnchor.constraint(equalTo: emojisCollection.bottomAnchor, constant: 16),
            colorsCollection.trailingAnchor.constraint(equalTo: emojisCollection.trailingAnchor),
            colorsCollection.heightAnchor.constraint(
                equalToConstant: CGFloat(colors.count) / geometry.cellCount * geometry.height + 18 + geometry.topInset + geometry.bottomInset
            ),
            buttonsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonsStack.topAnchor.constraint(equalTo: colorsCollection.bottomAnchor, constant: 16),
            buttonsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            buttonsStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - UITableViewDataSource
extension TrackerFormViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.schedule == nil {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let listCell = tableView.dequeueReusableCell(withIdentifier: ListCell.identifier) as? ListCell
        else { return UITableViewCell() }
        
        var position: ListOfItems.Position
        var value: String? = nil
        
        if data.schedule == nil {
            position = .alone
            value = category
        } else {
            position = indexPath.row == 0 ? .first : .last
            value = indexPath.row == 0 ? category : scheduleString
        }
        
        listCell.configure(label: parameters[indexPath.row], value: value, position: position)
        return listCell
    }
}

// MARK: - UITableViewDelegate
extension TrackerFormViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            guard let schedule = data.schedule else { return }
            let scheduleViewController = ScheduleViewController(selectedWeekdays: schedule)
            scheduleViewController.delegate = self
            let navigationController = UINavigationController(rootViewController: scheduleViewController)
            present(navigationController, animated: true)
        default:
            return
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        ListOfItems.height
    }
}

extension TrackerFormViewController: ScheduleViewControllerDelegate {
    func didConfirm(_ schedule: [WeekDay]) {
        data.schedule = schedule
        parametersTableView.reloadData()
        dismiss(animated: true)
    }
}
// MARK: - UICollectionViewDataSource
extension TrackerFormViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case emojisCollection: return emojis.count
        case colorsCollection: return colors.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case emojisCollection:
            guard let emojiCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else { return UICollectionViewCell() }
            let emoji = emojis[indexPath.row]
            emojiCell.configure(with: emoji)
            return emojiCell
        case colorsCollection:
            guard let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else { return UICollectionViewCell() }
            let color = colors[indexPath.row]
            colorCell.configure(with: color)
            return colorCell
        default:
            return UICollectionViewCell()
        }
    }
}

extension TrackerFormViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectionCellProtocol else { return }
        switch collectionView {
        case emojisCollection: data.emoji = emojis[indexPath.row]
        case colorsCollection: data.color = colors[indexPath.row]
        default: break
        }
        cell.select()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectionCellProtocol else { return }
        cell.deselect()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerFormViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let availableSpace = collectionView.frame.width - geometry.paddingWidth
        let cellWidth = availableSpace / geometry.cellCount
        return CGSize(width: cellWidth, height: geometry.height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets
    {
        UIEdgeInsets(
            top: geometry.topInset,
            left: geometry.leftInset,
            bottom: geometry.bottomInset,
            right: geometry.rightInset
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        geometry.cellSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView
    {
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: SelectionTitle.identifier,
                for: indexPath
            ) as? SelectionTitle
        else
        { return UICollectionReusableView() }
        
        var label: String
        switch collectionView {
        case emojisCollection: label = "Emoji"
        case colorsCollection: label = "Цвет"
        default: label = ""
        }
        
        view.configure(with: label)
        hideKeybordWithTap()
        return view
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
            at: indexPath
        )
        
        return headerView.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: UIView.layoutFittingExpandedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}

extension TrackerFormViewController {
    final class SelectionTitle: UICollectionReusableView {
        // MARK: - Layout elements
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 19)
            return label
        }()
        
        // MARK: - Properties
        static let identifier = "SelectionTitle"
        
        // MARK: - Lifecycle
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(titleLabel)
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
                titleLabel.topAnchor.constraint(equalTo: topAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Methods
        
        func configure(with label: String) {
            titleLabel.text = label
        }
    }
}

extension TrackerFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
