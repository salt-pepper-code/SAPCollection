//
//  DrawStats.swift
//  SAPCollection
//
//  Created by Kevin Malkic on 20/03/2019.
//  Copyright © 2019 Salt and Pepper Code. All rights reserved.
//

import Foundation

class DrawStats {
    static let shared = DrawStats()
    var fromTime = Date().timeIntervalSince1970
    
    var total: TimeInterval = 0
    var maxTime: TimeInterval = 0
    var count: Int = 0
    var last: TimeInterval = 0
    func add(_ time: TimeInterval) {
        total += time
        maxTime = max(time, maxTime)
        last = time
        count += 1
    }
    var average: TimeInterval {
        return total / TimeInterval(count)
    }
    func reset() {
        total = 0
        maxTime = 0
        last = 0
        count = 0
    }
    func markStartTime() {
        fromTime = Date().timeIntervalSince1970
    }
    @discardableResult func markEndAndPrintStat() -> TimeInterval {
        let diff = Date().timeIntervalSince1970 - fromTime
        add(diff)
        print("average: \(average) - last: \(last) - max: \(maxTime) - fps: \(1 / last)")
        return diff
    }
}
