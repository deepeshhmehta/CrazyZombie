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
        
        SpawnAndAnimations.setOptionButton(button: &DataStore.secondaryEnemyButton)
        SpawnAndAnimations.setOptionButton(button: &DataStore.smallFishButton)
        SpawnAndAnimations.setOptionButton(button: &DataStore.flowerButton)
        SpawnAndAnimations.setOptionButton(button: &DataStore.bigFishButton)
        
        DataStore.secondaryEnemyButton.position.y = DataStore.playableRect.maxY - (DataStore.secondaryEnemyButton.size.height)
        DataStore.flowerButton.position.y = DataStore.secondaryEnemyButton.position.y - (DataStore.secondaryEnemyButton.size.height + DataStore.flowerButton.size.height) * 0.75
        DataStore.smallFishButton.position.y = DataStore.flowerButton.position.y - (DataStore.flowerButton.size.height + DataStore.smallFishButton.size.height) * 0.75
        DataStore.bigFishButton.position.y = DataStore.smallFishButton.position.y - (DataStore.smallFishButton.size.height + DataStore.bigFishButton.size.height) * 0.75
        
        addChild(DataStore.backgroundMainMenu)
        addChild(DataStore.playButton)
        addChild(DataStore.soundButton)
        addChild(DataStore.secondaryEnemyButton)
        addChild(DataStore.smallFishButton)
        addChild(DataStore.bigFishButton)
        addChild(DataStore.flowerButton)
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
            
            if(DataStore.secondaryEnemyButton.contains(touch.location(in: self))){
                DataStore.secondaryEnemyEnabled = !DataStore.secondaryEnemyEnabled
                
                let colourAction = SKAction.colorize(with:  UIColor.green, colorBlendFactor: DataStore.secondaryEnemyEnabled ? 1.0 : 0.0, duration: 0.0)
                DataStore.secondaryEnemyButton.run(colourAction)
            }
            
            if(DataStore.flowerButton.contains(touch.location(in: self))){
                DataStore.flowerEnabled = !DataStore.flowerEnabled
                
                let colourAction = SKAction.colorize(with:  UIColor.green, colorBlendFactor: DataStore.flowerEnabled ? 1.0 : 0.0, duration: 0.0)
                DataStore.flowerButton.run(colourAction)
            }
            
            if(DataStore.smallFishButton.contains(touch.location(in: self))){
                DataStore.smallFishEnabled = !DataStore.smallFishEnabled
                
                let colourAction = SKAction.colorize(with:  UIColor.green, colorBlendFactor: DataStore.smallFishEnabled ? 1.0 : 0.0, duration: 0.0)
                DataStore.smallFishButton.run(colourAction)
            }
            
            if(DataStore.bigFishButton.contains(touch.location(in: self))){
                DataStore.bigFishEnabled = !DataStore.bigFishEnabled
                
                let colourAction = SKAction.colorize(with:  UIColor.green, colorBlendFactor: DataStore.bigFishEnabled ? 1.0 : 0.0, duration: 0.0)
                DataStore.bigFishButton.run(colourAction)
            }
        }
    }
}
