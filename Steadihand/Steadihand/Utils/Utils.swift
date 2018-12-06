//
//  Utils.swift
//  Steadihand
//
//  Created by Danny Luong on 12/6/18.
//  Copyright © 2018 dnylng. All rights reserved.
//

import Foundation

class Utils {
    
    static func nearestHundreth(_ num: Double) -> Double {
        return round(100.0 * num) / 100.0
    }
    
    static func lowPassFilter(input: [Double], output: [Double], alpha: Double) -> [Double] {
        var result = output
        for i in 0..<input.count {
            result[i] = output[i] + alpha * (input[i] - output[i])
        }
        return result
    }
    
    static func filteredAcceleration(acceleration: [Double], x: Double, y: Double) -> [Double] {
        if acceleration.count != 2 { return acceleration }
        let accelerationRange = -Constants.MAX_ACC...Constants.MAX_ACC
        let filteredX = accelerationRange.contains(x) ? x : acceleration[0]
        let filteredY = accelerationRange.contains(y) ? y : acceleration[1]
        return [filteredX, filteredY]
    }
    
    static func rangeValue(value: Double, min: Double, max: Double) -> Double {
        if value > max { return max }
        if value < min { return min }
        return value
    }
    
    static func fixNanOrInfinite(value: Double) -> Double {
        return (value.isNaN || value.isInfinite) ? 0 : value
    }
    
}
