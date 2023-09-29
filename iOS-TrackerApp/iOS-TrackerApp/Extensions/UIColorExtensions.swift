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
    
    static let gradient = [
        UIColor(named: "gBlue") ?? UIColor.black,
        UIColor(named: "gGreen") ?? UIColor.black,
        UIColor(named: "gRed") ?? UIColor.black,
    ]
}

// MARK: - For StatisticViewController - Gradient
extension UIView {
     private static let kLayerNameGradientBorder = "GradientBorderLayer"

     func gradientBorder(
         width: CGFloat,
         colors: [UIColor],
         startPoint: CGPoint = .init(x: 0.5, y: 0),
         endPoint: CGPoint = .init(x: 0.5, y: 1),
         andRoundCornersWithRadius cornerRadius: CGFloat = 0
     ) {
         let existingBorder = gradientBorderLayer()
         let border = existingBorder ?? .init()
         border.frame = CGRect(
             x: bounds.origin.x,
             y: bounds.origin.y,
             width: bounds.size.width + width,
             height: bounds.size.height + width
         )
         border.colors = colors.map { $0.cgColor }
         border.startPoint = startPoint
         border.endPoint = endPoint

         let mask = CAShapeLayer()
         let maskRect = CGRect(
             x: bounds.origin.x + width/2,
             y: bounds.origin.y + width/2,
             width: bounds.size.width - width,
             height: bounds.size.height - width
         )
         mask.path = UIBezierPath(
             roundedRect: maskRect,
             cornerRadius: cornerRadius
         ).cgPath
         mask.fillColor = UIColor.clear.cgColor
         mask.strokeColor = UIColor.white.cgColor
         mask.lineWidth = width

         border.mask = mask

         let isAlreadyAdded = (existingBorder != nil)
         if !isAlreadyAdded {
             layer.addSublayer(border)
         }
     }

     private func gradientBorderLayer() -> CAGradientLayer? {
         let borderLayers = layer.sublayers?.filter {
             $0.name == UIView.kLayerNameGradientBorder
         }
         if borderLayers?.count ?? 0 > 1 {
             fatalError()
         }
         return borderLayers?.first as? CAGradientLayer
     }
 }

extension CGPoint {

     enum CoordinateSide {
         case topLeft, top, topRight, right, bottomRight, bottom, bottomLeft, left
     }

     static func unitCoordinate(_ side: CoordinateSide) -> CGPoint {
         let x: CGFloat
         let y: CGFloat

         switch side {
         case .topLeft:      x = 0.0; y = 0.0
         case .top:          x = 0.5; y = 0.0
         case .topRight:     x = 1.0; y = 0.0
         case .right:        x = 0.0; y = 0.5
         case .bottomRight:  x = 1.0; y = 1.0
         case .bottom:       x = 0.5; y = 1.0
         case .bottomLeft:   x = 0.0; y = 1.0
         case .left:         x = 1.0; y = 0.5
         }
         return .init(x: x, y: y)
     }
 }
