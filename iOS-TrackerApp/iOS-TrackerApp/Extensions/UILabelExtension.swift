//
//  UILabelExtension.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 31.07.23.
//

import UIKit

extension UILabel {
    func configureLabel(text: String, addToView: UIView, ofSize: CGFloat, weight: UIFont.Weight) {
        self.translatesAutoresizingMaskIntoConstraints = false
        addToView.addSubview(self)
        self.text = text
        self.font = UIFont.systemFont(ofSize: ofSize, weight: weight)
        self.textAlignment = .center
        self.textColor = .BlackDay
    }
}
