//
//  NavCollectionViewCell.swift
//  HackSChedule
//
//  Created by Andrew Jiang on 5/3/18.
//  Copyright © 2018 Andrew Jiang. All rights reserved.
//

import UIKit

class NavCollectionViewCell: UICollectionViewCell {
    private var bgView: UIView = UIView()
    private(set) var index: UILabel = UILabel()
    
    static let darkBackground = UIColor(white: 0.0, alpha: 0.4)
    static let darkBorder = UIColor.black
    static let lightBackground = UIColor(white: 1.0, alpha: 0.4)
    static let lightBorder = UIColor(white: 1.0, alpha: 1.0)
    
    var isActive: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bgView.backgroundColor = NavCollectionViewCell.darkBackground
        bgView.layer.cornerRadius = 4
        bgView.layer.borderWidth = 1.0
        bgView.layer.borderColor = NavCollectionViewCell.darkBorder.cgColor
        bgView.clipsToBounds = true
        
        index.text = "0"
        index.textColor = UIColor.white
        index.font = UIFont.systemFont(ofSize: 12.0, weight: .heavy)
        index.textAlignment = .center
        
        addSubview(bgView)
        bgView.addSubview(index)
        
        layoutBgView()
        layoutIndex()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setColorScheme(_ isLight: Bool) {
        if isLight {
            self.bgView.backgroundColor = NavCollectionViewCell.lightBackground
            self.bgView.layer.borderColor = NavCollectionViewCell.lightBorder.cgColor
        } else {
            self.bgView.backgroundColor = NavCollectionViewCell.darkBackground
            self.bgView.layer.borderColor = NavCollectionViewCell.darkBorder.cgColor
        }
    }
    
    func setActive(_ isActive: Bool) {
        if isActive != self.isActive && isActive {
            UIView.animate(withDuration: 0.15, animations: {
                self.setColorScheme(isActive)
            }, completion: { (completed) in
                self.isActive = isActive
            })
        } else {
            self.setColorScheme(isActive)
        }
    }
    
    func layoutBgView() {
        bgView.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = NSLayoutConstraint(item: bgView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 4.0)
        let rightConstraint = NSLayoutConstraint(item: bgView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -4.0)
        let topConstraint = NSLayoutConstraint(item: bgView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 4.0)
        let bottomConstraint = NSLayoutConstraint(item: bgView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -4.0)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }
    
    func layoutIndex() {
        index.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = NSLayoutConstraint(item: index, attribute: .left, relatedBy: .equal, toItem: bgView, attribute: .left, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: index, attribute: .right, relatedBy: .equal, toItem: bgView, attribute: .right, multiplier: 1.0, constant: 0)
        let topConstraint = NSLayoutConstraint(item: index, attribute: .top, relatedBy: .equal, toItem: bgView, attribute: .top, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: index, attribute: .bottom, relatedBy: .equal, toItem: bgView, attribute: .bottom, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }
}
