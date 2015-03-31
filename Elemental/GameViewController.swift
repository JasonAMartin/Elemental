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
    
    //add mana Inidcators
    let iceManaInidcator = SKSpriteNode(color:SKColor.appIceMana(),size:CGSize(width: 20,height: 4))
    let fireManaInidcator = SKSpriteNode(color:SKColor.appFireMana(),size:CGSize(width: 20,height: 4))
    let timeManaInidcator = SKSpriteNode(color:SKColor.appTimeMana(),size:CGSize(width: 20,height: 4))
    let voidManaInidcator = SKSpriteNode(color:SKColor.appVoidMana(),size:CGSize(width: 20,height: 4))
    let earthManaInidcator = SKSpriteNode(color:SKColor.appEarthMana(),size:CGSize(width: 20,height: 4))
    let windManaInidcator = SKSpriteNode(color:SKColor.appWindMana(),size:CGSize(width: 20,height: 4))
    let lightningManaInidcator = SKSpriteNode(color:SKColor.appLightningMana(),size:CGSize(width: 20,height: 4))
    let waterManaInidcator = SKSpriteNode(color:SKColor.appWaterMana(),size:CGSize(width: 20,height: 4))
    
    //add mana values
    var iceMana = 0
    var fireMana = 0
    var timeMana = 0
    var voidMana = 0
    var earthMana = 0
    var windMana = 0
    var lightningMana = 0
    var waterMana = 0

    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverPanel: UIImageView!
    @IBOutlet weak var shuffleButton: UIButton!
    
    @IBOutlet weak var levelTypeLabel: UILabel!

    @IBAction func shuffleButtonPressed(AnyObject) {
        scene.runAction(playTeleport)
        shuffle()
        decrementMoves()
    }

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
        createSounds()
        
        
        //load level
        level = Level(filename: "Level_5")
        
        
        // Configure the view.
        let skView = view as SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.background = level.backgroundImage
        scene.scaleMode = .AspectFill
        scene.level = level
        
        //LEVEL STUFF
        
        scene.changeBackground(level.backgroundImage)
        let levelMusic = level.backgroundMusic
        
        //END LEVEL STUFF
        
        
        iceManaInidcator.name = "IceMana"
        iceManaInidcator.position = CGPoint(x: -120, y: -200)
        iceManaInidcator.anchorPoint = CGPointMake(0.5, 0.0) //rect expands from bottom vertically. For horiz, just swap.
        scene.addChild(iceManaInidcator)
        
        fireManaInidcator.name = "FireMana"
        fireManaInidcator.position = CGPoint(x: -86, y: -200)
        fireManaInidcator.anchorPoint = CGPointMake(0.5, 0.0) //setting anchor so growth will be from here
        scene.addChild(fireManaInidcator)
        
        timeManaInidcator.name = "TimeMana"
        timeManaInidcator.position = CGPoint(x: -52, y: -200)
        timeManaInidcator.anchorPoint = CGPointMake(0.5, 0.0) //setting anchor so growth will be from here
        scene.addChild(timeManaInidcator)
        
        voidManaInidcator.name = "VoidMana"
        voidManaInidcator.position = CGPoint(x: -18, y: -200)
        voidManaInidcator.anchorPoint = CGPointMake(0.5, 0.0)
        scene.addChild(voidManaInidcator)
        
        earthManaInidcator.name = "EarthMana"
        earthManaInidcator.position = CGPoint(x: 16, y: -200)
        earthManaInidcator.anchorPoint = CGPointMake(0.5, 0.0)
        scene.addChild(earthManaInidcator)
        
        windManaInidcator.name = "WindMana"
        windManaInidcator.position = CGPoint(x: 50, y: -200)
        windManaInidcator.anchorPoint = CGPointMake(0.5, 0.0)
        scene.addChild(windManaInidcator)
        
        lightningManaInidcator.name = "LightningMana"
        lightningManaInidcator.position = CGPoint(x: 84, y: -200)
        lightningManaInidcator.anchorPoint = CGPointMake(0.5, 0.0)
        scene.addChild(lightningManaInidcator)
        
        waterManaInidcator.name = "WaterMana"
        waterManaInidcator.position = CGPoint(x: 118, y: -200)
        waterManaInidcator.anchorPoint = CGPointMake(0.5, 0.0)
        scene.addChild(waterManaInidcator)
        
        
        scene.addTiles()

        scene.swipeHandler = handleSwipe
        gameOverPanel.hidden = true
        shuffleButton.hidden = true
        shuffleButton.layer.cornerRadius = 15.0
        
        // Present the scene.
        skView.presentScene(scene)
        //gameBackgroundMusic.play()
        masterSounds[levelMusic]?.play()
        masterSounds[levelMusic]?.volume = 0.3 //volume adjustment needs to come after play

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
        levelTypeLabel.text = "level:  \(level.levelType)"
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
            //this is run after chains assembled in Level.swift
            for chain in chains {
                //chainType = Vertical/Horizontal
                //description = returned string
                //elements = array
                //firstElement().elemental == element type in uppercase like EARTH
                
                //if chain.score > 0, fill up some mana
                self.updataMana(manaType: chain.firstElement().elemental, manaAmount: 10)
               
                
                
                //playing good or ba sound on match
                if(chain.score>0){
                    self.scene.playSound(1)
                } else if (chain.score<0) {
                    self.scene.playSound(2)
                } else {
                    self.scene.playSound(3) //0 points sound
                }
                
                //add to score
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
    
    func updataMana(#manaType:String, #manaAmount: Int){
        //current max size is 50
        let maxSize = 50
        var newSize = 0
        
      println("ICE MANA: \(iceMana)")
        switch manaType {
            case "ICE":
                newSize = iceMana + manaAmount
                if(newSize > 50) {newSize = 50}
                iceMana = newSize
                self.iceManaInidcator.size = CGSizeMake(20, CGFloat(newSize)) //width, height
            case "FIRE":
                newSize = fireMana + manaAmount
                if(newSize > 50) {newSize = 50}
                fireMana = newSize
                self.fireManaInidcator.size = CGSizeMake(20, CGFloat(newSize)) //width, height
            case "VOID":
                newSize = voidMana + manaAmount
                if(newSize > 50) {newSize = 50}
                voidMana = newSize
                self.voidManaInidcator.size = CGSizeMake(20, CGFloat(newSize)) //width, height
            case "TIME":
                newSize = timeMana + manaAmount
                if(newSize > 50) {newSize = 50}
                timeMana = newSize
                self.timeManaInidcator.size = CGSizeMake(20, CGFloat(newSize)) //width, height
            case "WIND":
                newSize = windMana + manaAmount
                if(newSize > 50) {newSize = 50}
                windMana = newSize
                self.windManaInidcator.size = CGSizeMake(20, CGFloat(newSize)) //width, height
            case "EARTH":
                newSize = earthMana + manaAmount
                if(newSize > 50) {newSize = 50}
                earthMana = newSize
                self.earthManaInidcator.size = CGSizeMake(20, CGFloat(newSize)) //width, height
            case "WATER":
                newSize = waterMana + manaAmount
                if(newSize > 50) {newSize = 50}
                waterMana = newSize
                self.waterManaInidcator.size = CGSizeMake(20, CGFloat(newSize)) //width, height
            case "LIGHTNING":
                newSize = lightningMana + manaAmount
                if(newSize > 50) {newSize = 50}
                lightningMana = newSize
                self.lightningManaInidcator.size = CGSizeMake(20, CGFloat(newSize)) //width, height

        default:
            newSize = 4
        }
        
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