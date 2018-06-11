//
//  MainMenuScene.swift
//  CrazyZombie
//
//  Created by Deepesh Mehta on 2018-06-07.
//  Copyright © 2018 DGames. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    //run this code when this scene opens
    override func didMove(to view: SKView) {
        
        //set up playable rectange
        let maxAspectRatio : CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = ( size.height - playableHeight )/2.0
        DataStore.playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        //set up background
        DataStore.backgroundMainMenu.size = size
        DataStore.backgroundMainMenu.position = CGPoint(x: size.width/2 , y: size.height/2)
        DataStore.backgroundMainMenu.zPosition = -1
        
        //setup play button
        SpawnAndAnimations.setPlayButton()
        DataStore.playButton.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        
        //setup sound button
        SpawnAndAnimations.setSoundButton()
        DataStore.soundButton.position = CGPoint(x: DataStore.playableRect.maxX, y: DataStore.playableRect.minY)
        
        //setup all option buttons
        SpawnAndAnimations.setOptionButton(button: &DataStore.secondaryEnemyButton)
        SpawnAndAnimations.setOptionButton(button: &DataStore.smallFishButton)
        SpawnAndAnimations.setOptionButton(button: &DataStore.flowerButton)
        SpawnAndAnimations.setOptionButton(button: &DataStore.bigFishButton)
        
        //set up playablerect specific y position
        DataStore.secondaryEnemyButton.position.y = DataStore.playableRect.maxY - (DataStore.secondaryEnemyButton.size.height)
        DataStore.flowerButton.position.y = DataStore.secondaryEnemyButton.position.y - (DataStore.secondaryEnemyButton.size.height + DataStore.flowerButton.size.height) * 0.75
        DataStore.smallFishButton.position.y = DataStore.flowerButton.position.y - (DataStore.flowerButton.size.height + DataStore.smallFishButton.size.height) * 0.75
        DataStore.bigFishButton.position.y = DataStore.smallFishButton.position.y - (DataStore.smallFishButton.size.height + DataStore.bigFishButton.size.height) * 0.75
        
        //add all elements to the scene
        addChild(DataStore.backgroundMainMenu)
        addChild(DataStore.playButton)
        addChild(DataStore.soundButton)
        addChild(DataStore.secondaryEnemyButton)
        addChild(DataStore.smallFishButton)
        addChild(DataStore.bigFishButton)
        addChild(DataStore.flowerButton)
    }
    
    //did not implement in touches began because then user might undo selection when releasing finger
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            checkTouches(touch: touch)
        }
    }
    
    func checkTouches(touch: UITouch){
        if(DataStore.playButton.contains(touch.location(in: self))){
            let gameScene = GameScene(size: self.size)
            gameScene.scaleMode = scaleMode
            let reveal = SKTransition.doorway(withDuration: 1.5)
            DataStore.playButton.removeFromParent()
            DataStore.backgroundMainMenu.removeFromParent()
            view?.presentScene(gameScene, transition: reveal)
        }
        SpawnAndAnimations.checkOptionButtonClicked(touch: touch, scene: self)
    }
}
