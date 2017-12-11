//
//  DiscoverCardViewController.swift
//  UW Food App
//
//  Created by Thipok Cholsaipant on 11/28/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import Pulley
import Cards

class DiscoverCardViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationCardCell", for: indexPath)
        return cell
    }
}

extension DiscoverCardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return CGSize(width: collectionView.bounds.width, height: CGFloat(600))
        } else {
            
            // Number of Items per Row
            let numberOfItemsInRow = 2
            
            // Current Row Number
            let rowNumber = indexPath.item/numberOfItemsInRow
            
            // Compressed With
            let compressedWidth = collectionView.bounds.width/3
            
            // Expanded Width
            let expandedWidth = (collectionView.bounds.width/3) * 2
            
            // Is Even Row
            let isEvenRow = rowNumber % 2 == 0
            
            // Is First Item in Row
            let isFirstItem = indexPath.item % numberOfItemsInRow != 0
            
            // Calculate Width
            var width: CGFloat = 0.0
            if isEvenRow {
                width = isFirstItem ? compressedWidth : expandedWidth
            } else {
                width = isFirstItem ? expandedWidth : compressedWidth
            }
            
            return CGSize(width: width, height: CGFloat(30))
        }
    }
}

extension DiscoverCardViewController: PulleyDrawerViewControllerDelegate {
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.closed] // You can specify the drawer positions you support. This is the same as: [.open, .partiallyRevealed, .collapsed, .closed]
    }
    
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 100.0 + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 264.0 + bottomSafeArea
    }
    
    
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat)
    {
        let discoverVC = parent as? DiscoverPulleyViewController

        // Set scrolling in card view
        if let cardVC = discoverVC?.cardViewController {
            switch drawer.drawerPosition {
                case .open:
                cardVC.collectionView?.isScrollEnabled = true
                default:
                cardVC.collectionView?.isScrollEnabled = false
            }
        }
    }
    
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        let scrollHeight = drawer.visibleDrawerHeight - bottomSafeArea
        let progress = 1 - ((drawer.visibleDrawerHeight - distance) / scrollHeight)
        var dimmingProgress:CGFloat {
            get {
                if drawer.supportedDrawerPositions().contains(PulleyPosition.partiallyRevealed) {
                    if distance == drawer.visibleDrawerHeight {
                        return 1
                    } else if distance < drawer.partialRevealDrawerHeight(bottomSafeArea: bottomSafeArea){
                        return 0
                    }
                    return (distance - drawer.partialRevealDrawerHeight(bottomSafeArea: bottomSafeArea)) / (drawer.visibleDrawerHeight - drawer.partialRevealDrawerHeight(bottomSafeArea: bottomSafeArea))
                }
                return progress
            }
        }
        
//        let discoverVC = parent as? DiscoverPulleyViewController
        
        // Set maps padding
//        if let currentPadding = discoverVC?.mapViewController?.mapsPadding {
//            if discoverVC?.initialPadding == nil {
//                discoverVC?.initialPadding = currentPadding
//            }
//            discoverVC?.mapViewController.mapsPadding = UIEdgeInsets(top: currentPadding.top, left: currentPadding.left, bottom: distance - bottomSafeArea, right: currentPadding.right)
//        }
//
//        discoverVC?.mapViewController?.view?.alpha = 1 - dimmingProgress
    }
}



