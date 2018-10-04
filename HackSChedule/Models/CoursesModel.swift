//
//  CoursesModel.swift
//  HackSChedule
//
//  Created by Andrew Jiang on 5/2/18.
//  Copyright © 2018 Andrew Jiang. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

protocol CoursesModelObserver {
    var id: Int { get }
    func update()
}

class CoursesModel {
    
    static let kCoursesPlist: String! = "Courses.plist"
    private let filePath: URL
    private let encoder: PropertyListEncoder
    private let decoder: PropertyListDecoder
    
    static private var _shared: CoursesModel?
    static var shared: CoursesModel {
        get {
            if _shared == nil {
                _shared = CoursesModel()
            }
            return _shared!
        }
    }
    static private var _observerCounter: Int = 0
    static var observerCounter: Int {
        get {
            let count = _observerCounter
            _observerCounter += 1
            return count
        }
    }
    var ref: DatabaseReference!
    
    private var _selectedCourse: CourseId?
    var selectedCourse: CourseId? {
        get {
            guard self.courses.index(where: { $0.id == self._selectedCourse }) != nil else {
                self._selectedCourse = nil
                return nil
            }
            return self._selectedCourse
        }
        set {
            if self.courses.index(where: { $0.id == newValue }) != nil {
                self._selectedCourse = newValue
            } else {
                self._selectedCourse = nil
            }
        }
    }
    
    private(set) var courses: [Course] = []
    private(set) var corpus: [EntityId: Entity] = [:]
    private(set) var schedules: [Combination] = []
    private var _activeSchedule: Int = 0
    var activeSchedule: Int {
        get {
            if !schedules.isEmpty {
                if _activeSchedule < 0 {
                    _activeSchedule = 0
                } else if _activeSchedule >= schedules.count {
                    _activeSchedule = schedules.count - 1
                }
            } else {
                _activeSchedule = 0
            }
            return _activeSchedule
        }
        set {
            if !schedules.isEmpty {
                if newValue < 0 {
                    _activeSchedule = 0
                } else if newValue >= schedules.count {
                    _activeSchedule = schedules.count - 1
                } else {
                    _activeSchedule = newValue
                }
            } else {
                _activeSchedule = 0
            }
            notify()
        }
    }
    
    private var observers: [CoursesModelObserver] = []
    
    init() {
        ref = Database.database().reference()
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        filePath = dir.appendingPathComponent(CoursesModel.kCoursesPlist)
        
        encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        decoder = PropertyListDecoder()
        
        do {
            let data = try Data(contentsOf: filePath)
            courses = try decoder.decode([Course].self, from: data)
            self.generateSchedules()
        } catch {
            print(error)
        }
    }
    
    func saveToMemory() {
        do {
            let data = try encoder.encode(courses)
            try data.write(to: filePath)
        } catch {
            print(error)
        }
    }
    
    private func extractBlocks(_ blocksSnap: DataSnapshot) -> [Block] {
        return blocksSnap.children.map({ (blockItem) -> Block in
            let result = blockItem as! DataSnapshot
            let day: DayType = Block.convertTo(dayType: result.childSnapshot(forPath: "day").value as? String)
            let location: String? = result.childSnapshot(forPath: "location").value as? String
            let start: Int? = Block.convertTo(minutes: result.childSnapshot(forPath: "start").value as? String)
            let end: Int? = Block.convertTo(minutes: result.childSnapshot(forPath: "end").value as? String)
            return Block(day: day, start: start, end: end, location: location, transient: false)
        })
    }
    
    private func extractSections(_ sectionsSnap: DataSnapshot) -> [Section] {
        return sectionsSnap.children.map({ (item) -> Section in
            let result = item as! DataSnapshot
            let instructorFirstName = result.childSnapshot(forPath: "instructor/first_name").value as? String
            let instructorLastName = result.childSnapshot(forPath: "instructor/last_name").value as? String
            
            let sectionId: String = result.key
            let title: String = result.childSnapshot(forPath: "title").value as! String
            let description: String? = result.childSnapshot(forPath: "description").value as? String
            let type: String = result.childSnapshot(forPath: "type").value as! String
            let units: String = result.childSnapshot(forPath: "units").value as! String
            let blocks: [Block] = self.extractBlocks(result.childSnapshot(forPath: "blocks"))
            let canceled: Bool = result.childSnapshot(forPath: "canceled").value as! Bool
            let isDistanceLearning: Bool = result.childSnapshot(forPath: "IsDistanceLearning").value as! Bool
            let instructor: Instructor = Instructor(firstName: instructorFirstName, lastName: instructorLastName)
            let numberRegistered: Int = Int(result.childSnapshot(forPath: "number_registered").value as! String)!
            let spacesAvailable: Int = Int(result.childSnapshot(forPath: "spaces_available").value as! String)!
            let dclassCode: String? = result.childSnapshot(forPath: "dclass_code").value as? String
            return Section(id: sectionId, title: title, description: description, type: type, units: units, blocks: blocks, canceled: canceled, isDistanceLearning: isDistanceLearning, instructor: instructor, numberRegistered: numberRegistered, spacesAvailable: spacesAvailable, dclassCode: dclassCode)
        })
    }
    
    func addCourse(_ course: Course) {
        let queryRef = ref.child("\(Trojan.term)_sections/\(course.id)")
        
        // insert
        self.courses.append(course)
        self.notify()
        
        // asynchronously download section data
        queryRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if snapshot.hasChildren() {
                let sections = self.extractSections(snapshot)
                if let i = self.courses.index(where: { course.id == $0.id }) {
                    self.courses[i].sections = Trojan.reduceArrayToDict(forSections: sections)
                }
            }
            self.notify()
            self.generateSchedules()
        }
    }
    
    func removeCourse(_ id: CourseId) {
        if let index = self.courses.index(where: { $0.id == id }) {
            self.courses.remove(at: index)
            self.notify()
            self.generateSchedules()
        }
    }
    
    func generateSchedules() {
        let coursesDict = Trojan.reduceArrayToDict(forCourses: courses)
        corpus = Combinator.convertSchedulerCorpusFromCourses(coursesDict)
        schedules = Scheduler.generate(corpus: corpus)
        print("COMBINATIONS: \(schedules.count)")
        self.notify()
    }
    
    func attachObserver(_ observer: CoursesModelObserver) {
        observers.append(observer)
    }
    
    func removeObserver(_ observer: CoursesModelObserver) {
        if let index = observers.index(where: { (obs: CoursesModelObserver) -> Bool in
            return observer.id == obs.id
        }) {
            observers.remove(at: index)
        }
    }
    
    private func notify(){
        for observer in observers {
            observer.update()
        }
        self.saveToMemory()
    }
}
