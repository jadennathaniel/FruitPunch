//
//  MenuScene.swift
//  FruitPunch
//
//  Created by Jaden Prawiro on 12/5/23.
//

import UIKit
import SpriteKit

class MenuScene: SKScene {
    var newGameButtonNode: SKSpriteNode!
    var calibrateButtonNode: SKSpriteNode!
    var difficultyButtonNode: SKSpriteNode!
    var difficultyLabelNode: SKLabelNode!
    var titleLabelNode: SKLabelNode!
    var fruitsTexture:SKSpriteNode!
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.cyan
        
        titleLabelNode = SKLabelNode(text: "Fruit Punch")
        titleLabelNode.position = CGPoint(x: self.frame.size.width / 2 - 370, y: self.frame.size.height - 900)
        titleLabelNode.fontName = "AmericanTypewriter"
        titleLabelNode.fontSize = 96
        titleLabelNode.fontColor = UIColor.black
        self.addChild(titleLabelNode)
        
        newGameButtonNode = SKSpriteNode(imageNamed: "newgame")
        newGameButtonNode.position = CGPoint(x: self.frame.size.width / 2 - 370, y: self.frame.size.height - 1080)
        newGameButtonNode.size = CGSize(width: 482, height: 143)
        self.addChild(newGameButtonNode)
        
        calibrateButtonNode = SKSpriteNode(imageNamed: "practice")
        calibrateButtonNode.position = CGPoint(x: self.frame.size.width / 2 - 370, y: self.frame.size.height - 1250)
        calibrateButtonNode.size = CGSize(width: 482, height: 143)
        self.addChild(calibrateButtonNode)
        
        difficultyButtonNode = SKSpriteNode(imageNamed: "difficulty")
        difficultyButtonNode.position = CGPoint(x: self.frame.size.width / 2 - 370, y: self.frame.size.height - 1450)
        difficultyButtonNode.size = CGSize(width: 482, height: 143)
        self.addChild(difficultyButtonNode)
        
    
        difficultyLabelNode = SKLabelNode(text: "Easy")
        difficultyLabelNode.position = CGPoint(x: self.frame.size.width / 2 - 370, y: self.frame.size.height - 1600)
        difficultyLabelNode.fontName = "AmericanTypewriter"
        difficultyLabelNode.fontSize = 48
        difficultyLabelNode.fontColor = UIColor(red: 0.0, green: 0.0, blue: 0.7, alpha: 1.0)
        self.addChild(difficultyLabelNode)
        
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "hard"){
            difficultyLabelNode.text = "Hard"
        } else{
            difficultyLabelNode.text = "Easy"
        }
        
        fruitsTexture = SKSpriteNode(imageNamed: "fruits")
        fruitsTexture.position = CGPoint(x: self.frame.size.width / 2 - 370, y: self.frame.size.height - 1750)
        fruitsTexture.size = CGSize(width: 300, height: 150)
        self.addChild(fruitsTexture)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self){
            let touchedNode = atPoint(location)
            if touchedNode == newGameButtonNode{ //transition to gamescene
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                gameScene.scaleMode = .aspectFit
                self.view?.presentScene(gameScene, transition: transition)
            }
            else if touchedNode == calibrateButtonNode{ //transition to practice scene
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let calibrateScene = CalibrateScene(size: self.size)
                calibrateScene.scaleMode = .aspectFit
                self.view?.presentScene(calibrateScene, transition: transition)
            }
            else if touchedNode == difficultyButtonNode{ //changing difficulty
                changeDifficulty()
            }
        }
    }
    
    func changeDifficulty(){
        let userDefaults = UserDefaults.standard
        
        if difficultyLabelNode.text == "Easy"{
            difficultyLabelNode.text = "Hard"
            userDefaults.set(true, forKey: "hard") //set user defaults for user preference
        } else{
            difficultyLabelNode.text = "Easy"
            userDefaults.set(false, forKey: "hard")
        }
        
        userDefaults.synchronize()
    }
    
}
