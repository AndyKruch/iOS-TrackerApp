//
//  UIColorExtentions.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 31.07.23.
//

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
        UIColor(named: "Color selection 1") ?? UIColor.black,
        UIColor(named: "Color selection 2") ?? UIColor.black,
        UIColor(named: "Color selection 3") ?? UIColor.black,
        UIColor(named: "Color selection 4") ?? UIColor.black,
        UIColor(named: "Color selection 5") ?? UIColor.black,
        UIColor(named: "Color selection 6") ?? UIColor.black,
        UIColor(named: "Color selection 7") ?? UIColor.black,
        UIColor(named: "Color selection 8") ?? UIColor.black,
        UIColor(named: "Color selection 9") ?? UIColor.black,
        UIColor(named: "Color selection 10") ?? UIColor.black,
        UIColor(named: "Color selection 11") ?? UIColor.black,
        UIColor(named: "Color selection 12") ?? UIColor.black,
        UIColor(named: "Color selection 13") ?? UIColor.black,
        UIColor(named: "Color selection 14") ?? UIColor.black,
        UIColor(named: "Color selection 15") ?? UIColor.black,
        UIColor(named: "Color selection 16") ?? UIColor.black,
        UIColor(named: "Color selection 17") ?? UIColor.black,
        UIColor(named: "Color selection 18") ?? UIColor.black
    ]
}
