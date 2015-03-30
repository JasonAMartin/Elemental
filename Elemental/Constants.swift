//
//  Constants.swift
//  Elemental
//
//  Created by Jason Martin on 3/29/15.
//  Copyright (c) 2015 uStoria LLC. All rights reserved.
//

import SpriteKit

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


//sound reference
var playFireball = SKAction.playSoundFileNamed("fireball.mp3", waitForCompletion: true)
var playBackgroundMusic = SKAction.playSoundFileNamed("backgroundSound.mp3", waitForCompletion: true)
var playTing = SKAction.playSoundFileNamed("ting.mp3", waitForCompletion: false)