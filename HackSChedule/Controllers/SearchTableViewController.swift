//
//  SearchTableViewController.swift
//  HackSChedule
//
//  Created by Andrew Jiang on 5/2/18.
//  Copyright © 2018 Andrew Jiang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

extension UISearchBar {
    
    public var textField: UITextField? {
        let subViews = subviews.flatMap { $0.subviews }
        guard let textField = (subViews.filter { $0 is UITextField }).first as? UITextField else {
            return nil
        }
        return textField
    }
    
    public var activityIndicator: UIActivityIndicatorView? {
        return textField?.leftView?.subviews.compactMap{ $0 as? UIActivityIndicatorView }.first
    }
    
    var isLoading: Bool {
        get {
            return activityIndicator != nil
        } set {
            if newValue {
                if activityIndicator == nil {
                    let newActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    newActivityIndicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    newActivityIndicator.startAnimating()
                    newActivityIndicator.backgroundColor = UIColor.white
                    textField?.leftView?.addSubview(newActivityIndicator)
                    let leftViewSize = textField?.leftView?.frame.size ?? CGSize.zero
                    newActivityIndicator.center = CGPoint(x: leftViewSize.width/2, y: leftViewSize.height/2)
                }
            } else {
                activityIndicator?.removeFromSuperview()
            }
        }
    }
}

extension String {
    func equalityScore(with string: String) -> Double {
        if self == string {
            return 2     // the greatest equality score this method can give
        } else if self.contains(string) {
            return 1 + 1 / Double(self.count - string.count)   // contains our term, so the score will be between 1 and 2, depending on number of letters.
        } else {
            // you could of course have other criteria, like string.contains(self)
            return 1 / Double(abs(self.count - string.count))
        }
    }
}

class SearchTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    static private var _shared: SearchTableViewController?
    static var shared: SearchTableViewController {
        get {
            if _shared == nil {
                _shared = SearchTableViewController()
            }
            return _shared!
        }
    }
    
    let reuseId = "SearchTableViewCell"
    
    let searchController = UISearchController(searchResultsController: nil)
    let model = CoursesModel.shared
    var ref: DatabaseReference!
    
    var currentSearchQuery: String = ""
    var searchResults: [CourseId] = []
    var searchResultsDict: [CourseId: Course] = [:]
    var alreadySearchedQueries: Set<String> = Set<String>()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "i.e. CSCI104, BAEP-401, SOCI 200, etc."
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.tintColor = Colors.darkRed
        navigationItem.titleView = searchController.searchBar
        navigationItem.hidesBackButton = true
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (navigationController as! NavigationController).renderNavigationBar(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    
        
        searchController.isActive = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (navigationController as! NavigationController).renderNavigationBar(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.popViewController(animated: true)
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let query: String = CourseIdHelper.parse(searchController.searchBar.text ?? "").courseId
        
        if query == currentSearchQuery {
            return
        } else {
            currentSearchQuery = query
        }
        self.updateSearchResults()
        
        DispatchQueue.main.async {
            let prefixedQuery = String(query.prefix(4))
            if !self.alreadySearchedQueries.contains(prefixedQuery) {
                self.alreadySearchedQueries.insert(prefixedQuery)
                
                let queryRef = self.ref.child("\(Trojan.term)_courses").queryOrderedByKey().queryStarting(atValue: prefixedQuery)
                
                self.searchController.searchBar.isLoading = true
                
                queryRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
                    if snapshot.hasChildren() {
                        let results = snapshot.children.map({ (item) -> Course in
                            let result = item as! DataSnapshot
                            let courseId: String = result.childSnapshot(forPath: "courseId").value as? String ?? ""
                            let description: String? = result.childSnapshot(forPath: "description").value as? String
                            let isCrossListed: Bool = result.childSnapshot(forPath: "isCrossListed").value as! Bool
                            let title: String = result.childSnapshot(forPath: "title").value as! String
                            let units: String = result.childSnapshot(forPath: "units").value as! String
                            
                            return Course(id: courseId, description: description, isCrossListed: isCrossListed, title: title, units: units, sections: [:])
                        })
                        self.searchResultsDict.merge(Trojan.reduceArrayToDict(forCourses: results), uniquingKeysWith: { (current, _) in current })
                        self.updateSearchResults()
                    }
                    self.searchController.searchBar.isLoading = false
                }
            }
        }
    }
    
    func updateSearchResults() {
        self.searchResults = self.searchResultsDict.keys.filter({ (key) -> Bool in
            key.hasPrefix(self.currentSearchQuery)
        }).sorted()
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(searchResults.count, 50)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: reuseId)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseId)
        }
        
        let resultItem: Course = searchResultsDict[searchResults[indexPath.row]]!

        cell!.textLabel?.text = resultItem.id
        cell!.detailTextLabel?.text = "\(resultItem.title), \(resultItem.units) units"
        cell!.accessoryType = .disclosureIndicator

        return cell!
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = self.searchResultsDict[searchResults[indexPath.row]]!
        model.addCourse(course)
        navigationController?.popViewController(animated: true)
    }
    
}
