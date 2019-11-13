//
//  UnitsAndModes.swift
//  HW3-Solution
//
//  Created by Jonathan Engelsma on 9/7/18.
//  Copyright © 2018 Jonathan Engelsma. All rights reserved.
//

import Foundation

enum CalculatorMode : String {
    case Length
    case Volume
}
enum LengthUnit : String, CaseIterable {
    case Meters = "Meters"
    case Yards = "Yards"
    case Miles = "Miles"
}

enum VolumeUnit : String, CaseIterable {
    case Liters = "Liters"
    case Gallons = "Gallons"
    case Quarts = "Quarts"
}

struct LengthConversionKey : Hashable {
    var toUnits : LengthUnit
    var fromUnits : LengthUnit
}

// The following tables let you convert between units with a simple dictionary lookup. For example, assume
// that the variable fromVal holds the value you are converting from:
//
//      let convKey =  LengthConversionKey(toUnits: .Miles, fromUnits: .Meters)
//      let toVal = fromVal * lengthConversionTable[convKey]!;

let lengthConversionTable : Dictionary<LengthConversionKey, Double> = [
    LengthConversionKey(toUnits: .Meters, fromUnits: .Meters) : 1.0,
    LengthConversionKey(toUnits: .Meters, fromUnits: .Yards) : 0.9144,
    LengthConversionKey(toUnits: .Meters, fromUnits: .Miles) : 1609.34,
    LengthConversionKey(toUnits: .Yards, fromUnits: .Meters) : 1.09361,
    LengthConversionKey(toUnits: .Yards, fromUnits: .Yards) : 1.0,
    LengthConversionKey(toUnits: .Yards, fromUnits: .Miles) : 1760.0,
    LengthConversionKey(toUnits: .Miles, fromUnits: .Meters) : 0.000621371,
    LengthConversionKey(toUnits: .Miles, fromUnits: .Yards) : 0.000568182,
    LengthConversionKey(toUnits: .Miles, fromUnits: .Miles) : 1.0
]

struct VolumeConversionKey : Hashable {
    var toUnits : VolumeUnit
    var fromUnits : VolumeUnit
}

let volumeConversionTable : Dictionary<VolumeConversionKey, Double> = [
    VolumeConversionKey(toUnits: .Liters, fromUnits: .Liters) : 1.0,
    VolumeConversionKey(toUnits: .Liters, fromUnits: .Gallons) : 3.78541,
    VolumeConversionKey(toUnits: .Liters, fromUnits: .Quarts) : 0.946353,
    VolumeConversionKey(toUnits: .Gallons, fromUnits: .Liters) : 0.264172,
    VolumeConversionKey(toUnits: .Gallons, fromUnits: .Gallons) : 1.0,
    VolumeConversionKey(toUnits: .Gallons, fromUnits: .Quarts) : 0.25,
    VolumeConversionKey(toUnits: .Quarts, fromUnits: .Liters) : 1.05669,
    VolumeConversionKey(toUnits: .Quarts, fromUnits: .Gallons) : 4.0,
    VolumeConversionKey(toUnits: .Quarts, fromUnits: .Quarts) : 1.0
]

// To support Swift 4.2's iteration over enum... see 
// source: https://stackoverflow.com/questions/24007461/how-to-enumerate-an-enum-with-string-type
#if !swift(>=4.2)
public protocol CaseIterable {
    associatedtype AllCases: Collection where AllCases.Element == Self
    static var allCases: AllCases { get }
}
extension CaseIterable where Self: Hashable {
    static var allCases: [Self] {
        return [Self](AnySequence { () -> AnyIterator<Self> in
            var raw = 0
            var first: Self?
            return AnyIterator {
                let current = withUnsafeBytes(of: &raw) { $0.load(as: Self.self) }
                if raw == 0 {
                    first = current
                } else if current == first {
                    return nil
                }
                raw += 1
                return current
            }
        })
    }
}
#endif


