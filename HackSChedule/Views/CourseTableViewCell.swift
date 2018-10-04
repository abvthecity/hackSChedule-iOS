//
//  CourseTableViewCell.swift
//  HackSChedule
//
//  Created by Andrew Jiang on 5/2/18.
//  Copyright © 2018 Andrew Jiang. All rights reserved.
//

/*
 let shadowView = UIView(frame: CGRectMake(50, 50, 100, 100))
 shadowView.layer.shadowColor = UIColor.blackColor().CGColor
 shadowView.layer.shadowOffset = CGSizeZero
 shadowView.layer.shadowOpacity = 0.5
 shadowView.layer.shadowRadius = 5
 
 let view = MyView(frame: shadowView.bounds)
 view.backgroundColor = UIColor.whiteColor()
 view.layer.cornerRadius = 10.0
 view.layer.borderColor = UIColor.grayColor().CGColor
 view.layer.borderWidth = 0.5
 view.clipsToBounds = true
 */

import UIKit

class CourseTableViewCell: UITableViewCell {
    static let reuseId = "CourseTableViewCell"
    
    let animationDuration: TimeInterval = 0.15

    // MARK: - Properties
    
    private var bgView: UIView = UIView()
    private var bgShadowView: UIView = UIView()
    
    private(set) var courseId: UILabel = UILabel()
    private(set) var courseName: UILabel = UILabel()
    private(set) var units: UILabel = UILabel()
    private(set) var types: UILabel = UILabel()
    
    var bgColor: UIColor? {
        get {
            return bgView.backgroundColor
        }
        set {
            bgView.backgroundColor = newValue
        }
    }
    
    // MARK: - Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        selectionStyle = .none
        alpha = 0.0
        
        // properties
        
        courseId.text = "XXX-XXX"
        courseName.text = "Untitled Course Name"
        units.text = "4.0 units"
        types.text = "Lec"
        
        bgShadowView.backgroundColor = UIColor.clear
        bgShadowView.layer.shadowColor = UIColor.black.cgColor
        bgShadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        bgShadowView.layer.shadowOpacity = 0.15
        bgShadowView.layer.shadowRadius = 10
        
        bgView.backgroundColor = UIColor.black
        bgView.layer.cornerRadius = 4
        bgView.clipsToBounds = true
        
        courseName.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        courseName.textAlignment = .left
        courseName.numberOfLines = 0
        courseName.lineBreakMode = .byWordWrapping
        courseName.translatesAutoresizingMaskIntoConstraints = false
        courseName.textColor = UIColor.white
        
        courseId.font = UIFont.systemFont(ofSize: 17.0, weight: .heavy)
        courseId.textColor = UIColor.white
        
        units.font = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        units.textColor = UIColor.white
        
        types.font = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        types.textColor = UIColor.white
        
        // add to subview
        
        addSubview(bgShadowView)
        bgShadowView.addSubview(bgView)
        bgView.addSubview(courseName)
        bgView.addSubview(courseId)
        bgView.addSubview(units)
        bgView.addSubview(types)
        
        // constraints
        
        layoutBgShadowView()
        layoutBgView()
        layoutCourseId()
        layoutCourseName()
        layoutUnits()
        layoutTypes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var isScaled: Bool = false
    
    func setScale(_ isScaled: Bool, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        let scaleFactor: CGFloat = CGFloat(isScaled ? 1.05 : 1.0)
        let transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        if !animated {
            self.transform = transform
        } else {
            UIView.animate(withDuration: animationDuration, animations: {
                self.transform = transform
            }, completion: { (completed) in
                self.isScaled = isScaled
                completion?(completed)
            })
        }
    }

    func layoutBgShadowView() {
        bgShadowView.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = NSLayoutConstraint(item: bgShadowView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 10.0)
        let rightConstraint = NSLayoutConstraint(item: bgShadowView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -10.0)
        let topConstraint = NSLayoutConstraint(item: bgShadowView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 5.0)
        let bottomConstraint = NSLayoutConstraint(item: bgShadowView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -5.0)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }
    
    func layoutBgView() {
        bgView.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = NSLayoutConstraint(item: bgView, attribute: .left, relatedBy: .equal, toItem: bgShadowView, attribute: .left, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: bgView, attribute: .right, relatedBy: .equal, toItem: bgShadowView, attribute: .right, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: bgView, attribute: .top, relatedBy: .equal, toItem: bgShadowView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: bgView, attribute: .bottom, relatedBy: .equal, toItem: bgShadowView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }
    
    func layoutCourseId() {
        courseId.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = NSLayoutConstraint(item: courseId, attribute: .left, relatedBy: .equal, toItem: bgView, attribute: .left, multiplier: 1.0, constant: 8.0)
        let topConstraint = NSLayoutConstraint(item: courseId, attribute: .top, relatedBy: .equal, toItem: bgView, attribute: .top, multiplier: 1.0, constant: 8.0)
        let rightConstraint = NSLayoutConstraint(item: courseId, attribute: .right, relatedBy: .equal, toItem: bgView, attribute: .left, multiplier: 1.0, constant: 100.0)
        NSLayoutConstraint.activate([leftConstraint, topConstraint, rightConstraint])
    }
    
    func layoutCourseName() {
        let leftConstraint = NSLayoutConstraint(item: courseName, attribute: .left, relatedBy: .equal, toItem: bgView, attribute: .left, multiplier: 1.0, constant: 108.0)
        let rightConstraint = NSLayoutConstraint(item: courseName, attribute: .right, relatedBy: .equal, toItem: bgView, attribute: .right, multiplier: 1.0, constant: -8.0)
        let topConstraint = NSLayoutConstraint(item: courseName, attribute: .top, relatedBy: .equal, toItem: bgView, attribute: .top, multiplier: 1.0, constant: 8.0)
        let bottomConstraint = NSLayoutConstraint(item: courseName, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: bgView, attribute: .bottom, multiplier: 1.0, constant: -8.0)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }
    
    func layoutUnits() {
        units.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = NSLayoutConstraint(item: units, attribute: .left, relatedBy: .equal, toItem: bgView, attribute: .left, multiplier: 1.0, constant: 8.0)
        let topConstraint = NSLayoutConstraint(item: units, attribute: .top, relatedBy: .equal, toItem: courseId, attribute: .bottom, multiplier: 1.0, constant: 4.0)
        let rightConstraint = NSLayoutConstraint(item: units, attribute: .right, relatedBy: .equal, toItem: bgView, attribute: .left, multiplier: 1.0, constant: 100.0)
        NSLayoutConstraint.activate([leftConstraint, topConstraint, rightConstraint])
    }
    
    func layoutTypes() {
        types.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = NSLayoutConstraint(item: types, attribute: .left, relatedBy: .equal, toItem: bgView, attribute: .left, multiplier: 1.0, constant: 8.0)
        let rightConstraint = NSLayoutConstraint(item: types, attribute: .right, relatedBy: .equal, toItem: bgView, attribute: .left, multiplier: 1.0, constant: 100.0)
        let topConstraint = NSLayoutConstraint(item: types, attribute: .top, relatedBy: .equal, toItem: units, attribute: .bottom, multiplier: 1.0, constant: 4.0)
        let bottomConstraint = NSLayoutConstraint(item: types, attribute: .bottom, relatedBy: .equal, toItem: bgView, attribute: .bottom, multiplier: 1.0, constant: -8.0)
        NSLayoutConstraint.activate([leftConstraint, topConstraint, rightConstraint, bottomConstraint])
    }
    
}
