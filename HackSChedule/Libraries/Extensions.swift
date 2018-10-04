////
////  Extensions.swift
////  HackSChedule
////
////  Created by Andrew Jiang on 5/3/18.
////  Copyright © 2018 Andrew Jiang. All rights reserved.
////
//
//import Foundation
//enum DayType: String, Codable {
//    case mon = "M"
//    case tue = "T"
//    case wed = "W"
//    case thu = "H"
//    case fri = "F"
//    case unknown = "A"
//}
//
//struct Block: Codable {
//    let day: DayType
//    let start: Int?
//    let end: Int?
//    let location: String?
//    var transient: Bool
//
//    init (day: DayType, start: Int?, end: Int?, location: String?, transient: Bool) {
//        self.day = day
//        self.start = start
//        self.end = end
//        self.location = location
//        self.transient = transient
//    }
//
//    enum CodingKeys: String, CodingKey { // declaring our keys
//        case day = "day"
//        case start = "start"
//        case end = "end"
//        case location = "location"
//        case transient = "transient"
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self) // defining our (keyed) container
//        let day = try container.decode(DayType.self, forKey: .day)
//        let start = try container.decode(Int.self, forKey: .start)
//        let end = try container.decode(Int.self, forKey: .end)
//        let location = try container.decode(String.self, forKey: .location)
//        let transient = try container.decode(Bool.self, forKey: .transient)
//        self.init(day: day, start: start, end: end, location: location, transient: transient)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(day, forKey: .day)
//        try container.encode(start, forKey: .start)
//        try container.encode(end, forKey: .end)
//        try container.encode(location, forKey: .location)
//        try container.encode(transient, forKey: .transient)
//    }
//}
//
//struct Section: Codable {
//    let id: SectionId
//    let title: String
//    let description: String?
//    let type: SectionType
//    let units: String
//    let blocks: [Block]
//    let canceled: Bool
//    let isDistanceLearning: Bool
//    let instructor: Instructor
//    let numberRegistered: Int
//    let spacesAvailable: Int
//    let dclassCode: String?
//
//    init (id: SectionId, title: String, description: String?, type: SectionType, units: String, blocks: [Block], canceled: Bool, isDistanceLearning: Bool, instructor: Instructor, numberRegistered: Int, spacesAvailable: Int, dclassCode: String?) {
//        self.id = id
//        self.title = title
//        self.description = description
//        self.type = type
//        self.units = units
//        self.blocks = blocks
//        self.canceled = canceled
//        self.isDistanceLearning = isDistanceLearning
//        self.instructor = instructor
//        self.numberRegistered = numberRegistered
//        self.spacesAvailable = spacesAvailable
//        self.dclassCode = dclassCode
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case id = "id"
//        case title = "title"
//        case description = "description"
//        case type = "type"
//        case units = "units"
//        case blocks = "blocks"
//        case canceled = "canceled"
//        case isDistanceLearning = "isDistanceLearning"
//        case instructor = "instructor"
//        case numberRegistered = "numberRegistered"
//        case spacesAvailable = "spacesAvailable"
//        case dclassCode = "dclassCode"
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let id: SectionId = try container.decode(SectionId.self, forKey: .id)
//        let title: String = try container.decode(String.self, forKey: .title)
//        let description: String? = try container.decode(String.self, forKey: .description)
//        let type: SectionType = try container.decode(SectionType.self, forKey: .type)
//        let units: String = try container.decode(String.self, forKey: .units)
//        let blocks: [Block] = try container.decode([Block].self, forKey: .blocks)
//        let canceled: Bool = try container.decode(Bool.self, forKey: .canceled)
//        let isDistanceLearning: Bool = try container.decode(Bool.self, forKey: .isDistanceLearning)
//        let instructor: Instructor = try container.decode(Instructor.self, forKey: .instructor)
//        let numberRegistered: Int = try container.decode(Int.self, forKey: .numberRegistered)
//        let spacesAvailable: Int = try container.decode(Int.self, forKey: .spacesAvailable)
//        let dclassCode: String? = try container.decode(String.self, forKey: .dclassCode)
//        self.init(id: id, title: title, description: description, type: type, units: units, blocks: blocks, canceled: canceled, isDistanceLearning: isDistanceLearning, instructor: instructor, numberRegistered: numberRegistered, spacesAvailable: spacesAvailable, dclassCode: dclassCode)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(title, forKey: .title)
//        try container.encode(description, forKey: .description)
//        try container.encode(type, forKey: .type)
//        try container.encode(units, forKey: .units)
//        try container.encode(blocks, forKey: .blocks)
//        try container.encode(canceled, forKey: .canceled)
//        try container.encode(isDistanceLearning, forKey: .isDistanceLearning)
//        try container.encode(instructor, forKey: .instructor)
//        try container.encode(numberRegistered, forKey: .numberRegistered)
//        try container.encode(spacesAvailable, forKey: .spacesAvailable)
//        try container.encode(dclassCode, forKey: .dclassCode)
//    }
//}
//
//struct Course: Codable {
//    let id: CourseId
//    let description: String?
//    let isCrossListed: Bool
//    let title: String
//    let units: String
//    var sections: [SectionId: Section]
//
//    enum CodingKeys: String, CodingKey {
//        case id = "id"
//        case description = "description"
//        case isCrossListed = "isCrossListed"
//        case title = "title"
//        case units = "units"
//        case sections = "sections"
//    }
//}
//
//struct Instructor: Codable {
//    let firstName: String?
//    let lastName: String?
//
//    enum CodingKeys: String, CodingKey {
//        case firstName = "firstName"
//        case lastName = "lastName"
//    }
//}

