//
//  UIColorExtentions.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 31.07.23.
//

import Foundation

import UIKit

extension UIColor {
    
    // MARK: - Interface (main) colors
    static var BlackDay: UIColor { UIColor(named: "Black [day]") ?? UIColor.black }
    static var BlackNight: UIColor { UIColor(named: "Black [night]") ?? UIColor.white }
    static var WhiteDay: UIColor { UIColor(named: "White [day]") ?? UIColor.white }
    static var WhiteNight: UIColor { UIColor(named: "White [night]") ?? UIColor.black }
    static var Blue: UIColor { UIColor(named: "Blue") ?? UIColor.blue }
    static var Red: UIColor { UIColor(named: "Red") ?? UIColor.red }
    static var BackgroundNight: UIColor { UIColor(named: "Background [night]") ?? UIColor.darkGray }
    static var BackgroundDay: UIColor { UIColor(named: "Background [day]") ?? UIColor.gray }
    static var Gray: UIColor { UIColor(named: "Gray") ?? UIColor.gray }
    static var LightGray: UIColor { UIColor(named: "Light Gray") ?? UIColor.lightGray }
    
    static let bunchOfSChoices = [
        UIColor(named: "Color Selection 1")!,
        UIColor(named: "Color Selection 2")!,
        UIColor(named: "Color Selection 3")!,
        UIColor(named: "Color Selection 4")!,
        UIColor(named: "Color Selection 5")!,
        UIColor(named: "Color Selection 6")!,
        UIColor(named: "Color Selection 7")!,
        UIColor(named: "Color Selection 8")!,
        UIColor(named: "Color Selection 9")!,
        UIColor(named: "Color Selection 10")!,
        UIColor(named: "Color Selection 11")!,
        UIColor(named: "Color Selection 12")!,
        UIColor(named: "Color Selection 13")!,
        UIColor(named: "Color Selection 14")!,
        UIColor(named: "Color Selection 15")!,
        UIColor(named: "Color Selection 16")!,
        UIColor(named: "Color Selection 17")!,
        UIColor(named: "Color Selection 18")!
    ]
}
