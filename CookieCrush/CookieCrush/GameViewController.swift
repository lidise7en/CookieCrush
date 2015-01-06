//
//  GameViewController.swift
//  CookieCrush
//
//  Created by Dennis Li on 12/14/14.
//  Copyright (c) 2014 Dennis Li. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var scene: GameScene!
    var level: Level!
    var movesLeft = 0
    var scores = 0
    var gestureTapRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var target: UILabel!

    @IBOutlet weak var movs: UILabel!
    
    @IBOutlet weak var score: UILabel!
    
    @IBOutlet weak var GameOverBanner: UIImageView!
    func beginGame() {
        movesLeft = level.maxMoves
        scores = 0
        updateLabels()
        shuffle()
    }
    
    func shuffle() {
        let newCookies = level.shuffle()
        scene.addSpritesForCookies(newCookies)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as SKView
        skView.multipleTouchEnabled = false
        
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        scene.swipeHandler = handleSwipe
        
        level = Level(filename: "Level_1")
        scene.level = level
        scene.addTiles()
        GameOverBanner.hidden = true
        skView.presentScene(scene)
        
        beginGame()
        
    }
    
    func handleSwipe(swap: Swap) {
        view.userInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.perforSwap(swap)
            scene.animateSwap(swap, completion: handleMatches)
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.userInteractionEnabled = true
            }
        }
    }
    
    func handleMatches() {
        let chains = level.removeMatches()
        if chains.count == 0 {
            self.beginNextTurn()
            return
        }
        scene.animateMatchedCookies(chains) {
            for chain in chains {
                self.scores += chain.score
            }
            self.updateLabels()
            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies(columns) {
                let columns = self.level.topUpCookies()
                self.scene.animateNewCookies(columns) {
                    self.handleMatches()
                }
            }
        }
    }
    
    func beginNextTurn() {
        level.resetComboNum()
        level.detectPossibleSwaps()
        view.userInteractionEnabled = true
        decreseMove()
    }
    
    func updateLabels() {
        target.text = NSString(format: "%ld", level.targetScore)
        movs.text = NSString(format: "%ld", movesLeft)
        score.text = NSString(format: "%ld", scores)
    }
    
    func showGameOver() {
        GameOverBanner.hidden = false
        scene.userInteractionEnabled = false
        gestureTapRecognizer = UITapGestureRecognizer(target: self, action: "hideGameOver")
        view.addGestureRecognizer(gestureTapRecognizer)
        
    }
    
    func hideGameOver() {
        view.removeGestureRecognizer(gestureTapRecognizer)
        gestureTapRecognizer = nil
        
        GameOverBanner.hidden = true
        scene.userInteractionEnabled = true
        beginGame()
    }
    
    func decreseMove() {
        movesLeft -= 1
        updateLabels()
        if scores > level.targetScore {
            GameOverBanner.image = UIImage(named: "LevelComplete")
            showGameOver()
        } else if movesLeft == 0 {
            GameOverBanner.image = UIImage(named: "GameOver")
            showGameOver()
        }
    }
}
