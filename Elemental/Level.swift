//
//  Level.swift
//  Elemental
//
//  Created by Jason Martin on 3/29/15.
//  Copyright (c) 2015 uStoria LLC. All rights reserved.
//

import Foundation

let NumColumns = 8
let NumRows = 8

class Level {
    private var elements = Array2D<Element>(columns: NumColumns, rows: NumRows)
    private var comboMultiplier = 0
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    private var possibleSwaps = Set<Swap>()
    let targetScore: Int!
    let maximumMoves: Int!
    let levelType: String!
    
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
                targetScore = (dictionary["targetScore"] as NSNumber).integerValue
                maximumMoves = (dictionary["moves"] as NSNumber).integerValue
                levelType = (dictionary["element"] as NSString)
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
    
    private func detectHorizontalMatches() -> Set<Chain> {
        // 1
        var set = Set<Chain>()
        // 2
        for row in 0..<NumRows {
            for var column = 0; column < NumColumns - 2 ; {
                // 3
                if let element = elements[column, row] {
                    let matchType = element.elementType
                    // 4
                    if elements[column + 1, row]?.elementType == matchType &&
                        elements[column + 2, row]?.elementType == matchType {
                            // 5
                            let chain = Chain(chainType: .Horizontal)
                            do {
                                chain.addElement(elements[column, row]!)
                                ++column
                            }
                                while column < NumColumns && elements[column, row]?.elementType == matchType
                            
                            set.addElement(chain)
                            continue
                    }
                }
                // 6
                ++column
            }
        }
        return set
    }
    
    private func detectVerticalMatches() -> Set<Chain> {
        var set = Set<Chain>()
        
        for column in 0..<NumColumns {
            for var row = 0; row < NumRows - 2; {
                if let element = elements[column, row] {
                    let matchType = element.elementType
                    
                    if elements[column, row + 1]?.elementType == matchType &&
                        elements[column, row + 2]?.elementType == matchType {
                            
                            let chain = Chain(chainType: .Vertical)
                            do {
                                chain.addElement(elements[column, row]!)
                                ++row
                            }
                                while row < NumRows && elements[column, row]?.elementType == matchType
                            
                            set.addElement(chain)
                            continue
                    }
                }
                ++row
            }
        }
        return set
    }
    
    func removeMatches() -> Set<Chain> {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        removeElements(horizontalChains)
        removeElements(verticalChains)
        calculateScores(horizontalChains)
        calculateScores(verticalChains)
        return horizontalChains.unionSet(verticalChains)
    }
    
    private func removeElements(chains: Set<Chain>) {
        for chain in chains {
            for element in chain.elements {
                elements[element.column, element.row] = nil
            }
        }
    }
    
    func fillHoles() -> [[Element]] {
        var columns = [[Element]]()
        // 1
        for column in 0..<NumColumns {
            var array = [Element]()
            for row in 0..<NumRows {
                // 2
                if tiles[column, row] != nil && elements[column, row] == nil {
                    // 3
                    for lookup in (row + 1)..<NumRows {
                        if let element = elements[column, lookup] {
                            // 4
                            elements[column, lookup] = nil
                            elements[column, row] = element
                            element.row = row
                            // 5
                            array.append(element)
                            // 6
                            break
                        }
                    }
                }
            }
            // 7
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    //this method adds new elements
    func topUpElements() -> [[Element]] {
        var columns = [[Element]]()
        var elementType: ElementType = .Unknown
        
        for column in 0..<NumColumns {
            var array = [Element]()
            // 1
            for var row = NumRows - 1; row >= 0 && elements[column, row] == nil; --row {
                // 2
                if tiles[column, row] != nil {
                    // 3
                    var newElementType: ElementType
                    do {
                        newElementType = ElementType.random()
                    } while newElementType == elementType
                    elementType = newElementType
                    // 4
                    let element = Element(column: column, row: row, elementType: elementType)
                    elements[column, row] = element
                    array.append(element)
                }
            }
            // 5
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }

    private func calculateScores(chains: Set<Chain>) {
        // 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
        for chain in chains {
            chain.score = 60 * (chain.length - 2) * comboMultiplier
            ++comboMultiplier
        }
    }
    
    func resetComboMultiplier() {
        comboMultiplier = 1
    }
    
}