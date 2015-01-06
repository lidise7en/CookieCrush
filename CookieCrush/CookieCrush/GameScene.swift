//
//  GameScene.swift
//  CookieCrush
//
//  Created by Dennis Li on 12/14/14.
//  Copyright (c) 2014 Dennis Li. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    var level: Level!
    var swipeFromColumn: Int?
    var swipeFromRow: Int?
    var swipeHandler: ((Swap) ->())?
    var selectionSprite = SKSpriteNode()
    
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let cookiesLayer = SKNode()
    let tilesLayer = SKNode()
    
    let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
    let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
    let fallingCookieSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
    let addCookieSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
    
    
    
    override init(size: CGSize) {
        SKLabelNode(fontNamed: "GillSans-BoldItalic")
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let background = SKSpriteNode(imageNamed: "Background")
        addChild(background)
        
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        cookiesLayer.position = layerPosition
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        gameLayer.addChild(cookiesLayer)
        swipeFromColumn = nil
        swipeFromRow = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSpritesForCookies(cookies: Set<Cookie>) {
        for cookie in cookies {
            let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            sprite.position = pointForColumn(cookie.column, row: cookie.row)
            cookiesLayer.addChild(sprite)
            cookie.sprite = sprite
        }
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns) * TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows) * TileHeight {
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        }
        return (false, 0, 0)
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x:CGFloat(column) * TileWidth + TileWidth / 2,
            y:CGFloat(row) * TileHeight + TileHeight / 2
        )
    }
    
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let tile = level.tileAtColumn(column, row: row) {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.position = pointForColumn(column, row: row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(cookiesLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            if let cookie = level.cookieAtColumn(column, row: row) {
                showSelectionIndicatorForCookie(cookie)
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if swipeFromColumn == nil {
            return
        }
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(cookiesLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            var horizDelta = 0, vertiDelta = 0
            if column < swipeFromColumn! {
                horizDelta = -1
            } else if column > swipeFromColumn! {
                horizDelta = 1
            } else if row < swipeFromRow! {
                vertiDelta = -1
            } else if row > swipeFromRow! {
                vertiDelta = 1
            }
            
            if horizDelta != 0 || vertiDelta != 0 {
                trySwapCookie(horizDelta, vertical: vertiDelta)
                hideSelecionIndicator()
                swipeFromRow = nil
                swipeFromColumn = nil
            }
        }
    
    }
    
    func trySwapCookie(horizen: Int, vertical: Int) {
        let toColumn = swipeFromColumn! + horizen
        let toRow = swipeFromRow! + vertical
        
        if toColumn < 0 || toColumn >= NumColumns ||
            toRow < 0 || toRow >= NumRows {
            return
        }
        
        if let toCookie = level.cookieAtColumn(toColumn, row: toRow) {
            if let fromCookie = level.cookieAtColumn(swipeFromColumn!, row: swipeFromRow!) {
                //println("*** swapping \(fromCookie) with \(toCookie)")
                if let handler = swipeHandler {
                    let swapObj = Swap(cookieA: fromCookie, cookieB: toCookie)
                    handler(swapObj)
                }
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if selectionSprite.parent != nil && swipeFromColumn != nil {
            hideSelecionIndicator()
        }
        swipeFromRow = nil
        swipeFromColumn = nil
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        touchesEnded(touches, withEvent: event)
    }
    
    func animateSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: NSTimeInterval = 0.3
        
        let moveA = SKAction.moveTo(spriteB.position, duration: duration)
        moveA.timingMode = .EaseOut
        spriteA.runAction(moveA, completion: completion)
        
        let moveB = SKAction.moveTo(spriteA.position, duration: duration)
        moveB.timingMode = .EaseOut
        spriteB.runAction(moveB)
        
        runAction(swapSound)
        
    }
    
    func animateInvalidSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: NSTimeInterval = 0.2
        
        let moveA = SKAction.moveTo(spriteB.position, duration: duration)
        moveA.timingMode = .EaseOut
        
        let moveB = SKAction.moveTo(spriteA.position, duration: duration)
        moveB.timingMode = .EaseOut
        
        spriteA.runAction(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.runAction(SKAction.sequence([moveB, moveA]))
        
        runAction(invalidSwapSound)
    }
    
    func showSelectionIndicatorForCookie(cookie: Cookie) {
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        if let sprite = cookie.sprite {
            let texture = SKTexture(imageNamed: cookie.cookieType.highlightedSpriteName)
            selectionSprite.size = texture.size()
            selectionSprite.runAction(SKAction.setTexture(texture))
            
            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
        }
    }
    
    func hideSelecionIndicator() {
        selectionSprite.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(0.3),
            SKAction.removeFromParent()]))
    }
    
    func animateMatchedCookies(chains: Set<Chain>, completion: () -> ()) {
        for chain in chains {
            animateScoreForChain(chain)
            for cookie in chain.cookies {
                if let sprite = cookie.sprite {
                    if sprite.actionForKey("removing") == nil {
                        let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
                        scaleAction.timingMode = .EaseOut
                        sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]), withKey: "removing")
                    }
                }
            }
        }
        runAction(matchSound)
        runAction(SKAction.waitForDuration(0.3), completion: completion)
    }
    
    func animateFallingCookies(columns: [[Cookie]], completion: () -> ()) {
        var longestDuration: NSTimeInterval = 0
        for array in columns {
            for (idx, value) in enumerate(array) {
                let newPos = pointForColumn(value.column, row: value.row)
                let delay = 0.05 + 0.15 * NSTimeInterval(idx)
                let sprite = value.sprite!
                let duration = NSTimeInterval((sprite.position.y - newPos.y) / TileHeight * 0.1)
                
                longestDuration = max(longestDuration, delay + duration)
                
                let moveAction = SKAction.moveTo(newPos, duration: duration)
                
                moveAction.timingMode = .EaseOut
                
                sprite.runAction(SKAction.sequence([SKAction.waitForDuration(delay), SKAction.group([moveAction, fallingCookieSound])]))
                
            }
        }
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }
    
    func animateNewCookies(columns: [[Cookie]], completion: () -> ()) {
        var longestDuration: NSTimeInterval = 0
        
        for array in columns {
            let startRow = array[0].row + 1
            for (idx, cookie) in enumerate(array) {
                let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
                sprite.position = pointForColumn(cookie.column, row: startRow)
                cookiesLayer.addChild(sprite)
                cookie.sprite = sprite
                
                let delay = 0.1 + 0.2 * NSTimeInterval(array.count - idx - 1)
                
                let duration = NSTimeInterval(startRow - cookie.row) * 0.1
                longestDuration = max(longestDuration, duration + delay)
                
                let newPos = pointForColumn(cookie.column, row: cookie.row)
                let moveAction = SKAction.moveTo(newPos, duration: duration)
                moveAction.timingMode = .EaseOut
                
                sprite.alpha = 0
                sprite.runAction(SKAction.sequence([SKAction.waitForDuration(delay),
                    SKAction.group([SKAction.fadeInWithDuration(0.05),
                    moveAction,
                    addCookieSound])]))
            }
        }
        runAction(SKAction.waitForDuration(longestDuration), completion)
    }
    
    func animateScoreForChain(chain: Chain) {
        let firstSprite = chain.firstCookie().sprite!
        let lastSprite = chain.lastCookie().sprite!
        
        let centerPos = CGPoint(
            x: (firstSprite.position.x + lastSprite.position.x) / 2,
            y: (firstSprite.position.y + lastSprite.position.y) / 2 - 8)
        
        let scoreLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
        scoreLabel.fontSize = 16
        scoreLabel.text = NSString(format: "%ld", chain.score)
        scoreLabel.position = centerPos
        scoreLabel.zPosition = 300
        cookiesLayer.addChild(scoreLabel)
        
        let moveAction = SKAction.moveBy(CGVector(dx: 0, dy: 3), duration: 0.7)
        moveAction.timingMode = .EaseOut
        scoreLabel.runAction(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }
}
