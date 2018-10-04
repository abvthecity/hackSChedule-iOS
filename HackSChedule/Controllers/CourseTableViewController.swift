//
//  CourseListViewController.swift
//  HackSChedule
//
//  Created by Andrew Jiang on 4/21/18.
//  Copyright © 2018 Andrew Jiang. All rights reserved.
//


import UIKit

class CourseTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CoursesModelObserver {
    static private var _shared: CourseTableViewController?
    private var removeCourseAlertController: UIAlertController!
    
    let model: CoursesModel = CoursesModel.shared
    
    var tableView: UITableView = UITableView()
    var id = CoursesModel.observerCounter
    
    static var shared: CourseTableViewController {
        get {
            if _shared == nil {
                _shared = CourseTableViewController()
            }
            return _shared!
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - viewcontroller view cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddCourse(sender:)))
        addButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = addButton

        self.loadAlertAction()
        self.loadTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (navigationController as! NavigationController).renderNavigationBar(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (navigationController as! NavigationController).renderNavigationBar(self)
        model.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        model.attachObserver(self)
    }
    
    // MARK: - ui helper methods
    
    private func loadAlertAction() {
        removeCourseAlertController = UIAlertController(title: "Edit XXX-###", message: nil, preferredStyle: .actionSheet)
        
        let  deleteButton = UIAlertAction(title: "Remove", style: .destructive, handler: { (action) -> Void in
            if let courseId = self.model.selectedCourse {
                self.model.removeCourse(courseId)
            }
            self.removeCourseAlertController.dismiss(animated: true)
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            self.removeCourseAlertController.dismiss(animated: true)
        })
        
        removeCourseAlertController.addAction(deleteButton)
        removeCourseAlertController.addAction(cancelButton)
    }
    
    private func loadTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CourseTableViewCell.self, forCellReuseIdentifier: CourseTableViewCell.reuseId)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 76
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let leftConstraint = NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: tableView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CourseTableViewCell = tableView.dequeueReusableCell(withIdentifier: CourseTableViewCell.reuseId) as! CourseTableViewCell
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        cell.addGestureRecognizer(longPressGesture)
        let course = model.courses[indexPath.row]
        cell.courseId.text = course.id
        cell.courseName.text = course.title
        cell.units.text = "\(course.units) units"
        cell.bgColor = Colors.list[indexPath.row % Colors.list.count]
        cell.types.text = Trojan.uniqueTypes(forSections: course.sections).joined(separator: ", ")
        
        UIView.animate(withDuration: cell.animationDuration) {
            cell.alpha = 1.0
        }
        return cell
    }
    
    // MARK: - other event handlers
    
    func update() {
        tableView.reloadData()
    }
    
    @objc func handleAddCourse(sender: UIBarButtonItem) {
        navigationController?.pushViewController(SearchTableViewController.shared, animated: true)
    }
    
    @objc func deviceRotated() {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            if !CalendarViewController.shared.isBeingPresented {
                present(CalendarViewController.shared, animated: true, completion: nil)
            }
        }
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if let index = tableView.indexPath(for: sender.view as! UITableViewCell)?.row {
                let course = model.courses[index]
                model.selectedCourse = course.id
                removeCourseAlertController.title = "Edit \(course.id)"
                self.navigationController?.present(removeCourseAlertController, animated: true)
            }
        } else if sender.state == .failed {
            model.selectedCourse = nil
            if removeCourseAlertController.isViewLoaded || removeCourseAlertController.isBeingPresented {
                removeCourseAlertController.dismiss(animated: true)
            }
        }
    }

}
