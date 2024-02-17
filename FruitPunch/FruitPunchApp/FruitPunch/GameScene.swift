//
//  GameScene.swift
//  FruitPunch
//
//  Created by Jaden Prawiro on 12/5/23.
//
//Inspiration from https://www.youtube.com/watch?v=DL2YQa9Ryp4&t=1508s
//https://www.youtube.com/watch?v=cJy61bOqQpg&t=973s


import SpriteKit
import GameplayKit
import CoreMotion
import CoreML

enum GamePhase {
    case Ready
    case InPlay
    case GameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var gamePhase = GamePhase.Ready
    var bestScore = 0
    var score:Int = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    var misses = 0
    var maxMisses = 3
    var xMarks:XMarks!
    var promptLabel:SKLabelNode!
    var scoreLabel:SKLabelNode!
    var bestScoreLabel:SKLabelNode!
    var backButton:SKLabelNode!
    var tapLabel:SKLabelNode!
    var instructionNode:SKSpriteNode!
    
    var fruitTimer = Timer()
    
    var ringBuffer = RingBuffer()
    let motion = CMMotionManager()
    let motionOperationQueue = OperationQueue()
    
    var isCalibrating = false
    var isWaitingForMotionData = true
    var accelMagValue = 1.0
    var gyroMagValue = 1.0
    
    
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
            handlePunches(outputTuri.target) //sending the label for punch detection
            setDelayedWaitingToTrue(0.5)
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
    
    func handlePunches(_ response:String){
        for node in children{ //if correct punch is done on correct fruit, remove fruit and increase score
            if node.name == "apple" && response == "jab"{
                score += 1
                scoreLabel.text = "Score: \(score)"
                node.removeFromParent()
            }
            if node.name == "orange" && response == "hook"{
                score += 1
                scoreLabel.text = "Score: \(score)"
                node.removeFromParent()
            }
            if node.name == "pineapple" && response == "uppercut"{
                score += 1
                scoreLabel.text = "Score: \(score)"
                node.removeFromParent()
            }
        }
    }
    
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = UIColor.cyan
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -2)
        
        instructionNode = SKSpriteNode(imageNamed: "instructions")
        instructionNode.position = CGPoint(x: 600, y: self.frame.size.height - 270)
        instructionNode.size = CGSize(width: 300, height: 250)
        self.addChild(instructionNode)
        
        backButton = SKLabelNode(text: "Back")
        backButton.position = CGPoint(x: 100, y: self.frame.size.height - 70)
        backButton.fontName = "AmericanTypewriter"
        backButton.fontSize = 36
        backButton.fontColor = UIColor.blue
        self.addChild(backButton)
        
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.position = CGPoint(x: 100, y: self.frame.size.height - 120)
        scoreLabel.fontName = "AmericanTypewriter"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.black
        score = 0
        self.addChild(scoreLabel)
        
        bestScoreLabel = SKLabelNode(text: "Best: \(bestScore)")
        bestScoreLabel.position = CGPoint(x: 100, y: self.frame.size.height - 170)
        bestScoreLabel.fontName = "AmericanTypewriter"
        bestScoreLabel.fontSize = 36
        bestScoreLabel.fontColor = UIColor.black
        self.addChild(bestScoreLabel)
              
        promptLabel = SKLabelNode(text: "Fruit Punch")
        promptLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        promptLabel.fontName = "AmericanTypewriter-Bold"
        promptLabel.fontSize = 96
        promptLabel.fontColor = UIColor.black
        self.addChild(promptLabel)
        
        tapLabel = SKLabelNode(text: "Tap to play")
        tapLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2 - 60)
        tapLabel.fontName = "AmericanTypewriter"
        tapLabel.fontSize = 40
        tapLabel.fontColor = UIColor.darkGray
        self.addChild(tapLabel)
    
        xMarks = XMarks(num: maxMisses) //initializing x marks
        xMarks.position = CGPoint(x: self.frame.size.width-90, y: self.frame.size.height - 70)
        addChild(xMarks)

        //if best score exists, set the best score
        if UserDefaults.standard.object(forKey: "bestScore") != nil{
            bestScore = UserDefaults.standard.object(forKey: "bestScore") as! Int
        }
        
        self.physicsWorld.contactDelegate = self
        startMotionUpdates()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gamePhase == .Ready {
            gamePhase = .InPlay
            startGame()
        }
        let touch = touches.first
        
        if let location = touch?.location(in: self){
            let touchedNode = atPoint(location)
            if touchedNode == backButton{ //back button functionality
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let menuScene = MenuScene(fileNamed: "MenuScene")!
                menuScene.scaleMode = scaleMode
                self.view?.presentScene(menuScene, transition: transition)
            }
        }
        
    }
    
    override func didSimulatePhysics() {
        for fruit in children {
            if fruit.position.y < -1000 {
                missFruit()
                fruit.removeFromParent()
                
            }
        }
    }
    
    func missFruit(){
        misses += 1
        xMarks.update(num: misses)
        if misses == maxMisses{
            gameOver()
        }
    }
    
    func startGame(){
        score = 0
        scoreLabel.text = "Score: \(score)"
        bestScoreLabel.text = "Best: \(bestScore)"
        
        //make title labels disappear once game starts
        promptLabel.isHidden = true
        tapLabel.isHidden = true
        misses = 0
        xMarks.reset()
        
        var timeInterval = 3.0
        if UserDefaults.standard.bool(forKey: "hard"){ //if user selects hard, fruits appear faster
            timeInterval = 1.0
        }
        
        fruitTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: {_ in self.createFruits()})
    }
    
    func createFruits(){
        let numberOfFruits = 1 + Int(arc4random_uniform(UInt32(4)))
        
        for _ in 0..<numberOfFruits{
            let fruit = Fruits()
            fruit.position.x = randomCGFloat(0, self.frame.size.width)
            fruit.position.y = 100
            addChild(fruit)
            print(fruit.description)
            
            //making sure fruits don't fly out to the side of the screen
            if(fruit.position.x < self.frame.size.width / 2){
                fruit.physicsBody?.velocity.dx = randomCGFloat(0, 200)
            }
            if fruit.position.x > self.frame.size.width / 2{
                fruit.physicsBody?.velocity.dx = randomCGFloat(0, -200)
            }
            
            fruit.physicsBody?.velocity.dy = randomCGFloat(1200, 1300)
            fruit.physicsBody?.angularVelocity = randomCGFloat(-5, 5)
        }
    }
    
    func gameOver(){
        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: "bestScore") //save locally the best score
            UserDefaults.standard.synchronize()
        }
        
        promptLabel.isHidden = false
        promptLabel.text = "Game Over"
        promptLabel.setScale(0)
        promptLabel.run(SKAction.scale(to: 1, duration: 0.3))
        
        gamePhase = .GameOver
        
        fruitTimer.invalidate()
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: {_ in self.gamePhase = .Ready})
    }
    
    override func willMove(from view: SKView) {
        motion.stopDeviceMotionUpdates()
        fruitTimer.invalidate()
    }
    
}
