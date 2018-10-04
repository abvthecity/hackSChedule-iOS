//
//  Trojan.swift
//  HackSChedule
//
//  Created by Andrew Jiang on 5/2/18.
//  Copyright © 2018 Andrew Jiang. All rights reserved.
//

import Foundation

typealias CourseId = String
typealias SectionId = String
typealias SectionType = String
typealias Bucket = [SectionType: [SectionId]]

enum DayType: String, Codable {
    case mon = "M"
    case tue = "T"
    case wed = "W"
    case thu = "H"
    case fri = "F"
    case unknown = "A"
}

struct Block: Codable {
    let day: DayType
    let start: Int?
    let end: Int?
    let location: String?
    var transient: Bool
}

struct Section: Codable {
    let id: SectionId
    let title: String
    let description: String?
    let type: SectionType
    let units: String
    let blocks: [Block]
    let canceled: Bool
    let isDistanceLearning: Bool
    let instructor: Instructor
    let numberRegistered: Int
    let spacesAvailable: Int
    let dclassCode: String?
}

struct Course: Codable {
    let id: CourseId
    let description: String?
    let isCrossListed: Bool
    let title: String
    let units: String
    var sections: [SectionId: Section]
}

struct Instructor: Codable {
    let firstName: String?
    let lastName: String?
}

extension Conflict {
    static func existsFor(sections sectionA: Section, _ sectionB: Section) -> Bool {
        for a in sectionA.blocks {
            for b in sectionB.blocks {
                if Conflict.existsFor(blocks: a, b) {
                    return true
                }
            }
        }
        return false
    }
}

class Trojan {
    static let term = "20183"
    
    static let immediatelyRegExp = try? NSRegularExpression(pattern: "immediately", options: .caseInsensitive)
    
    static func create(withSections sectionsDict: [SectionId: Section]) -> Trojan {
        let generator = Trojan(sectionsDict: sectionsDict)
        generator.makeBuckets()
        generator.makeCombinations()
        return generator
    }
    
    static func convertTerm(from id: String) -> String {
        let year = id.prefix(4)
        let modifier = id.suffix(1)
        if modifier == "1" {
            return "Spring \(year)"
        } else if modifier == "2" {
            return "Summer \(year)"
        } else {
            return "Fall \(year)"
        }
    }
    
    static func reduceArrayToDict(forCourses courses: [Course]) -> [CourseId: Course] {
        return courses.reduce(into: [CourseId: Course]()) { (result, course) in
            result.updateValue(course, forKey: course.id)
        }
    }
    
    static func reduceArrayToDict(forSections sections: [Section]) -> [SectionId: Section] {
        return sections.reduce(into: [SectionId: Section]()) { (result, section) in
            result.updateValue(section, forKey: section.id)
        }
    }
    
    let sections: [Section]
    let sectionsDict: [SectionId: Section]
    let orderedSectionId: [SectionId]
    private(set) var buckets: [Bucket] = []
    private(set) var results: [[SectionId]] = []
    
    private init(sectionsDict: [SectionId: Section]) {
        self.sections = sectionsDict.map({ $1 })
        self.orderedSectionId = Trojan.getOrdered(sections: sections)
        self.sectionsDict = sectionsDict
    }
    
    private func makeCombinations() {
        results = []
        
        guard !orderedSectionId.isEmpty else {
            return
        }
        
        for bucket in buckets {
            var queue: [[SectionId]] = [[]]
            var left: Int = 0 // to remove from queue
            
            var bucketKeys = Array(bucket.keys) // unique section types
            let goalSize = bucketKeys.count
            var currSize: Int = 0
            
            while currSize < goalSize {
                let queueLength = queue.count // make copy of queue length
                for i in left..<queueLength {
                    let type: SectionType = bucketKeys[currSize]
                    
                    for j in 0..<bucket[type]!.count {
                        var temp: [SectionId] = queue[i]
                        // check conflicts
                        let sA: Section = sectionsDict[bucket[type]![j]]!
                        let isConflicting = temp.contains(where: { Conflict.existsFor(sections: sA, sectionsDict[$0]!) })
                        
                        if !isConflicting {
                            temp.append(sA.id)
                            queue.append(temp)
                        }
                    }
                    
                    left += 1
                }
                
                currSize += 1
            }
            
            queue.removeFirst(left)
            results.append(contentsOf: queue)
        }
    }
    
    /// makeBuckets() restructures list of sections into "buckets".
    /// Buckets represent each separate set of sections which we want to analyze.
    /// In most cases, having multiple buckets won't matter. But for the unlucky
    /// few esp. ones that say: "choose 1 lec and 1 lab directly underneath",
    /// we need to identify all the different "buckets" so that we don't return
    /// course combinations that don't work in actuality.
    private func makeBuckets() {
        buckets = []
        
        guard !orderedSectionId.isEmpty else {
            return
        }
        
        let orderIsImportant = Trojan.checkOrderIsImportant(forSections: sectionsDict, orderedBy: orderedSectionId)
        var quiz: [SectionId] = [] // quiz sections apply to all buckets
        var den: Bucket = Bucket() // distance learning bucket (cannot be mixed with other sections)
        
        // for every section, insert a bucket into an array of sections with the same label.
        // this groups all Lecs together, or all Labs together
        
        var bucket: Bucket = Bucket()
        let firstSection = sectionsDict[orderedSectionId[0]]!
        for id in orderedSectionId {
            let section = sectionsDict[id]!
            
            if !bucket.isEmpty && orderIsImportant && firstSection.type == section.type {
                buckets.append(bucket)
                bucket = Bucket()
            }
            
            if !bucket.isEmpty && Trojan.checkIsCombinedType(section.type) {
                buckets.append(bucket)
                bucket = Bucket()
            }
            
            if section.isDistanceLearning || section.blocks[0].location == "DEN@Viterbi" {
                den[section.type] = den[section.type] ?? []
                den[section.type]?.append(section.id)
                continue
            }
            
            if Trojan.checkIsQuizType(section.type) {
                quiz.append(section.id)
                continue
            }
            
            bucket[section.type] = bucket[section.type] ?? []
            bucket[section.type]!.append(section.id)
        }
        
        // reconciliation
        if !bucket.isEmpty {
            buckets.append(bucket)
        }
        
        if !den.isEmpty {
            buckets.append(den)
        }
        
        if !quiz.isEmpty {
            buckets = buckets.map({ (b) -> Bucket in
                var bucket = b
                bucket.updateValue(quiz, forKey: "Qz")
                return bucket
            })
        }
    }
    
    /// quickly determine if a course has rigid or random section-choosing structure
    /// true: order does matter
    /// false: order does not matter
    static func checkOrderIsImportant(forSections sectionsDict: [SectionId: Section], orderedBy order: [SectionId]) -> Bool {
        guard order.count > 1 && sectionsDict[order[0]]?.type == sectionsDict[order[1]]?.type else {
            for id in order {
                if let desc = sectionsDict[id]?.description, let matchesCount = immediatelyRegExp?.numberOfMatches(in: desc, range: NSMakeRange(0, desc.count)) {
                    if matchesCount > 0 {
                        return true
                    }
                }
            }
            return false
        }
        return false
    }
    
    /// gets the section ID array in sorted order
    static func getOrdered(sections: [Section]) -> [SectionId] {
        // sort using dclass_code
        let sectionKeys: [SectionId] = sections.map { $0.id }.sorted()
        return sectionKeys
    }
    
    static func getSection(from sections: [Section], with id: SectionId) -> Section? {
        if let i = sections.index(where: { $0.id == id }) {
            return sections[i]
        }
        return nil
    }
    
    // HELPER
    
    static func uniqueTypes(forSections sectionsDict: [SectionId: Section]) -> [SectionType] {
        let types = sectionsDict.values.map{ $0.type }
        return Array(Set(types))
    }
    
    static func checkIsCombinedType(_ type: SectionType) -> Bool {
        if type.index(of: "-") != nil {
            return true
        }
        return false
    }
    
    static func checkIsQuizType(_ type: SectionType) -> Bool {
        return type == "Qz"
    }
}

extension Block {
    static func convertTo(dayType day: String?) -> DayType {
        if day == nil {
            return .unknown
        }
        
        switch day! {
        case "M":
            return .mon
        case "T":
            return .tue
        case "W":
            return .wed
        case "H":
            return .thu
        case "F":
            return .fri
        default:
            return .unknown
        }
    }
    
    static func convertFrom(dayType day: DayType) -> String? {
        switch day {
        case .mon:
            return "M"
        case .tue:
            return "T"
        case .wed:
            return "W"
        case .thu:
            return "H"
        case .fri:
            return "F"
        default:
            return nil
        }
    }
    
    static func convertTo(minutes time: String?) -> Int? {
        if let timeArray: [Substring] = time?.split(separator: ":") {
            let hours = Int(timeArray[0]) ?? 0
            let minutes = Int(timeArray[1]) ?? 0
            return hours * 60 + minutes
        }
        return nil
    }
    
    static func convertFrom(minutes: Int?) -> String? {
        if minutes == nil {
            return nil
        }
        
        
        let hour: String = {
            let hr = (minutes! / 60) % 12
            if hr == 0 {
                return String(12)
            }
            return String(hr)
        }()
        let min: String? = {
            let min = minutes! % 60
            if min == 0 {
                return nil
            } else if min >= 10 {
                return String(min)
            }
            return "0\(min)"
        }()
        
        let ap = (minutes! / 60 >= 12) ? "p" : "a"
        
        return min == nil ? "\(hour)\(ap)" : "\(hour):\(min!)\(ap)"
    }
}

struct CourseIdHelper {
    let dept: String
    let num: String
    let seq: String
    let courseId: CourseId
    
    private static let deptRegExp = try? NSRegularExpression(pattern: "^[a-z]+", options: .caseInsensitive)
    private static let numRegExp = try? NSRegularExpression(pattern: "[0-9]+", options: .caseInsensitive)
    private static let seqRegExp = try? NSRegularExpression(pattern: "[a-z]$", options: .caseInsensitive)
    
    private static func getDept(_ query: String) -> String {
        if let match = deptRegExp?.firstMatch(in: query, options: [], range: NSMakeRange(0, query.count)) {
            return String(query[Range(match.range, in: query)!]).uppercased()
        }
        return ""
    }
    
    private static func getNum(_ query: String) -> String {
        if let match = numRegExp?.firstMatch(in: query, options: [], range: NSMakeRange(0, query.count)) {
            return String(query[Range(match.range, in: query)!]).uppercased()
        }
        return ""
    }
    
    private static func getSeq(_ query: String) -> String {
        if let match = seqRegExp?.firstMatch(in: query, options: [], range: NSMakeRange(0, query.count)) {
            return String(query[Range(match.range, in: query)!]).uppercased()
        }
        return ""
    }
    
    static func parse(_ courseId: String) -> CourseIdHelper {
        let dept = getDept(courseId)
        let num = getNum(courseId)
        let seq = getSeq(courseId)
        let courseId = { () -> String in
            if num.count > 0 {
                return "\(dept)-\(num)"
            }
            return dept
        }()
        
        return CourseIdHelper(dept: dept, num: num, seq: seq, courseId: courseId)
    }
}
