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
     // MARK: - Lifecycle
     
     override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .WhiteDay
         configureViews()
         configureConstraints()

     }

     // MARK: - Actions
     
     @objc
     private func didTapPlusButton() {
         print("Plus tapped")
     }
 }
  //MARK: - Layout methods
 private extension TrackersViewController {
     func configureViews() {
         view.backgroundColor = .WhiteDay
         view.addSubview(addButton)

         addButton.translatesAutoresizingMaskIntoConstraints = false
     }

     func configureConstraints() {
         NSLayoutConstraint.activate([
             addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
             addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
         ])
     }
 }

 // MARK: - SHOW PREVIEW
 import SwiftUI
 struct CreateTrackerVCProvider: PreviewProvider {
     static var previews: some View {
         TrackersViewController().showPreview()
     }
 }
