//
//  GameViewController.swift
//  Elemental
//
//  Created by Jason Martin on 3/29/15.
//  Copyright (c) 2015 uStoria LLC. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation


class GameViewController: UIViewController {
    var scene: GameScene!
    var level: Level!
    var movesLeft = 0
    var score = 0
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverPanel: UIImageView!
    @IBOutlet weak var shuffleButton: UIButton!

    @IBAction func shuffleButtonPressed(AnyObject) {
        shuffle()
        decrementMoves()
    }
    
    
    lazy var backgroundMusic: AVAudioPlayer = {
        let url = NSBundle.mainBundle().URLForResource("backgroundSound", withExtension: "mp3")
        let player = AVAudioPlayer(contentsOfURL: url, error: nil)
        player.numberOfLoops = -1
        return player
        }()
    
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
        level = Level(filename: "Level_5")
        scene.level = level
        scene.addTiles()

        scene.swipeHandler = handleSwipe
        gameOverPanel.hidden = true
        shuffleButton.hidden = true
        shuffleButton.layer.cornerRadius = 15.0

        // Present the scene.
        skView.presentScene(scene)
        backgroundMusic.play()
        //start game
        beginGame()
    }
    
    func beginGame() {
        movesLeft = level.maximumMoves
        score = 0
        updateLabels()
        level.resetComboMultiplier()
        scene.animateBeginGame() {self.shuffleButton.hidden = false}
        shuffle()
        println("Starting level for element: \(level.levelType)")
    }
    
    func shuffle() {
        scene.removeAllElementSprites()
        let newElements = level.shuffle()
        scene.addSpritesForElements(newElements)
    }
    
    func handleSwipe(swap: Swap) {
        view.userInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            scene.animateSwap(swap, completion: handleMatches)
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.userInteractionEnabled = true
            }
        }
    }
    
    func handleMatches() {
        let chains = level.removeMatches()
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        scene.animateMatchedElements(chains) {
            for chain in chains {
                self.score += chain.score
            }
            self.updateLabels()
            let columns = self.level.fillHoles()
            self.scene.animateFallingElements(columns) {
                let columns = self.level.topUpElements()
                self.scene.animateNewElements(columns) {
                    self.handleMatches()
                }
            }
        }
    }
    
    func beginNextTurn() {
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        view.userInteractionEnabled = true
        decrementMoves()
    }

    func updateLabels() {
        println(NSString(format: "%ld", score))
        targetLabel.text = NSString(format: "%ld", level.targetScore)
        movesLabel.text = NSString(format: "%ld", movesLeft)
        scoreLabel.text = NSString(format: "%ld", score)
    }

    func decrementMoves() {
        --movesLeft
        updateLabels()
        if score >= level.targetScore {
            gameOverPanel.image = UIImage(named: "rockHouse") //level complete image
            showGameOver()
        } else if movesLeft == 0 {
            gameOverPanel.image = UIImage(named: "gameBackground") //game over image
            showGameOver()
        }
    }
    
    func showGameOver() {
        gameOverPanel.hidden = false
        scene.userInteractionEnabled = false
        shuffleButton.hidden = true

        scene.animateGameOver() {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideGameOver")
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    
    func hideGameOver() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        
        gameOverPanel.hidden = true
        scene.userInteractionEnabled = true
        
        beginGame()
    }

}