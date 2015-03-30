//
//  Swap.swift
//  Elemental
//
//  Created by Jason Martin on 3/30/15.
//  Copyright (c) 2015 uStoria LLC. All rights reserved.
//

struct Swap: Printable, Hashable {
    let elementA: Element
    let elementB: Element
    
    init(elementA: Element, elementB: Element) {
        self.elementA = elementA
        self.elementB = elementB
    }
    
    var description: String {
        return "swap \(elementA) with \(elementB)"
    }
    
    var hashValue: Int {
        return elementA.hashValue ^ elementB.hashValue
    }
}

func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.elementA == rhs.elementA && lhs.elementB == rhs.elementB) ||
        (lhs.elementB == rhs.elementA && lhs.elementA == rhs.elementB)
}