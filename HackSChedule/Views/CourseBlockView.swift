//
//  CourseBlockView.swift
//  HackSChedule
//
//  Created by Andrew Jiang on 5/3/18.
//  Copyright © 2018 Andrew Jiang. All rights reserved.
//

import UIKit

class CourseBlockView: UIView {

    private var bgView: UIView = UIView()
    private var bgShadowView: UIView = UIView()
    
    private(set) var courseId: UILabel = UILabel()
    private(set) var sectionId: UILabel = UILabel()
    private(set) var details: UILabel = UILabel()
    
    var bgColor: UIColor? {
        get {
            return bgView.backgroundColor
        }
        set {
            bgView.backgroundColor = newValue
        }
    }
    
    static func create(courseId: String, sectionId: String, details: String, bgColor: UIColor, frame: CGRect) -> CourseBlockView {
        let blockView = CourseBlockView()
        blockView.courseId.text = courseId
        blockView.sectionId.text = sectionId
        blockView.details.text = details
        blockView.bgColor = bgColor
        blockView.frame = frame
        return blockView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bgShadowView.backgroundColor = UIColor.clear
        bgShadowView.layer.shadowColor = UIColor.black.cgColor
        bgShadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        bgShadowView.layer.shadowOpacity = 0.15
        bgShadowView.layer.shadowRadius = 4
        
        
        bgView.backgroundColor = UIColor.black
        bgView.layer.cornerRadius = 4
        bgView.clipsToBounds = true
        
        courseId.text = "XXX-###"
        courseId.textColor = UIColor.white
        courseId.font = UIFont.systemFont(ofSize: 12.0, weight: .heavy)
        
        sectionId.text = "######"
        sectionId.textColor = UIColor.white
        sectionId.font = UIFont.systemFont(ofSize: 10.0, weight: .regular)
        
        details.text = "Lec, 10a–11:50a, Wang"
        details.textColor = UIColor.white
        details.font = UIFont.systemFont(ofSize: 10.0, weight: .regular)
        details.numberOfLines = 0
        details.lineBreakMode = .byWordWrapping
        
        addSubview(bgShadowView)
        bgShadowView.addSubview(bgView)
        bgView.addSubview(courseId)
        bgView.addSubview(sectionId)
        bgView.addSubview(details)
        
        layoutBgShadowView()
        layoutBgView()
        layoutCourseId()
        layoutSectionId()
        layoutDetails()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layoutBgShadowView() {
        bgShadowView.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = NSLayoutConstraint(item: bgShadowView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: bgShadowView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: bgShadowView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: bgShadowView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
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
        let leftConstraint = NSLayoutConstraint(item: courseId, attribute: .left, relatedBy: .equal, toItem: bgView, attribute: .left, multiplier: 1.0, constant: 4.0)
        let topConstraint = NSLayoutConstraint(item: courseId, attribute: .top, relatedBy: .equal, toItem: bgView, attribute: .top, multiplier: 1.0, constant: 4.0)
        NSLayoutConstraint.activate([leftConstraint, topConstraint])
    }
    
    func layoutSectionId() {
        sectionId.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = NSLayoutConstraint(item: sectionId, attribute: .left, relatedBy: .equal, toItem: courseId, attribute: .right, multiplier: 1.0, constant: 4.0)
        let bottomConstraint = NSLayoutConstraint(item: sectionId, attribute: .bottom, relatedBy: .equal, toItem: courseId, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: sectionId, attribute: .right, relatedBy: .lessThanOrEqual, toItem: bgView, attribute: .right, multiplier: 1.0, constant: -4.0)
        NSLayoutConstraint.activate([leftConstraint, bottomConstraint, rightConstraint])
    }
    
    func layoutDetails() {
        details.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = NSLayoutConstraint(item: details, attribute: .left, relatedBy: .equal, toItem: bgView, attribute: .left, multiplier: 1.0, constant: 4.0)
        let rightConstraint = NSLayoutConstraint(item: details, attribute: .right, relatedBy: .equal, toItem: bgView, attribute: .right, multiplier: 1.0, constant: -4.0)
        let topConstraint = NSLayoutConstraint(item: details, attribute: .top, relatedBy: .equal, toItem: courseId, attribute: .bottom, multiplier: 1.0, constant: 2.0)
        let bottomConstraint = NSLayoutConstraint(item: details, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: bgView, attribute: .bottom, multiplier: 1.0, constant: -4.0)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }
    
    func fade(to alpha: CGFloat, withDuration duration: TimeInterval = 0.15, completion handler: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = alpha
        }, completion: handler)
    }
    
    func fadeIn(withDuration duration: TimeInterval = 0.15, completion handler: ((Bool) -> Void)? = nil) {
        fade(to: 1.0, withDuration: duration, completion: handler)
    }
    
    func fadeOut(withDuration duration: TimeInterval = 0.15, completion handler: ((Bool) -> Void)? = nil) {
        fade(to: 0.0, withDuration: duration, completion: handler)
    }
    
    override func removeFromSuperview() {
        fadeOut { _ in
            super.removeFromSuperview()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
