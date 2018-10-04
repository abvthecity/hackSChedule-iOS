//
//  NavigationController.swift
//  HackSChedule
//
//  Created by Andrew Jiang on 5/2/18.
//  Copyright © 2018 Andrew Jiang. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    let gradientLayer = CAGradientLayer()
    let logoImageView = UIImageView(image: #imageLiteral(resourceName: "hackSChedule-logo"))
    let termLabel = UILabel()
    
    // MARK: - ViewController lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // following order is important:
        self.loadLogoImageView()
        self.loadTermLabel()
        self.applyConstraints()
        
        self.pushViewController(CourseTableViewController.shared, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gradientLayer.frame = UIScreen.main.bounds
        gradientLayer.colors = [Colors.darkRed.cgColor, Colors.darkerRed.cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - UI helper methods
    
    private func loadTermLabel() {
        self.termLabel.text = Trojan.convertTerm(from: Trojan.term)
        self.termLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .heavy)
        self.termLabel.textColor = Colors.gold
        self.navigationBar.addSubview(self.termLabel)
    }
    
    private func loadLogoImageView() {
        self.navigationBar.addSubview(self.logoImageView)
    }
    
    private func applyConstraints() {
        self.termLabel.translatesAutoresizingMaskIntoConstraints = false
        self.logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([NSLayoutConstraint(item: self.logoImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 170),
                                     NSLayoutConstraint(item: self.logoImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 29),
                                     NSLayoutConstraint(item: self.termLabel, attribute: .centerY, relatedBy: .equal, toItem: self.navigationBar, attribute: .centerY, multiplier: 1.0, constant: 4.0),
                                     NSLayoutConstraint(item: self.logoImageView, attribute: .centerY, relatedBy: .equal, toItem: self.navigationBar, attribute: .centerY, multiplier: 1.0, constant: 0.0),
                                     NSLayoutConstraint(item: self.logoImageView, attribute: .left, relatedBy: .equal, toItem: self.navigationBar, attribute: .left, multiplier: 1.0, constant: 10.0),
                                     NSLayoutConstraint(item: self.termLabel, attribute: .left, relatedBy: .equal, toItem: self.logoImageView, attribute: .right, multiplier: 1.0, constant: 10.0)])
    }
    
    func renderNavigationBar(_ viewController: UIViewController) {
        navigationBar.isTranslucent = true
        
        if viewController is CourseTableViewController {
            navigationBar.isHidden = false
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
            self.logoImageView.isHidden = false
            self.termLabel.isHidden = false
        } else if viewController is CalendarViewController {
            navigationBar.isHidden = true
        } else {
            navigationBar.isHidden = false
            navigationBar.setBackgroundImage(nil, for: .default)
            navigationBar.shadowImage = nil
            self.logoImageView.isHidden = true
            self.termLabel.isHidden = true
        }
    }
}
