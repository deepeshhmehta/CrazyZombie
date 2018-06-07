//
//  MainMenuScene.swift
//  CrazyZombie
//
//  Created by Deepesh Mehta on 2018-06-07.
//  Copyright © 2018 DGames. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    var button : SKSpriteNode = SKSpriteNode.init(imageNamed: "play_button")
    var soundButton : SKSpriteNode = SKSpriteNode.init(imageNamed: "sound")
    var allowSound : Bool = true
    let background = SKSpriteNode.init(imageNamed: "MainMenu")
    var playableRect : CGRect = CGRect(x:0, y:0, width: 0, height: 0)
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        let maxAspectRatio : CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = ( size.height - playableHeight )/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        background.size = size
        background.position = CGPoint(x: size.width/2 , y: size.height/2)
        background.zPosition = -1
        
        button.setScale(0.8)
        let buttonFirstAction = SKAction.scale(by: 0.5, duration: 0.5)
        let delay = SKAction.wait(forDuration: 0.2)
        let buttonSecondAction = buttonFirstAction.reversed()
        let buttonActionSequence = SKAction.sequence([buttonFirstAction,delay,buttonSecondAction,delay])
        button.run(SKAction.repeatForever(buttonActionSequence))
        button.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        button.zPosition = 10
        
        soundButton.anchorPoint = CGPoint(x: 1, y: 0)
        soundButton.position = CGPoint(x: playableRect.maxX, y: playableRect.minY)
        soundButton.zPosition = 10
        
        addChild(background)
        addChild(button)
        addChild(soundButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            if(button.contains(touch.location(in: self))){
                print("Button Clicked")
                let gameScene = GameScene(size: self.size)
                gameScene.scaleMode = scaleMode
                let reveal = SKTransition.doorway(withDuration: 1.5)
                button.removeFromParent()
                background.removeFromParent()
                view?.presentScene(gameScene, transition: reveal)
            }
            
            if(soundButton.contains(touch.location(in: self))){
                if allowSound{
                    allowSound = false
                    soundButton.texture = SKTexture(imageNamed: "noSound")
                }else{
                    allowSound = true
                    soundButton.texture = SKTexture(imageNamed: "sound")
                }
            }
        }
    }
}
