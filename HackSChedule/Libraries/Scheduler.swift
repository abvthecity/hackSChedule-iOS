//
//  SchedulerAPI.swift
//  HackSChedule
//
//  Created by Andrew Jiang on 5/3/18.
//  Copyright © 2018 Andrew Jiang. All rights reserved.
//

import Foundation

typealias EntityId = String
typealias ScenarioId = String
typealias BlockId = String
typealias Scenario = [BlockId: [Block]]
typealias Entity = [ScenarioId: Scenario]
typealias Combination = [EntityId: ScenarioId]

class Scheduler {
    static func generate(corpus: [EntityId: Entity] = [:], callback: ((Combination) -> Void)? = nil, completion: (([Combination]) -> Void)? = nil) -> [Combination] {
        var output: [Combination] = []
        
        let scheduler = Scheduler(corpus: corpus)
        scheduler.backtrace(callback: { (combination: Combination) in
            output.append(combination)
            callback?(combination)
        }) {
            completion?(output)
        }
        
        return output
    }
    
    var heap: Combination
    var corpus: [EntityId: Entity]
    var corpusKeys: [EntityId]
    
    private init(corpus: [EntityId: Entity]) {
        self.corpus = corpus
        self.corpusKeys = corpus.keys.map{ $0 }
        self.heap = Combination()
    }
    
    /* BACKTRACKING ALGORITHM:
     funcion bt() {
     if end, send to output.
     else...
     entity = get next entity
     for each course scenario
     {
     add() scenario to current heap
     if add doesn't work, skip to the next scenario
     if add works, backtrace to next layer.
     bt()
     remove() scenario from current heap
     }
     } */
    private func backtrace(index: Int = 0, callback: (Combination) -> Void, completion: (() -> Void)? = nil) {
        if corpus.count == index {
            // we are at the end of stack
            callback(heap)
            return;
        }
        
        let entityKey: String = corpusKeys[index]
        
        for entity in corpus[entityKey]! {
            if !add(entityKey: entityKey, scenarioKey: entity.key) {
                continue
            }
            backtrace(index: index + 1, callback: callback)
            remove(entityKey: entityKey)
        }
        
        completion?()
    }
    
    private func add(entityKey: EntityId, scenarioKey: ScenarioId) -> Bool {
        let scenarioA: Scenario = corpus[entityKey]![scenarioKey]!
        
        for entity in heap {
            let scenarioB: Scenario = corpus[entity.key]![heap[entity.key]!]!
            
            if Conflict.existsFor(scenarios: scenarioA, scenarioB) {
                return false
            }
        }
        
        heap[entityKey] = scenarioKey
        return true;
    }
    
    private func remove(entityKey: CourseId) {
        let i = heap.index{ $0.key == entityKey }!
        heap.remove(at: i)
    }
}

class Conflict {
    static func existsFor(scenarios scenarioA: Scenario, _ scenarioB: Scenario) -> Bool {
        return scenarioA.contains{ a in scenarioB.contains{ b in Conflict.existsFor(blocksArray: a.value, b.value)}}
    }
    
    static func existsFor(blocksArray blocksArrayA: [Block], _ blocksArrayB: [Block]) -> Bool {
        return blocksArrayA.contains{ a in blocksArrayB.contains{ b in Conflict.existsFor(blocks: a, b)}}
    }
    
    static func existsFor(blocks blockA: Block, _ blockB: Block) -> Bool {
        let isDayConflict = existsForDays(dayA: blockA.day, dayB: blockB.day)
        let isTimesConflict = existsForTimes(startA: blockA.start, endA: blockA.end, startB: blockB.start, endB: blockB.end)
        return isDayConflict && isTimesConflict
    }
    
    static private func existsForDays(dayA: DayType, dayB: DayType) -> Bool {
        if dayA == .unknown || dayB == .unknown {
            return false
        }
        return dayA == dayB
    }
    
    static private func existsForTimes(startA: Int?, endA: Int?, startB: Int?, endB: Int?) -> Bool {
        if let a = startA, let a2 = endA, let b = startB, let b2 = endB {
            if a == b {
                return true
            }
            
            if a < b {
                return a2 > b
            }
            
            if b < a {
                return b2 > a
            }
        }
        return false
    }
}
