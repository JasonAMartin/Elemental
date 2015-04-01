//
//  Constants.swift
//  Elemental
//
//  Created by Jason Martin on 3/29/15.
//  Copyright (c) 2015 uStoria LLC. All rights reserved.
//

import SpriteKit
import AVFoundation


enum State: Int {
    case Selected, Moving, Moved
}

//sound dictionary for loading


let soundFiles = [
    "backgroundMusic": "backgroundSound.mp3",
    "blockStacking" : "blockStacking.mp3",
    "fireball" : "fireball.mp3"
]

let gameBackground = SKSpriteNode(imageNamed: "gameBackground")
let fireManaGraphic = SKSpriteNode(imageNamed: "element-fire")
let iceManaGraphic = SKSpriteNode(imageNamed: "element-ice")
let waterManaGraphic = SKSpriteNode(imageNamed: "element-water")
let lightningManaGraphic = SKSpriteNode(imageNamed: "element-lightning")
let windManaGraphic = SKSpriteNode(imageNamed: "element-wind")
let earthManaGraphic = SKSpriteNode(imageNamed: "element-earth")
let timeManaGraphic = SKSpriteNode(imageNamed: "element-time")
let voidManaGraphic = SKSpriteNode(imageNamed: "element-void")


//sound reference


//dictionary to hold background sounds and functions
var masterSounds = [String:AVAudioPlayer]()


//creating sounds for dictionary
    var gameBackgroundMusic: AVAudioPlayer = {
    let url = NSBundle.mainBundle().URLForResource("backgroundSound", withExtension: "mp3")
    let player = AVAudioPlayer(contentsOfURL: url, error: nil)
    player.numberOfLoops = -1
    return player
    }()

    var gameBackgroundMusicTwo: AVAudioPlayer = {
    let url = NSBundle.mainBundle().URLForResource("gameIntroTwo", withExtension: "mp3")
    let player = AVAudioPlayer(contentsOfURL: url, error: nil)
    player.numberOfLoops = -1
    return player
    }()

func createSounds(){
    //this function is called from GameVC and puts all the sounds in the dictionary for use
    masterSounds.updateValue(gameBackgroundMusic, forKey: "mainBackground")
    masterSounds.updateValue(gameBackgroundMusicTwo, forKey: "gameIntroTwo")
}

var playFireball = SKAction.playSoundFileNamed("fireball.mp3", waitForCompletion: false)
//var playBackgroundMusic = SKAction.playSoundFileNamed("backgroundSound.mp3", waitForCompletion: true)
var playTing = SKAction.playSoundFileNamed("ting.mp3", waitForCompletion: false)
var playStacking = SKAction.playSoundFileNamed("blockStacking.mp3", waitForCompletion: false)
var playBadElement = SKAction.playSoundFileNamed("freedom.mp3", waitForCompletion: false)
var playGoodElement = SKAction.playSoundFileNamed("magic.mp3", waitForCompletion: false)
var playMagicPoint = SKAction.playSoundFileNamed("magicpoint.mp3", waitForCompletion: false)
var playPowerOne = SKAction.playSoundFileNamed("powerOne.mp3", waitForCompletion: false)
var playNoMatch = SKAction.playSoundFileNamed("noMatch.mp3", waitForCompletion: false)
var playTeleport = SKAction.playSoundFileNamed("teleport.mp3", waitForCompletion: false)
