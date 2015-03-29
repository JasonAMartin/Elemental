//
//  Elements.swift
//  Elemental
//
//  Created by Jason Martin on 3/29/15.
//  Copyright (c) 2015 uStoria LLC. All rights reserved.
//

import SpriteKit

class Element: Printable, Hashable {
    var column: Int
    var row: Int
    let elementType: ElementType
    var sprite: SKSpriteNode?
    
    init(column: Int, row: Int, elementType: ElementType) {
        self.column = column
        self.row = row
        self.elementType = elementType
    }
    
    var description: String {
        return "type:\(elementType) square:(\(column),\(row))"
    }
    
    var hashValue: Int {
        return row*10 + column
    }
}



enum ElementType: Int , Printable {
    case Unknown = 0, Fire, Ice, Wind, Earth, Void, Time, Lightning, Water
    
    var spriteName: String {
        let spriteNames = [
            "element-fire",
            "element-ice",
            "element-wind",
            "element-earth",
            "element-void",
            "element-time",
            "element-lightning",
            "element-water"
            ]
        
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    static func random() -> ElementType {
        return ElementType(rawValue: Int(arc4random_uniform(8)) + 1)!
    }
    
    var description: String {
        return spriteName
    }
}


func ==(lhs: Element, rhs: Element) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}