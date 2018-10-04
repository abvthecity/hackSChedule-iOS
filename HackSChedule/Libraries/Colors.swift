//
//  Colors.swift
//  HackSChedule
//
//  Created by Andrew Jiang on 5/3/18.
//  Copyright © 2018 Andrew Jiang. All rights reserved.
//

import UIKit

class Colors {
    
    static let red: UIColor = rgb(244,67,54)
    static let pink: UIColor = rgb(233,30,99)
    static let purple: UIColor = rgb(156,39,176)
    static let deepPurple: UIColor = rgb(103,58,183)
    static let indigo: UIColor = rgb(92,107,192)
    static let blue: UIColor = rgb(33,150,243)
    static let lightBlue: UIColor = rgb(3,169,244)
    static let cyan: UIColor = rgb(0,188,212)
    static let teal: UIColor = rgb(0,150,136)
    static let green: UIColor = rgb(76,175,80)
    static let lightGreen: UIColor = rgb(139,195,74)
    static let lime: UIColor = rgb(175,180,43)
    static let yellow: UIColor = rgb(251,192,45)
    static let orange: UIColor = rgb(251,140,0)
    static let deepOrange: UIColor = rgb(255,87,34)
    static let brown: UIColor = rgb(121,85,72)
    static let blueGrey: UIColor = rgb(96,125,139)
    
    static let darkRed: UIColor = UIColor(red: 153.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
    static let darkerRed: UIColor = UIColor(red: 102.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
    static let gold: UIColor = UIColor(red: 1.0, green: (204.0/255.0), blue: 0.0, alpha: 1.0)
    
    static let list: [UIColor] = [
        orange,
        lime,
        green,
        blue,
        indigo,
        purple,
        pink,
    ]
    
    static func rgb(_ r: Int, _ g: Int, _ b: Int) -> UIColor {
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
    }
}
