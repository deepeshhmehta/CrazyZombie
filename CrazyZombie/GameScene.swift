//
//  GameScene.swift
//  CrazyZombie
//
//  Created by Deepesh Mehta on 2018-05-31.
//  Copyright © 2018 DGames. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    //camera Rect used for visible bounds
    var cameraRect : CGRect {
        let x = DataStore.cameraNode.position.x - size.width/2
            + (size.width - DataStore.playableRect.width)/2
        let y = DataStore.cameraNode.position.y - size.height/2
            + (size.height - DataStore.playableRect.height)/2
        return CGRect(
            x: x,
            y: y,
            width: DataStore.playableRect.width,
            height: DataStore.playableRect.height)
    }
    
    //function that runs when scene loads
    override func didMove(to view: SKView) {
        //reset game parameters to override previous game values
        DataStore.lives = 5
        DataStore.catsInTrain = 0
        DataStore.gameOver = false
        DataStore.zombieIsBlinking = false
        DataStore.lastUpdateTime = 0
        DataStore.dt = 0
        DataStore.destination = DataStore.zombie.position
        
        //set position add score labels
        SpawnAndAnimations.setLabels()
        DataStore.cameraNode.addChild(DataStore.livesLabel)
        DataStore.cameraNode.addChild(DataStore.catsInTrainLabel)
        
        //test print gamestats
//        print("GameStats")
//        print("------")
//        print("lives: \(Values.lives)")
//        print("catsInTrain: \(Values.catsInTrain)")
//        print("gameOver: \(Values.gameOver)")
//        print("zombieIsBlinking: \(Values.zombieIsBlinking)")
//        print("lastUpdateTime: \(Values.lastUpdateTime)")
//        print("dt: \(Values.dt)")
        
        
        //add 2 background nodes to move around
        for i in 0...1 {
            let background = SpawnAndAnimations.backgroundNode()
            background.position = CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            addChild(background)
        }
        
        //set camera
        DataStore.cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        camera = DataStore.cameraNode
        addChild(DataStore.cameraNode)
        
        //add main player
        addChild(SpawnAndAnimations.spawnZombie(x: size.width/4, y: 400))

        //spawn action for primary enemy
        let primaryAction = SKAction.repeatForever(SKAction.sequence([
                    SKAction.run() { [weak self] in
                        self?.spawnEnemy(type: "primary")
                        
                    },
                    SKAction.wait(forDuration: TimeInterval(CGFloat.random(min: 1.0, max: 5.0) ))
                ])
            )
        run(primaryAction)
        
        //spawn action for cats
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnCat()
                },SKAction.wait(forDuration: TimeInterval(CGFloat.random(min: 1.0, max: 5.0)))])))
        
        //check and spawn action for secondary enemy
        if(DataStore.secondaryEnemyEnabled){
            let secondaryAction = SKAction.repeatForever(
                                    SKAction.sequence([
                                        SKAction.run() { [weak self] in
                                            self?.spawnEnemy(type: "secondary")
                                        },
                                        SKAction.wait(forDuration: TimeInterval(CGFloat.random(min: 2.0, max: 5.0)))
                                        ])
                                    )
            run(secondaryAction)
        }
        
        //check and spawn action for flower
        if(DataStore.flowerEnabled){
            let flowerSpawnAction = SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run() { [weak self] in
                        self?.spawnFlower()
                    },
                    SKAction.wait(forDuration: TimeInterval(CGFloat.random(min: 5.0, max: 10.0)))
                    ])
            )
            run(flowerSpawnAction)
        }
        
        //check and spawn action for small fish
        if(DataStore.smallFishEnabled){
            let smallFishSpawnAction = SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run() { [weak self] in
                        self?.spawnFish(type: "small")
                    },
                    SKAction.wait(forDuration: 8)
                    ])
            )
            run(smallFishSpawnAction)
        }
        
        //check and spawn action for bigfish
        if(DataStore.bigFishEnabled){
            let bigFishSpawnAction = SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run() { [weak self] in
                        self?.spawnFish(type: "big")
                    },
                    SKAction.wait(forDuration: 10)
                    ])
            )
            run(bigFishSpawnAction)
        }
        
        //if music is allowed play background music
        if DataStore.allowSound{
            playBackgroundMusic(filename: "backgroundMusic.mp3")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        //find difference between twoframe updates
        if DataStore.lastUpdateTime > 0 {
            DataStore.dt = currentTime - DataStore.lastUpdateTime
        } else {
            DataStore.dt = 0
        }
        DataStore.lastUpdateTime = currentTime
        
        //if zombie is moving to the right
        if DataStore.destination.x >= DataStore.zombie.position.x{
            DataStore.moveRight = true
            //if secondary enemy is enabled center zombie or else off center
            let pos: CGFloat = DataStore.zombie.position.x + (DataStore.secondaryEnemyEnabled ? 0 : size.width/4)
            let transitionAnimate = SKAction.moveTo(x: pos, duration: 0.5)
            
            //animate camera to follow zombie
            DataStore.cameraNode.run(transitionAnimate)
            
            //change directions of background node generated
            enumerateChildNodes(withName: "background") { node, _ in
                let background = node as! SKSpriteNode
                if background.position.x + background.size.width < self.cameraRect.origin.x {
                    background.position = CGPoint(
                        x: background.position.x + background.size.width*2,
                        y: background.position.y)
                }
            }
        }
        
        //if zombie is moving to the left
        if DataStore.destination.x < DataStore.zombie.position.x {
            DataStore.moveRight = false
            //if secondary enemy is enabled center zombie or else off center
            let pos: CGFloat = DataStore.zombie.position.x - (DataStore.secondaryEnemyEnabled ? 0 : size.width/4)
            let transitionAnimate = SKAction.moveTo(x: pos, duration: 0.5)
            
            //animate camera to follow zombie
            DataStore.cameraNode.run(transitionAnimate)
            
            //change directions of background node generated
            enumerateChildNodes(withName: "background") { node, _ in
                let background = node as! SKSpriteNode
                if background.position.x > self.cameraRect.maxX{
                    background.position = CGPoint(
                        x: background.position.x - background.size.width*2,
                        y: background.position.y)
                }
            }
        }
        //move to tapped location only. DO NOT KEEP GOING IN A DIRECTION unless hit a boundary
        if(DataStore.destination - DataStore.zombie.position).length() > (CGFloat(DataStore.dt) * DataStore.zombieMovePointsPerSec){
            move(sprite: DataStore.zombie,velocity: DataStore.velocity)
            SpawnAndAnimations.rotate(sprite: DataStore.zombie, direction: DataStore.velocity, rotateRadiansPerSecond: 3)
        }else{
            //stop walk animation
            DataStore.zombie.removeAction(forKey: "ZombieWalk")
        }
        
        //check for hit boundary
        boundsCheckZombie()

        //check for loose condition
        if DataStore.lives <= 0 && DataStore.gameOver == false{
            DataStore.gameOver = true
            DataStore.won = false
            let gameOverScene = GameOverScene(size: size)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
            if(DataStore.allowSound){
                backgroundMusicPlayer.stop()
            }
            self.removeFromParent()
            view?.presentScene(gameOverScene, transition: reveal)
            
        }
        
        //check for win condition
        if DataStore.catsInTrain >= 15 && DataStore.gameOver == false{
            DataStore.gameOver = true
            DataStore.won = true
            let gameWonScene = GameOverScene(size: size)
            gameWonScene.scaleMode = scaleMode
            let reveal = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
            if(DataStore.allowSound){
                backgroundMusicPlayer.stop()
            }
            self.removeFromParent()
            view?.presentScene(gameWonScene, transition: reveal)
        }
        
        //make train move towards zombie
        moveTrain()
    }
    
    //check for collissions after evaluating actions
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    
    //move a particular object to a particular location
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(DataStore.dt)
        sprite.position += amountToMove
    }
    
    //function used to move zombie to a particular point
    func moveZombieToward(location: CGPoint) {
        //start walk animation
        DataStore.zombie.run(SKAction.repeatForever(DataStore.zombieAnimation), withKey: "ZombieWalk")
        
        //set move parameters
        let offset = location - DataStore.zombie.position
        let direction = offset.normalized()
        DataStore.velocity = direction * DataStore.zombieMovePointsPerSec
        
    }
    //check when screen is touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //get the first instance of the rouch
        guard let touch = touches.first else {
            return
        }
            //set variables and move zombie towards touch
            let touchLocation = touch.location(in: self)
            DataStore.destination = touchLocation
            moveZombieToward(location: touchLocation)
        
            //initialize a touch marker to show
            let touchPointer = SKSpriteNode.init(imageNamed: "touchMarker")
            touchPointer.zPosition = 5.0
            touchPointer.position = touchLocation
            addChild(touchPointer)
            touchPointer.setScale(1.0)
        
            //animate the marker
            let touchDisappear = SKAction.scale(to: 0.0, duration: 0.5)
            let touchRemove = SKAction.run {
                touchPointer.removeFromParent()
            }
            let touchActions = SKAction.sequence([touchDisappear,touchRemove])
            touchPointer.run(touchActions)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //if a user presses and holds then make zombie continuouslyy move towards his touch
        for touch in touches{
            let touchLocation = touch.location(in: self)
            DataStore.destination = touchLocation
            moveZombieToward(location: touchLocation)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    func boundsCheckZombie() {
        //set constants and call function to check bounds and take necessary actions
        let bottomLeft = CGPoint(x: DataStore.zombie.size.width/2 + cameraRect.minX, y: cameraRect.minY + DataStore.zombie.size.height / 2)
        let topRight = CGPoint(x: cameraRect.maxX - DataStore.zombie.size.width / 2, y: cameraRect.maxY - DataStore.zombie.size.height / 2)
        SpawnAndAnimations.boundsCheckZombie(bottomLeft: bottomLeft, topRight: topRight)
    }
    
    //get enemy with basic parameters set from spawn and animations, set other parameters and add. also check for primary or secondary
    func spawnEnemy(type: String){
        let enemy = SpawnAndAnimations.spawnEnemy(type: type)
        
        enemy.position.y =  CGFloat.random(min: cameraRect.minY + enemy.size.height/2, max: cameraRect.maxY - enemy.size.height/2)
        
        var dest: CGFloat
        switch type {
        case "primary":
            enemy.position.x = DataStore.moveRight ? cameraRect.maxX + enemy.size.width : cameraRect.minX - enemy.size.width
            dest = DataStore.moveRight ? cameraRect.minX - enemy.size.width/2 : cameraRect.maxX + enemy.size.width/2
        case "secondary":
            enemy.position.x = DataStore.moveRight ? cameraRect.minX - enemy.size.width: cameraRect.maxX + enemy.size.width
            dest = DataStore.moveRight ? cameraRect.maxX + enemy.size.width/2 : cameraRect.minX - enemy.size.width/2
        default:
            enemy.position.x = DataStore.moveRight ? cameraRect.maxX + enemy.size.width : cameraRect.minX - enemy.size.width
            dest = DataStore.moveRight ? cameraRect.minX - enemy.size.width/2 : cameraRect.maxX + enemy.size.width/2
        }
        
        
        let  action = SKAction.moveTo(x: dest, duration: 4.0)
        
        let actionRemove = SKAction.removeFromParent()
        addChild(enemy)
        enemy.run(SKAction.sequence([action,actionRemove]))
    }
    
    func spawnCat() {
        let cat = SpawnAndAnimations.spawnCat()
        cat.position = CGPoint(
            x: CGFloat.random(min: cameraRect.minX + cat.size.width/2,
                              max: cameraRect.maxX - cat.size.width/2),
            y: CGFloat.random(min: cameraRect.minY + cat.size.height/2,
                              max: cameraRect.maxY - cat.size.height/2))
        addChild(cat)
        
        cat.run(SpawnAndAnimations.catAnimation)
    }
    
    func spawnFlower(){
        let flower = SpawnAndAnimations.spawnFlower()
        flower.position.x = CGFloat.random(min: cameraRect.minX + flower.size.width, max: cameraRect.maxX - flower.size.width)
        addChild(flower)
    }
    
    func spawnSmallFish(){
        let smallfish = SpawnAndAnimations.spawnFish(type: "small")
        smallfish.position.x = CGFloat.random(min: cameraRect.minX + smallfish.size.width, max: cameraRect.maxX - smallfish.size.width)
        addChild(smallfish)
    }
    func spawnFish(type:String){
        let fish = SpawnAndAnimations.spawnFish(type: type)
        fish.position.x = CGFloat.random(min: cameraRect.minX + fish.size.width, max: cameraRect.maxX - fish.size.width)
        addChild(fish)
    }
    
    //check collision with zombie
    func checkCollisions() {
        enumerateChildNodes(withName: "cat") { node, _ in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(DataStore.zombie.frame) || (DataStore.bigFishMode && cat.frame.intersects(DataStore.zombie.frame + 400)) {
                SpawnAndAnimations.zombieHit(object: cat,scene: self)
            }
        }
        
        enumerateChildNodes(withName: "enemy") {node, _ in
            let enemy = node as! SKSpriteNode
            if enemy.frame.intersects(DataStore.zombie.frame){
                SpawnAndAnimations.zombieHit(object: enemy, scene: self)
            }
        }
        
        enumerateChildNodes(withName: "flower") {node, _ in
            let flower = node as! SKSpriteNode
            if flower.frame.intersects(DataStore.zombie.frame){
                SpawnAndAnimations.zombieHit(object: flower, scene: self)
            }
        }
        
        enumerateChildNodes(withName: "smallFish") {node, _ in
            let smallFish = node as! SKSpriteNode
            if smallFish.frame.intersects(DataStore.zombie.frame){
                SpawnAndAnimations.zombieHit(object: smallFish, scene: self)
            }
        }
        
        enumerateChildNodes(withName: "bigFish") {node, _ in
            let bigFish = node as! SKSpriteNode
            if bigFish.frame.intersects(DataStore.zombie.frame){
                SpawnAndAnimations.zombieHit(object: bigFish, scene: self)
            }
        }
        
    }
    
    //move train of cat
    func moveTrain() {
        var targetPosition = DataStore.zombie.position
        enumerateChildNodes(withName: "train") { node, stop in
            if !node.hasActions() {
                node.xScale = DataStore.moveRight ? 1.0 : -1.0
                SpawnAndAnimations.moveCatTrain(cat: node as! SKSpriteNode, targetPosition: targetPosition)
            }
            targetPosition = node.position
        }
    }
    
    //reduce the number of cats in train
    func looseCats(){
        var looseCount = 0
        enumerateChildNodes(withName: "train"){ node, stop in
            let randomX = CGFloat.random(min: 0, max: self.size.width)
            let randomY = CGFloat.random(min: self.cameraRect.minY, max: self.cameraRect.maxY)
            node.removeAllActions()
            node.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: CGPoint(x:randomX, y:randomY), duration: 1.0),
                    SKAction.rotate(byAngle: 3.14 * 4, duration: 1.0),
                    SKAction.colorize(with: UIColor.black, colorBlendFactor: 1.0, duration: 1.0)
                    ]),
                SKAction.removeFromParent()
                ]))
            looseCount += 1
            DataStore.catsInTrain -= 1

            if looseCount >= 2{
                stop[0] = true
            }
            
        }
    }
}
