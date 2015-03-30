//
//  Chain.swift
//  Elemental
//
//  Created by Jason Martin on 3/30/15.
//  Copyright (c) 2015 uStoria LLC. All rights reserved.
//

class Chain: Hashable, Printable {
    var elements = [Element]()
    
    enum ChainType: Printable {
        case Horizontal
        case Vertical
        
        var description: String {
            switch self {
            case .Horizontal: return "Horizontal"
            case .Vertical: return "Vertical"
            }
        }
    }
    
    var chainType: ChainType
    
    init(chainType: ChainType) {
        self.chainType = chainType
    }
    
    func addElement(element: Element) {
        elements.append(element)
    }
    
    func firstElement() -> Element {
        return elements[0]
    }
    
    func lastElement() -> Element {
        return elements[elements.count - 1]
    }
    
    var length: Int {
        return elements.count
    }
    
    var description: String {
        return "type:\(chainType) cookies:\(elements)"
    }
    
    var hashValue: Int {
        return reduce(elements, 0) { $0.hashValue ^ $1.hashValue }
    }
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
    return lhs.elements == rhs.elements
}