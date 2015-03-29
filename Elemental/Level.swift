//
//  Level.swift
//  Elemental
//
//  Created by Jason Martin on 3/29/15.
//  Copyright (c) 2015 uStoria LLC. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9

class Level {
    private var elements = Array2D<Element>(columns: NumColumns, rows: NumRows)
    
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    
    
    
    init(filename: String) {
        // 1
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            // 2
            if let tilesArray: AnyObject = dictionary["tiles"] {
                // 3
                for (row, rowArray) in enumerate(tilesArray as [[Int]]) {
                    // 4
                    let tileRow = NumRows - row - 1
                    // 5
                    for (column, value) in enumerate(rowArray) {
                        if value == 1 {
                            tiles[column, tileRow] = Tile()
                        }
                    }
                }
            }
        }
    }
    
    
    
    func elementAtColumn(column: Int, row: Int) -> Element? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return elements[column, row]
    }

    func shuffle() -> Set<Element> {
        return createInitialElements()
    }
    
    private func createInitialElements() -> Set<Element> {
        var set = Set<Element>()
        
        // 1
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                if tiles[column, row] != nil {
                    // 2
                    var elementType = ElementType.random()
                
                    // 3
                    let element = Element(column: column, row: row, elementType: elementType)
                        elements[column, row] = element
                
                    // 4
                    set.addElement(element)
                }
            }
        }
        return set
    }
    
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
}