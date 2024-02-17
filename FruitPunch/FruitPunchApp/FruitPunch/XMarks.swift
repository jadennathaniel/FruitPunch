//
//  XMarks.swift
//  FruitPunch
//
//  Created by Jaden Prawiro on 12/5/23.
//

import SpriteKit

class XMarks: SKNode {
    
    var xArray = [SKSpriteNode]()
    var numX = Int()
    
    let black = SKTexture(imageNamed: "blackx")
    let red = SKTexture(imageNamed: "redx")
    
    
    init(num: Int = 0){
        super.init()
        
        numX = num
        //adding num x marks for lives taken from https://www.youtube.com/watch?v=DL2YQa9Ryp4&t=1508s
        for i in 0..<num{
            let xMark = SKSpriteNode(imageNamed: "blackx")
            xMark.size = CGSize(width: 60, height: 60)
            xMark.position.x = -CGFloat(i)*70
            addChild(xMark)
            xArray.append(xMark)
        }
    }
    
    func update(num: Int){
        
        if num <= numX{
            xArray[xArray.count-num].texture = red

        }
    }
    
    func reset(){
        for xMark in xArray{
            xMark.texture = black
        }
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
}

