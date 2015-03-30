//
//  GameViewController.swift
//  Elemental
//
//  Created by Jason Martin on 3/29/15.
//  Copyright (c) 2015 uStoria LLC. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var scene: GameScene!
    var level: Level!

    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        //load level
        level = Level(filename: "Level_0")
        scene.level = level
        scene.addTiles()

        scene.swipeHandler = handleSwipe

        // Present the scene.
        skView.presentScene(scene)
        
        //start game
        beginGame()
    }
    
    func beginGame() {
        shuffle()
    }
    
    func shuffle() {
        let newElements = level.shuffle()
        scene.addSpritesForElements(newElements)
    }
    
    func handleSwipe(swap: Swap) {
        view.userInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            scene.animateSwap(swap) {
                self.view.userInteractionEnabled = true
            }
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.userInteractionEnabled = true
            }
        }
    }
}