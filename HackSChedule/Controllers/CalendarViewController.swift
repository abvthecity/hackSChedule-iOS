//
//  CalendarViewController.swift
//  HackSChedule
//
//  Created by Andrew Jiang on 5/2/18.
//  Copyright © 2018 Andrew Jiang. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CoursesModelObserver {
    
    static private var _shared: CalendarViewController?
    static var shared: CalendarViewController {
        get {
            if _shared == nil {
                _shared = CalendarViewController()
            }
            return _shared!
        }
    }
    
    let calendarView: UIScrollView = UIScrollView()
    var id = CoursesModel.observerCounter
    let model: CoursesModel = CoursesModel.shared
    
    private var blocks: [CourseBlockView] = []
    
    private let darkRed = UIColor.init(red: 153.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
    private let darkerRed = UIColor.init(red: 102.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
    private let gradientLayer = CAGradientLayer()
    
    private let mon = UILabel()
    private let tue = UILabel()
    private let wed = UILabel()
    private let thu = UILabel()
    private let fri = UILabel()
    private var daysLabels: [UILabel] = []
    
    private var calendarViewWidth: CGFloat {
        get {
            return self.calendarView.frame.width
        }
    }
    private var calendarViewHeight: CGFloat {
        get {
            return CGFloat(heightPerHour * (hours.count + 1))
        }
    }
    private var columnWidth: CGFloat {
        get {
            return (self.calendarViewWidth - self.horizontalOffset) / CGFloat(self.daysLabels.count)
        }
    }
    
    private let hours: [String] = ["8a", "9a", "10a", "11a", "12p", "1p", "2p", "3p", "4p", "5p", "6p", "7p", "8p", "9p", "10p"]
    private var hoursLabels: [UILabel] = []
    private let horizontalOffset: CGFloat = CGFloat(25.0)
    private let heightPerHour: Int = 30
    private let startingHour: Int = 7
    
    private var calendarViewShapeLayer: CAShapeLayer = CAShapeLayer()
    private var daysLabelsLayer: CAShapeLayer = CAShapeLayer()
    
    var viewLayout: UICollectionViewFlowLayout!
    var navView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = .crossDissolve
        daysLabels = [mon, tue, wed, thu, fri]
        
        layoutCalendarView()
        layoutDaysLabels()
        layoutNavView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gradientLayer.frame = UIScreen.main.bounds
        gradientLayer.colors = [darkRed.cgColor, darkerRed.cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        drawCalendarViewGrid()
        drawDaysLabelsGrid()
        fadeIn()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        model.attachObserver(self)
        update()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        model.removeObserver(self)
    }
    
    private func layoutCalendarView() {
        calendarView.backgroundColor = UIColor.white
        calendarView.isScrollEnabled = true
        calendarView.showsHorizontalScrollIndicator = false
        calendarView.showsVerticalScrollIndicator = true
        calendarView.isDirectionalLockEnabled = true
        calendarView.alwaysBounceHorizontal = false
        calendarView.alwaysBounceVertical = true
        calendarView.contentSize = CGSize(width: view.frame.width, height: calendarViewHeight)
        view.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: calendarView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: calendarView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: calendarView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 24.0),
            NSLayoutConstraint(item: calendarView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -48.0)
        ])
        
        for i in 0...(hours.count - 1) {
            let label = UILabel()
            label.text = hours[i]
            label.font = UIFont.systemFont(ofSize: 10.0, weight: .bold)
            label.textColor = UIColor(white: 0.0, alpha: 0.3)
            label.textAlignment = .right
            label.sizeToFit()
            label.frame = CGRect(x: CGFloat(0.0), y: 30.0 * CGFloat(i + 1) - (label.bounds.height / 2.0), width: 22.0, height: label.bounds.height)
            label.alpha = 0.0
            calendarView.addSubview(label)
            hoursLabels.append(label)
        }
        
        calendarViewShapeLayer.opacity = 0.0
        calendarViewShapeLayer.strokeColor = UIColor.black.cgColor
        calendarViewShapeLayer.fillColor = UIColor.clear.cgColor
        calendarViewShapeLayer.lineWidth = 0.5
        calendarView.layer.addSublayer(calendarViewShapeLayer)
    }
    
    private func layoutDaysLabels() {
        mon.text = "MON"
        mon.textColor = UIColor.white
        mon.font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
        mon.textAlignment = .center
        
        tue.text = "TUE"
        tue.textColor = UIColor.white
        tue.font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
        tue.textAlignment = .center
        
        wed.text = "WED"
        wed.textColor = UIColor.white
        wed.font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
        wed.textAlignment = .center
        
        thu.text = "THU"
        thu.textColor = UIColor.white
        thu.font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
        thu.textAlignment = .center
        
        fri.text = "FRI"
        fri.textColor = UIColor.white
        fri.font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
        fri.textAlignment = .center
        
        view.addSubview(mon)
        view.addSubview(tue)
        view.addSubview(wed)
        view.addSubview(thu)
        view.addSubview(fri)
        
        daysLabelsLayer.opacity = 0
        daysLabelsLayer.strokeColor = UIColor.black.cgColor
        daysLabelsLayer.fillColor = UIColor.clear.cgColor
        daysLabelsLayer.lineWidth = 0.5
        
        view.layer.addSublayer(daysLabelsLayer)
    }
    
    private func layoutNavView() {
        viewLayout = UICollectionViewFlowLayout()
        viewLayout.scrollDirection = .horizontal
        viewLayout.minimumInteritemSpacing = 0.0
        viewLayout.minimumLineSpacing = 0.0
        viewLayout.itemSize = CGSize(width: 48.0, height: 48.0)
        
        navView = UICollectionView(frame: CGRect(), collectionViewLayout: viewLayout)
        navView.delegate = self
        navView.dataSource = self
        navView.backgroundColor = UIColor.clear
        navView.register(NavCollectionViewCell.self, forCellWithReuseIdentifier: "NavCell")
        navView.showsVerticalScrollIndicator = false
        navView.showsHorizontalScrollIndicator = true
        navView.alwaysBounceVertical = false
        navView.alwaysBounceHorizontal = true
        navView.alpha = 0.0
        view.addSubview(navView)
        
        navView.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = NSLayoutConstraint(item: navView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: navView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: navView, attribute: .top, relatedBy: .equal, toItem: calendarView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: navView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }
    
    private func drawCalendarViewGrid() {
        calendarView.contentSize.height = calendarViewHeight
        
        let path = UIBezierPath()
        var x: CGFloat, y: CGFloat
        for i in 0...(hours.count + 1) {
            y = CGFloat(i) * 30.0
            path.move(to: CGPoint(x: horizontalOffset, y: y))
            path.addLine(to: CGPoint(x: view.frame.width, y: y))
        }
        for i in 0...4 {
            x = horizontalOffset + (CGFloat(i) * columnWidth)
            path.move(to: CGPoint(x: x, y: -500.0))
            path.addLine(to: CGPoint(x: x, y: calendarViewHeight + 500.0))
        }
        
        calendarViewShapeLayer.path = path.cgPath
    }
    
    private func drawDaysLabelsGrid() {
        let labelsHeight = CGFloat(24.0)
        let path = UIBezierPath()
        var x: CGFloat
        for i in 0...4 {
            x = horizontalOffset + (CGFloat(i) * columnWidth)
            path.move(to: CGPoint(x: x, y: 0.0))
            path.addLine(to: CGPoint(x: x, y: labelsHeight))
            daysLabels[i].frame = CGRect(x: x, y: 0.0, width: columnWidth, height: labelsHeight)
        }
        daysLabelsLayer.path = path.cgPath
    }
    
    private func fadeIn() {
        UIView.animate(withDuration: 0.15) {
            self.calendarViewShapeLayer.opacity = 0.15
            self.daysLabelsLayer.opacity = 0.25
            for label in self.daysLabels {
                label.alpha = 1.0
            }
            for label in self.hoursLabels {
                label.alpha = 1.0
            }
            self.navView.alpha = 1.0
        }
    }

    override open var shouldAutorotate: Bool {
        return UIDeviceOrientationIsLandscape(UIDevice.current.orientation)
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    @objc func deviceRotated() {
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) && UIDevice.current.orientation == .portrait && !self.isBeingDismissed {
            dismiss(animated: true)
        } else if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            gradientLayer.frame = UIScreen.main.bounds
            drawCalendarViewGrid()
            drawDaysLabelsGrid()
        }
    }
    
    func clearBlocks() {
        for block in blocks {
            block.removeFromSuperview()
        }
        blocks.removeAll()
    }
    
    func canRender(block: Block) -> Bool {
        return block.day != .unknown && block.start != nil && block.end != nil
    }
    
    func appendBlock(_ block: Block, courseId: String, sectionId: String) {
        let courseIndex = model.courses.index { $0.id == courseId }
        
        if !canRender(block: block) || courseIndex == nil {
            return
        }
        
        let bgColor = Colors.list[courseIndex! % Colors.list.count]
        
        let course = model.courses[courseIndex!]
        let type = course.sections[sectionId]!.type
        let startTime = Block.convertFrom(minutes: block.start)
        let endTime = Block.convertFrom(minutes: block.end)
        let details = startTime == nil ? "\(type)" : "\(type), \(startTime!)–\(endTime!)"
        
        let x = self.horizontalOffset + (CGFloat(block.day.hashValue) * self.columnWidth)
        let y = ((CGFloat(block.start!) / 60.0) - CGFloat(self.startingHour)) * CGFloat(self.heightPerHour)
        let width = self.columnWidth
        let height = ((CGFloat(block.end!) / 60.0) - CGFloat(self.startingHour)) * CGFloat(self.heightPerHour) - y
        let frame = CGRect(x: x + 0.5, y: y, width: width - 1.0, height: height)
        
        let blockView = CourseBlockView.create(courseId: courseId, sectionId: sectionId, details: details, bgColor: bgColor, frame: frame)
        calendarView.addSubview(blockView)
        blockView.alpha = 0.0
        blockView.fadeIn()
        self.blocks.append(blockView)
    }
    
    func createCalendar(forSchedule combination: Combination) {
        for pair in combination {
            let courseId = pair.key
            if let scenarios = model.corpus[pair.key]?[pair.value] {
                for scenario in scenarios {
                    let sectionId = scenario.key
                    let blocks = scenario.value
                    
                    blocks.forEach({ (block) in
                        self.appendBlock(block, courseId: courseId, sectionId: sectionId)
                    })
                }
            }
        }
    }

    func update() {
        clearBlocks()
        if !model.schedules.isEmpty {
            createCalendar(forSchedule: model.schedules[model.activeSchedule])
        }
        navView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.schedules.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NavCell", for: indexPath) as! NavCollectionViewCell
        cell.index.text = String(indexPath.row + 1)
        cell.setActive(indexPath.row == model.activeSchedule)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        model.activeSchedule = indexPath.row
    }
}
