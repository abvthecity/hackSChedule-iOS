//
//  Combinator.swift
//  HackSChedule
//
//  Created by Andrew Jiang on 5/3/18.
//  Copyright © 2018 Andrew Jiang. All rights reserved.
//

import Foundation

class Combinator {
    static func createSchedulerScenarioFromSections(_ sectionsDict: [SectionId: Section], using sectionIds: [SectionId]) -> Scenario {
        var scenario = Scenario()
        
        for id in sectionIds {
            let section = sectionsDict[id]!
            scenario.updateValue(section.blocks, forKey: id) // blockId
        }
        
        return scenario
    }
    
    static func createSchedulerEntityFromCourse(_ course: Course) -> Entity {
        let trojan = Trojan.create(withSections: course.sections)
        return trojan.results.reduce(into: Entity(), { (result, sectionIds) in
            let scenario = createSchedulerScenarioFromSections(course.sections, using: sectionIds)
            result.updateValue(scenario, forKey: String(result.count)) // scenarioId
        })
    }
    
    static func convertSchedulerCorpusFromCourses(_ coursesDict: [CourseId: Course]) -> [EntityId: Entity] {
        return coursesDict.keys.reduce(into: [EntityId: Entity]()) { (result, courseId) in
            result.updateValue(createSchedulerEntityFromCourse(coursesDict[courseId]!), forKey: courseId) // entitId
        }
    }
}
