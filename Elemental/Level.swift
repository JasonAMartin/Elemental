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
    private var possibleSwaps = Set<Swap>()
    
    
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
        var set: Set<Element>
        do {
            set = createInitialElements()
            detectPossibleSwaps()
            println("possible swaps: \(possibleSwaps)")
        }
            while possibleSwaps.count == 0
        
        return set
    }
    
    private func createInitialElements() -> Set<Element> {
        var set = Set<Element>()
        
        // 1
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                if tiles[column, row] != nil {
                    // 2
                    var elementType: ElementType
                    do {
                        elementType = ElementType.random()
                    }
                        while (column >= 2 &&
                            elements[column - 1, row]?.elementType == elementType &&
                            elements[column - 2, row]?.elementType == elementType)
                            || (row >= 2 &&
                                elements[column, row - 1]?.elementType == elementType &&
                                elements[column, row - 2]?.elementType == elementType)
                    
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
    
    func performSwap(swap: Swap) {
        let columnA = swap.elementA.column
        let rowA = swap.elementA.row
        let columnB = swap.elementB.column
        let rowB = swap.elementB.row
        
        elements[columnA, rowA] = swap.elementB
        swap.elementB.column = columnA
        swap.elementB.row = rowA
        
        elements[columnB, rowB] = swap.elementA
        swap.elementA.column = columnB
        swap.elementA.row = rowB
    }
    
    private func hasChainAtColumn(column: Int, row: Int) -> Bool {
        let elementType = elements[column, row]!.elementType
        
        var horzLength = 1
        for var i = column - 1; i >= 0 && elements[i, row]?.elementType == elementType;
            --i, ++horzLength { }
        for var i = column + 1; i < NumColumns && elements[i, row]?.elementType == elementType;
            ++i, ++horzLength { }
        if horzLength >= 3 { return true }
        
        var vertLength = 1
        for var i = row - 1; i >= 0 && elements[column, i]?.elementType == elementType;
            --i, ++vertLength { }
        for var i = row + 1; i < NumRows && elements[column, i]?.elementType == elementType;
            ++i, ++vertLength { }
        return vertLength >= 3
    }
    
    func detectPossibleSwaps() {
        var set = Set<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let element = elements[column, row] {
                    
                    if column < NumColumns - 1 {
                        // Have a element in this spot? If there is no tile, there is no element.
                        if let other = elements[column + 1, row] {
                            // Swap them
                            elements[column, row] = other
                            elements[column + 1, row] = element
                            
                            // Is either cookie now part of a chain?
                            if hasChainAtColumn(column + 1, row: row) ||
                                hasChainAtColumn(column, row: row) {
                                    set.addElement(Swap(elementA: element, elementB: other))
                            }
                            
                            // Swap them back
                            elements[column, row] = element
                            elements[column + 1, row] = other
                        }
                    }
                    
                    if row < NumRows - 1 {
                        if let other = elements[column, row + 1] {
                            elements[column, row] = other
                            elements[column, row + 1] = element
                            
                            // Is either cookie now part of a chain?
                            if hasChainAtColumn(column, row: row + 1) ||
                                hasChainAtColumn(column, row: row) {
                                    set.addElement(Swap(elementA: element, elementB: other))
                            }
                            
                            // Swap them back
                            elements[column, row] = element
                            elements[column, row + 1] = other
                        }
                    }
                    
                    
                }
            }
        }
        
        possibleSwaps = set
    }
    
    func isPossibleSwap(swap: Swap) -> Bool {
        return possibleSwaps.containsElement(swap)
    }
    
}