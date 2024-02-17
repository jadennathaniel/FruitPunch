//
//  CalibrateScene.swift
//  FruitPunch
//
//  Created by Jaden Prawiro on 12/7/23.
//

import SpriteKit
import UIKit
import CoreMotion
import CoreML

class CalibrateScene: SKScene{
    
    var ringBuffer = RingBuffer()
    let motion = CMMotionManager()
    let motionOperationQueue = OperationQueue()
    
    var isCalibrating = false
    var isWaitingForMotionData = true
    var accelMagValue = 1.0
    var gyroMagValue = 1.0
    
    var backButton:SKLabelNode!
    
    var jabLabel:SKLabelNode!
    var uppercutLabel:SKLabelNode!
    var hookLabel:SKLabelNode!
    var titleLabel:SKLabelNode!
    var noteLabel:SKLabelNode!
    
    var jabTexture:SKSpriteNode!
    var hookTexture:SKSpriteNode!
    var uppercutTexture:SKSpriteNode!
    
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = UIColor.cyan
        
        backButton = SKLabelNode(text: "Back")
        backButton.position = CGPoint(x: self.frame.size.width - 650, y: self.frame.size.height - 75)
        backButton.fontName = "AmericanTypewriter"
        backButton.fontSize = 36
        backButton.fontColor = UIColor.black
        self.addChild(backButton)
        
        titleLabel = SKLabelNode(text: "Practice punches")
        titleLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 200)
        titleLabel.fontName = "AmericanTypewriter"
        titleLabel.fontSize = 75
        titleLabel.fontColor = UIColor.black
        self.addChild(titleLabel)
        
        jabLabel = SKLabelNode(text: "Jab")
        jabLabel.position = CGPoint(x: self.frame.size.width / 2 - 10, y: self.frame.size.height - 350)
        jabLabel.fontName = "AmericanTypewriter"
        jabLabel.fontSize = 48
        jabLabel.fontColor = UIColor.black
        self.addChild(jabLabel)
        
        jabTexture = SKSpriteNode(imageNamed: "jab2")
        jabTexture.position = CGPoint(x: self.frame.size.width / 2 - 10, y: self.frame.size.height - 450)
        jabTexture.size = CGSize(width: 200, height: 200)
        self.addChild(jabTexture)
        
        hookLabel = SKLabelNode(text: "Hook")
        hookLabel.position = CGPoint(x: self.frame.size.width / 2 - 10, y: self.frame.size.height - 650)
        hookLabel.fontName = "AmericanTypewriter"
        hookLabel.fontSize = 48
        hookLabel.fontColor = UIColor.black
        self.addChild(hookLabel)
        
        hookTexture = SKSpriteNode(imageNamed: "hook")
        hookTexture.position = CGPoint(x: self.frame.size.width / 2 - 10, y: self.frame.size.height - 750)
        hookTexture.size = CGSize(width: 200, height: 200)
        self.addChild(hookTexture)
        
        uppercutLabel = SKLabelNode(text: "Uppercut")
        uppercutLabel.position = CGPoint(x: self.frame.size.width / 2 - 10, y: self.frame.size.height - 970)
        uppercutLabel.fontName = "AmericanTypewriter"
        uppercutLabel.fontSize = 48
        uppercutLabel.fontColor = UIColor.black
        self.addChild(uppercutLabel)
        
        uppercutTexture = SKSpriteNode(imageNamed: "uppercut")
        uppercutTexture.position = CGPoint(x: self.frame.size.width / 2 - 10, y: self.frame.size.height - 1100)
        uppercutTexture.size = CGSize(width: 200, height: 200)
        self.addChild(uppercutTexture)
        
        startMotionUpdates()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self){
            let touchedNode = atPoint(location)
            if touchedNode == backButton{
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let menuScene = MenuScene(fileNamed: "MenuScene")!
                menuScene.scaleMode = scaleMode
                self.view?.presentScene(menuScene, transition: transition)
            }
        }
    }
    
    // MARK: Core Motion Updates
    func startMotionUpdates(){
        
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 1.0/200
            self.motion.startDeviceMotionUpdates(to: motionOperationQueue, withHandler: self.handleMotion)
        }
    }
    
    lazy var turiModel:TuriModel = {
        do{
            let config = MLModelConfiguration()
            return try TuriModel(configuration: config)
        }catch{
            print(error)
            fatalError("Could not load custom model")
        }
    }()
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let accel = motionData?.userAcceleration, let gyro = motionData?.rotationRate {
            self.ringBuffer.addNewData(xAcc: accel.x, yAcc: accel.y, zAcc: accel.z, xGy: gyro.x, yGy: gyro.y, zGy: gyro.z)
            
            let accelMag = fabs(accel.x)+fabs(accel.y)+fabs(accel.z)
            let gyroMag = fabs(gyro.x)+fabs(gyro.y)+fabs(gyro.z)
            
            if accelMag > self.accelMagValue && gyroMag > self.gyroMagValue {
                // buffer up a bit more data and then notify of occurrence
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                        // something large enough happened to warrant
                        self.largeMotionEventOccurred()
                })
            }
        }
    }
    
    func largeMotionEventOccurred(){
        if(self.isWaitingForMotionData)
        {
            self.isWaitingForMotionData = false
            //predict a label
            let seq = toMLMultiArray(self.ringBuffer.getDataAsVector())
            
            guard let outputTuri = try? turiModel.prediction(sequence: seq) else {
                fatalError("Unexpected runtime error.")
            }
            displayLabelResponse(outputTuri.target)
            setDelayedWaitingToTrue(1.0)
        }
    }
    
    func setDelayedWaitingToTrue(_ time:Double){
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
            self.isWaitingForMotionData = true
        })
    }
    
//     convert to ML Multi array
// https://github.com/akimach/GestureAI-CoreML-iOS/blob/master/GestureAI/GestureViewController.swift
    private func toMLMultiArray(_ arr: [Double]) -> MLMultiArray {
        // create an empty multi array
        guard let sequence = try? MLMultiArray(shape:[300], dataType:MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray could not be created")
        }
        
        // populate the multi array with data
        let size = Int(truncating: sequence.shape[0])
        for i in 0..<size {
            sequence[i] = NSNumber(floatLiteral: arr[i])
        }
        return sequence
    }
    
    func displayLabelResponse(_ response:String){
        //highlight punch based on response
        switch response {
        case "jab":
            blinkLabel(jabLabel)
            DispatchQueue.main.async{
                self.uppercutLabel.fontColor = UIColor.black
                self.hookLabel.fontColor = UIColor.black
            }
            break
        case "uppercut":
            blinkLabel(uppercutLabel)
            DispatchQueue.main.async{
                self.jabLabel.fontColor = UIColor.black
                self.hookLabel.fontColor = UIColor.black
            }
            break
        case "hook":
            blinkLabel(hookLabel)
            DispatchQueue.main.async{
                self.uppercutLabel.fontColor = UIColor.black
                self.jabLabel.fontColor = UIColor.black
            }
            break
        default:
            print("Unknown")
            break
        }
    }
    
    func blinkLabel(_ label:SKLabelNode){
        DispatchQueue.main.async {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                label.fontColor = UIColor.red
            })
        }
    }
    
    override func willMove(from view: SKView) {
        motion.stopDeviceMotionUpdates()
    }

}
