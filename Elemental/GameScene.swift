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
        //runAction(playBackgroundMusic)

        anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
        addChild(gameBackground)
        addChild(gameLayer)
        gameLayer.hidden = true
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        elementsLayer.position = layerPosition
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        gameLayer.addChild(elementsLayer)
        swipeFromColumn = nil
        swipeFromRow = nil
        SKLabelNode(fontNamed: "GillSans-BoldItalic")
    }
    
    func addSpritesForElements(elements: Set<Element>) {
        for element in elements {
            let sprite = SKSpriteNode(imageNamed: element.elementType.spriteName)
            sprite.position = pointForColumn(element.column, row:element.row)
            elementsLayer.addChild(sprite)
            element.sprite = sprite
            sprite.alpha = 0
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            
            sprite.runAction(
                SKAction.sequence([
                    SKAction.waitForDuration(0.25, withRange: 0.5),
                    SKAction.group([
                        SKAction.fadeInWithDuration(0.25),
                        SKAction.scaleTo(1.0, duration: 0.25)
                        ])
                    ]))
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
    
    func animateMatchedElements(chains: Set<Chain>, completion: () -> ()) {
        for chain in chains {
            
            animateScoreForChain(chain)
            
            for element in chain.elements {
                if let sprite = element.sprite {
                    if sprite.actionForKey("removing") == nil {
                        let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
                        scaleAction.timingMode = .EaseOut
                        sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                            withKey:"removing")
                    }
                }
            }
        }
       // runAction(matchSound)
        runAction(SKAction.waitForDuration(0.3), completion: completion)
    }
    
    func animateFallingElements(columns: [[Element]], completion: () -> ()) {
        // 1
        var longestDuration: NSTimeInterval = 0
        for array in columns {
            for (idx, element) in enumerate(array) {
                let newPosition = pointForColumn(element.column, row: element.row)
                // 2
                let delay = 0.05 + 0.15*NSTimeInterval(idx)
                // 3
                let sprite = element.sprite!
                let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)
                // 4
                longestDuration = max(longestDuration, duration + delay)
                // 5
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.runAction(
                    SKAction.sequence([
                        SKAction.waitForDuration(delay),
                        SKAction.group([moveAction, playFireball])]))
            }
        }
        // 6
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }
    
    func animateNewElements(columns: [[Element]], completion: () -> ()) {
        // 1
        var longestDuration: NSTimeInterval = 0
        
        for array in columns {
            // 2
            let startRow = array[0].row + 1
            
            for (idx, element) in enumerate(array) {
                // 3
                let sprite = SKSpriteNode(imageNamed: element.elementType.spriteName)
                sprite.position = pointForColumn(element.column, row: startRow)
                elementsLayer.addChild(sprite)
                element.sprite = sprite
                // 4
                let delay = 0.1 + 0.2 * NSTimeInterval(array.count - idx - 1)
                // 5
                let duration = NSTimeInterval(startRow - element.row) * 0.1
                longestDuration = max(longestDuration, duration + delay)
                // 6
                let newPosition = pointForColumn(element.column, row: element.row)
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.alpha = 0
                sprite.runAction(
                    SKAction.sequence([
                        SKAction.waitForDuration(delay),
                        SKAction.group([
                            SKAction.fadeInWithDuration(0.05),
                            moveAction,
                            playTing])
                        ]))
            }
        }
        // 7
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }
    
    func animateScoreForChain(chain: Chain) {
        // Figure out what the midpoint of the chain is.
        let firstSprite = chain.firstElement().sprite!
        let lastSprite = chain.lastElement().sprite!
        let centerPosition = CGPoint(
            x: (firstSprite.position.x + lastSprite.position.x)/2,
            y: (firstSprite.position.y + lastSprite.position.y)/2 - 8)
        
        // Add a label for the score that slowly floats up.
        let scoreLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
        scoreLabel.fontSize = 16
        scoreLabel.text = NSString(format: "%ld", chain.score)
        scoreLabel.position = centerPosition
        scoreLabel.zPosition = 300
        elementsLayer.addChild(scoreLabel)
        
        let moveAction = SKAction.moveBy(CGVector(dx: 0, dy: 3), duration: 0.7)
        moveAction.timingMode = .EaseOut
        scoreLabel.runAction(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }
    
    func animateGameOver(completion: () -> ()) {
        let action = SKAction.moveBy(CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .EaseIn
        gameLayer.runAction(action, completion: completion)
    }
    
    func animateBeginGame(completion: () -> ()) {
        gameLayer.hidden = false
        gameLayer.position = CGPoint(x: 0, y: size.height)
        let action = SKAction.moveBy(CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .EaseOut
        gameLayer.runAction(action, completion: completion)
    }
    
    func removeAllElementSprites() {
        elementsLayer.removeAllChildren()
    }

}