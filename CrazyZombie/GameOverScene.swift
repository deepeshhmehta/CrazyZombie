//
//  GameOverScene.swift
//  CrazyZombie
//
//  Created by Deepesh Mehta on 2018-06-06.
//  Copyright © 2018 DGames. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameOverScene: SKScene{
    var won : Bool = false
    init(size: CGSize, won: Bool) {
        super.init(size: size)
        self.won = won
    }
    
    
    required init (coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        let showImage = SKSpriteNode.init(imageNamed: won ? "YouWin" : "YouLose")
        showImage.size.width = self.size.width
        showImage.size.height = self.size.height
        showImage.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(showImage)
        
        let sound = SKAction.playSoundFileNamed(won ? "win.wav" : "lose.wav", waitForCompletion: false)
        
        let timer = SKAction.wait(forDuration: 3.0)
        let action = SKAction.run {
            let mainMenuScene = MainMenuScene(size: self.size)
            mainMenuScene.scaleMode = self.scaleMode
            // 2
            let reveal = SKTransition.doorsCloseVertical(withDuration: 0.5)
            // 3
            view.presentScene(mainMenuScene, transition: reveal)
        }
        let seq = SKAction.sequence(DataStore.allowSound ? [sound,timer,action] : [timer,action])
        run(seq)
    }
        

}
