//
//  TrackersViewController.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 31.07.23.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private lazy var addButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(
                systemName: "plus",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 18,
                    weight: .bold
                )
            )!,
            target: self,
            action: #selector(didTapPlusButton))
        button.tintColor = .BlackDay
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.backgroundColor = .WhiteDay
        datePicker.tintColor = .blue
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar = Calendar(identifier: .iso8601)
        datePicker.addTarget(self, action: #selector(didChangedDatePicker), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.placeholder = "Поиск"
        view.searchBarStyle = .minimal
        view.delegate = self
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.backgroundColor = .WhiteDay
        view.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: TrackerCell.identifier
        )
        view.register(
            TrackerCategoryNames.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
             return view
         }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Фильтры", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        button.layer.cornerRadius = 16
        button.backgroundColor = .Blue
        return button
    }()
    
    //MARK: - Properties
    
    private let mainSpacePlaceholderStack = UIStackView()
    private let searchSpacePlaceholderStack = UIStackView()
    private let trackerLabel = UILabel()
    private var currentDate = Date()
    private let params = UICollectionView.GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, topInset: 8, bottomInset: 16, height: 148, cellSpacing: 10)
    private var categories = [TrackerCategory]()
    private var completedTrackers: Set<TrackerRecord> = []
    private var searchText = "" {
        didSet {
            try? trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
        }
    }
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        trackerLabel.configureLabel(
            text: "Трекеры",
            addToView: view,
            ofSize: 34,
            weight: .bold
        )
        mainSpacePlaceholderStack.configurePlaceholderStack(imageName: "StarIcon", text: "Что будем отслеживать?")
        searchSpacePlaceholderStack.configurePlaceholderStack(imageName: "EmptyTracker", text: "Ничего не найдено")
        checkMainPlaceholderVisability()
        checkPlaceholderVisabilityAfterSearch()
        
        trackerRecordStore.delegate = self
        trackerStore.delegate = self
        
        try? trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
        try? trackerRecordStore.loadCompletedTrackers(by: currentDate)
        
        checkNumberOfTrackers()
    }
    
    // MARK: - Actions
    @objc
    private func didTapPlusButton() {
        
        let setTrackersViewController = SetTrackersViewController()
        setTrackersViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: setTrackersViewController)
        present(navigationController, animated: true)
         
    }
    
    @objc
    private func didChangedDatePicker(_ sender: UIDatePicker) {
        currentDate = Date.from(date: sender.date)!
        do {
            try trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
            try trackerRecordStore.loadCompletedTrackers(by: currentDate)
        } catch {}
        collectionView.reloadData()
    }
    
    // MARK: - Methods
    private func checkMainPlaceholderVisability() {
        let isHidden = trackerStore.numberOfTrackers == 0  && searchSpacePlaceholderStack.isHidden
        mainSpacePlaceholderStack.isHidden = !isHidden
    }
    
    private func checkPlaceholderVisabilityAfterSearch() {
        let isHidden = trackerStore.numberOfTrackers == 0  && searchBar.text != ""
        searchSpacePlaceholderStack.isHidden = !isHidden
    }
    
    private func checkNumberOfTrackers() {
        filterButton.isHidden = trackerStore.numberOfTrackers == 0
    }
}
// MARK: - EXTENSIONS
 //MARK: - Layout methods
private extension TrackersViewController {
    func configureViews() {
        view.backgroundColor = .WhiteDay
        [trackerLabel, addButton, datePicker, searchBar, collectionView, mainSpacePlaceholderStack, searchSpacePlaceholderStack, filterButton].forEach { view.addSubview($0) }
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        mainSpacePlaceholderStack.translatesAutoresizingMaskIntoConstraints = false
        searchSpacePlaceholderStack.translatesAutoresizingMaskIntoConstraints = false
        filterButton.translatesAutoresizingMaskIntoConstraints = false

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func configureConstraints() {
        NSLayoutConstraint.activate([
            trackerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.1083),
            trackerLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 18),
            datePicker.widthAnchor.constraint(equalToConstant: 120),
            datePicker.centerYAnchor.constraint(equalTo: trackerLabel.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            addButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 18),
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.07019),
            searchBar.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7),
            searchBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 34),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mainSpacePlaceholderStack.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.495),
            mainSpacePlaceholderStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchSpacePlaceholderStack.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.495),
            searchSpacePlaceholderStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
//MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource
 extension TrackersViewController: UICollectionViewDataSource {
     func numberOfSections(in collectionView: UICollectionView) -> Int {
         checkMainPlaceholderVisability()
         return trackerStore.numberOfSections
     }

     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return trackerStore.numberOfRowsInSection(section)
     }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         guard let trackerCell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell, let tracker = trackerStore.tracker(at: indexPath) else {
             return UICollectionViewCell()
         }

         let isCompleted = completedTrackers.contains { $0.date == currentDate && $0.trackerId == tracker.id }
         trackerCell.configure(with: tracker, days: tracker.daysCount, isCompleted: isCompleted)
         trackerCell.delegate = self
         return trackerCell
     }
 }

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let availableSpace = collectionView.frame.width - params.paddingWidth
        let cellWidth = availableSpace / params.cellCount
        return CGSize(width: cellWidth, height: params.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets
    {
        UIEdgeInsets(top: params.topInset, left: params.leftInset, bottom: params.bottomInset, right: params.rightInset)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath
            ) as? TrackerCategoryNames
        else { return UICollectionReusableView() }
        
        guard let label =  trackerStore.headerLabelInSection(indexPath.section) else { return UICollectionReusableView() }
        view.configure(with: label)
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
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
// MARK: - AddTrackerViewControllerDelegate
extension TrackersViewController: SetTrackersViewControllerDelegate {
    func didSelectTracker(with type: SetTrackersViewController.TrackerType) {
        dismiss(animated: true)
        let trackerFormViewController = TrackerFormViewController(type: type)
        trackerFormViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: trackerFormViewController)
        present(navigationController, animated: true)
    }
}

extension TrackersViewController: TrackerFormViewControllerDelegate {
    func didTapConfirmButton(category: TrackerCategory, trackerToAdd: Tracker) {
        dismiss(animated: true)
        try? trackerStore.addTracker(trackerToAdd, with: category)
    }
    
    func didTapCancelButton() {
        dismiss(animated: true)
    }
}

// MARK: - UISearchBarDelegate
 extension TrackersViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        checkPlaceholderVisabilityAfterSearch()
        searchBar.setShowsCancelButton(true, animated: true)
         return true
     }

     func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
         self.searchText = searchText
         collectionView.reloadData()
         checkPlaceholderVisabilityAfterSearch()
     }

     func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         searchBar.text = ""
         self.searchText = ""
         searchBar.endEditing(true)
         searchBar.setShowsCancelButton(false, animated: true)
         searchBar.resignFirstResponder()
         collectionView.reloadData()
         checkPlaceholderVisabilityAfterSearch()
     }
 }
// MARK: - TrackerCellDelegate
 extension TrackersViewController: TrackerCellDelegate {
     func didTapCompleteButton(of cell: TrackerCell, with tracker: Tracker) {
         if let recordToRemove = completedTrackers.first(where: { $0.date == currentDate && $0.trackerId == tracker.id }) {
                      try? trackerRecordStore.remove(recordToRemove)
             cell.switchAddDayButton(to: false)
             cell.decreaseCount()
         } else {
             let trackerRecord = TrackerRecord(trackerId: tracker.id, date: currentDate)
                          try? trackerRecordStore.add(trackerRecord)
             cell.switchAddDayButton(to: true)
             cell.increaseCount()
         }
     }
 }
// MARK: - TrackerStoreDelegate
 extension TrackersViewController: TrackerStoreDelegate {
     func didUpdate() {
         checkNumberOfTrackers()
         collectionView.reloadData()
     }
 }

 // MARK: - TrackerRecordStoreDelegate
 extension TrackersViewController: TrackerRecordStoreDelegate {
     func didUpdateRecords(_ records: Set<TrackerRecord>) {
         completedTrackers = records
     }
 }
