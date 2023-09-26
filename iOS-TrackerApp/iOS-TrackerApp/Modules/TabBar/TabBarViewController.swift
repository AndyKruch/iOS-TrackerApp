//
//  TabBarViewController.swift
//  iOS-TrackerApp
//
//  Created by Andy Kruch on 31.07.23.
//

import UIKit

class TabBarViewController: UITabBarController {
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: "visitedBefore")
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .WhiteDay
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        tabBar.tintColor = .Blue
        
        let trackersViewController = TrackersViewController()
        let statisticViewController = StatisticViewController()
        let statisticViewModel = StatisticViewModel()
        statisticViewController.statisticViewModel = statisticViewModel
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("TrackersViewController.title", comment: ""),
            image: UIImage(named: "Trackers_TabBarIcon_on"),
            selectedImage: nil
        )
        statisticViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("StatisticViewController.title", comment: ""),
            image: UIImage(named: "Statistics_TabBarIcon_off"),
            selectedImage: nil
        )
        
        let controllers = [trackersViewController, statisticViewController]
        
        viewControllers = controllers
    }
}
