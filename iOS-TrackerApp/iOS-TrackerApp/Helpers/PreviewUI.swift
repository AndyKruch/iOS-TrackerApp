//
//  PreviewUI.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 31.07.23.
//


import SwiftUI

extension UIViewController {

    private struct Preview: UIViewControllerRepresentable {
        let vc: UIViewController

        func makeUIViewController(context: Context) -> some UIViewController { vc }
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
    }

    func showPreview() -> some View {
        Preview(vc: self).edgesIgnoringSafeArea(.all)
    }
}
