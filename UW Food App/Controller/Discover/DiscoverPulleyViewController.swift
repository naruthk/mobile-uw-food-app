//
//  DiscoverPulleyViewController.swift
//  UW Food App
//
//  Created by Thipok Cholsaipant on 11/28/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import Pulley
import GoogleMaps
import FluentIcons

class DiscoverPulleyViewController: PulleyViewController {
    
    @IBOutlet var mapView: UIView!
//    @IBOutlet var cardView: UICollectionView!
//    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var accountView: UIView!
    
    var mapViewController: DiscoverMapViewController!
    var cardViewController: DrawerViewController!
    
    var initialPadding:UIEdgeInsets!
    var userData:Restaurant! {
        didSet {
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.primaryContentContainerView = mapView
//        super.drawerContentContainerView = cardView
        super.drawerCornerRadius = 0
        super.backgroundDimmingColor = .clear
        super.backgroundDimmingOpacity = CGFloat(0)
        super.drawerBackgroundVisualEffectView = nil
        mapViewController = children.first as? DiscoverMapViewController
        cardViewController = children.last as? DrawerViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setAccountButton()
//        setFloatingNav()
    }
    
    func setFloatingNav() {
//        view.bringSubviewToFront(accountButton)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setAccountButton() {
        let icon = UIImage(fluent: .person24Filled)
//        accountButton.setImage(icon, for: .normal)
//        accountButton.layer.shadowOpacity = 0.25;
//        accountButton.layer.shadowRadius = 12;

    }
//    @IBAction func accountButtonClicked(_ sender: Any) {
//        print("accountButtonClicked")
//    }
    
    @IBAction func goToMyLocation(_ sender: Any) {
        if let location = mapViewController.locationManager.location {
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15)
            mapViewController.googleMaps.camera = camera
        }
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




