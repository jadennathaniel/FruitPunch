//
//  Fruits.swift
//  FruitPunch
//
//  Created by Jaden Prawiro on 12/5/23.
//

import SpriteKit

class Fruits : SKNode {
    let apple = "🍎"
    let orange = "🍊"
    let pineapple = "🍍"
    override init() {
        super.init()
        
        var emoji = ""
        
        let probability = randomCGFloat(0, 1)

        //getting a random fruit and adding it as a child
        if probability < (1/3){
            name = "apple"
            emoji = apple
        } else if (probability < (2/3)){
            name = "orange"
            emoji = orange
        } else{
            name = "pineapple"
            emoji = pineapple
        }
        let label = SKLabelNode(text: emoji)
        label.fontSize = 120
        label.verticalAlignmentMode = .center
        addChild(label)
        
        physicsBody = SKPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
