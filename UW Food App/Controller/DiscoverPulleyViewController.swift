//
//  DiscoverViewController.swift
//  UW Food App
//
//  Created by Thipok Cholsaipant on 11/28/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import Pulley

class DiscoverPulleyViewController: PulleyViewController {
    
    @IBOutlet var mapView: UIView!
    @IBOutlet var cardView: UICollectionView!
    
    var mapViewController: DiscoverMapViewController!
    var cardViewController: DiscoverCardViewController!
    
    var initialPadding:UIEdgeInsets!
    var userData:Restaurant! {
        didSet {
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.primaryContentContainerView = mapView
        super.drawerContentContainerView = cardView
        super.drawerCornerRadius = 0
        super.backgroundDimmingColor = .clear
        super.backgroundDimmingOpacity = CGFloat(0)
        super.drawerBackgroundVisualEffectView = nil
        mapViewController = childViewControllers.first as? DiscoverMapViewController
        cardViewController = childViewControllers.last as? DiscoverCardViewController
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = super.collapsedDrawerHeight(bottomSafeArea: CGFloat(300))
        // Do any additional setup after loading the view.
                getTodayDate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTodayDate() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd"
        let convertedDate = dateFormatter.string(from: currentDate)
//        dateLabelAsButton.setTitle(String(convertedDate), for: .normal)
//        dateLabelAsButton.tintColor = UIColor.flatGray()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}




