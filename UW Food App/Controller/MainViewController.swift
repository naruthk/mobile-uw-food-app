//
//  MainViewController.swift
//  UW Food App
//
//  Created by Thipok Cholsaipant on 8/7/20.
//  Copyright © 2020 iSchool. All rights reserved.
//

import FluentIcons
import UIKit


private enum TabTitles: String, CustomStringConvertible {
    case  Discover
    case  Search
    case  Account

    var description: String {
        return self.rawValue
    }
}

private var tabIcons = [
    TabTitles.Discover: UIImage(fluent: .compassNorthwest28Regular),
    TabTitles.Search: UIImage(fluent: .search28Regular),
    TabTitles.Account: UIImage(fluent: .person28Regular)
]

class MainViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if let vcs = viewControllers {
            for vc in vcs {
                let item = vc.tabBarItem as UITabBarItem
                if let title = item.title,
                   let tab = TabTitles(rawValue: title),
                   let image = tabIcons[tab] {
                    item.title = title
                    item.image = image
                }
            }
        }
    }
}
