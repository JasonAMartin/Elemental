//
//  GameScene.swift
//  Elemental
//
//  Created by Jason Martin on 3/29/15.
//  Copyright (c) 2015 uStoria LLC. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var selectionSprite = SKSpriteNode()
    var swipeHandler: ((Swap) -> ())?
    var level: Level!
    let tilesLayer = SKNode()
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    var swipeFromColumn: Int?
    var swipeFromRow: Int?
    
    let gameLayer = SKNode()
    let elementsLayer = SKNode()
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        runAction(playBackgroundMusic)

        anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
        addChild(gameBackground)
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        elementsLayer.position = layerPosition
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        gameLayer.addChild(elementsLayer)
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    func addSpritesForElements(elements: Set<Element>) {
        for element in elements {
            let sprite = SKSpriteNode(imageNamed: element.elementType.spriteName)
            sprite.position = pointForColumn(element.column, row:element.row)
            elementsLayer.addChild(sprite)
            element.sprite = sprite
        }
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let tile = level.tileAtColumn(column, row: row) {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.position = pointForColumn(column, row: row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // 1
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(elementsLayer)
        // 2
        let (success, column, row) = convertPoint(location)
        if success {
            // 3
            if let element = level.elementAtColumn(column, row: row) {
                // 4
                showSelectionIndicatorForElement(element)
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        // 1
        if swipeFromColumn == nil { return }
        
        // 2
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(elementsLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            
            // 3
            var horzDelta = 0, vertDelta = 0
            if column < swipeFromColumn! {          // swipe left
                horzDelta = -1
            } else if column > swipeFromColumn! {   // swipe right
                horzDelta = 1
            } else if row < swipeFromRow! {         // swipe down
                vertDelta = -1
            } else if row > swipeFromRow! {         // swipe up
                vertDelta = 1
            }
            
            // 4
            if horzDelta != 0 || vertDelta != 0 {
                trySwapHorizontal(horzDelta, vertical: vertDelta)
                hideSelectionIndicator()
                
                // 5
                swipeFromColumn = nil
            }
        }
    }
    
    func trySwapHorizontal(horzDelta: Int, vertical vertDelta: Int) {
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        
        // Going outside the bounds of the array? This happens when the user swipes
        // over the edge of the grid. We should ignore such swipes.
        if toColumn < 0 || toColumn >= NumColumns { return }
        if toRow < 0 || toRow >= NumRows { return }
        
        // Can't swap if there is no cookie to swap with. This happens when the user
        // swipes into a gap where there is no tile.
        if let toElement = level.elementAtColumn(toColumn, row: toRow) {
            if let fromElement = level.elementAtColumn(swipeFromColumn!, row: swipeFromRow!) {
                
                // Communicate this swap request back to the ViewController.
                if let handler = swipeHandler {
                    let swap = Swap(elementA: fromElement, elementB: toElement)
                    handler(swap)
                }
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        if selectionSprite.parent != nil && swipeFromColumn != nil {
            hideSelectionIndicator()
        }
        
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        touchesEnded(touches, withEvent: event)
    }

    func animateSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.elementA.sprite!
        let spriteB = swap.elementB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.3
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        spriteA.runAction(moveA, completion: completion)
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        spriteB.runAction(moveB)
    }
    
    func showSelectionIndicatorForElement(element: Element) {
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        if let sprite = element.sprite {
            let texture = SKTexture(imageNamed: element.elementType.highlightedSpriteName)
            selectionSprite.size = texture.size()
            selectionSprite.runAction(SKAction.setTexture(texture))
            
            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
        }
    }
    
    func hideSelectionIndicator() {
        selectionSprite.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(0.3),
            SKAction.removeFromParent()]))
    }
    
    func animateInvalidSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.elementA.sprite!
        let spriteB = swap.elementB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.2
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        
        spriteA.runAction(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.runAction(SKAction.sequence([moveB, moveA]))
    }

}