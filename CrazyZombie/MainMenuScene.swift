//
//  MainMenuScene.swift
//  CrazyZombie
//
//  Created by Deepesh Mehta on 2018-06-07.
//  Copyright © 2018 DGames. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
    
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
        DataStore.playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        DataStore.backgroundMainMenu.size = size
        DataStore.backgroundMainMenu.position = CGPoint(x: size.width/2 , y: size.height/2)
        DataStore.backgroundMainMenu.zPosition = -1
        
        SpawnAndAnimations.setPlayButton()
        DataStore.playButton.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        
        SpawnAndAnimations.setSoundButton()
        DataStore.soundButton.position = CGPoint(x: DataStore.playableRect.maxX, y: DataStore.playableRect.minY)
        
        addChild(DataStore.backgroundMainMenu)
        addChild(DataStore.playButton)
        addChild(DataStore.soundButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            if(DataStore.playButton.contains(touch.location(in: self))){
                print("Button Clicked")
                let gameScene = GameScene(size: self.size)
                gameScene.scaleMode = scaleMode
                let reveal = SKTransition.doorway(withDuration: 1.5)
                DataStore.playButton.removeFromParent()
                DataStore.backgroundMainMenu.removeFromParent()
                view?.presentScene(gameScene, transition: reveal)
            }
            
            if(DataStore.soundButton.contains(touch.location(in: self))){
                if DataStore.allowSound{
                    DataStore.allowSound = false
                    DataStore.soundButton.texture = SKTexture(imageNamed: "noSound")
                }else{
                    DataStore.allowSound = true
                    DataStore.soundButton.texture = SKTexture(imageNamed: "sound")
                }
            }
        }
    }
}
