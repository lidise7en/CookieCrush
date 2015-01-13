//
//  Cookie.swift
//  CookieCrush
//
//  Created by Dennis Li on 12/14/14.
//  Copyright (c) 2014 Dennis Li. All rights reserved.
//

import SpriteKit

enum CookieType: Int, Printable {
    case Unknown = 0, Croissant, Cupcake, Danish, Donut, Macaroon, SugarCookie, Croissant_Combo,
        Cupcake_Combo, Danish_Combo, Donut_Combo, Macaroon_Combo, SugarCookie_Combo
    
    var spriteName: String {
        if rawValue == 0 {
            return "Unknown"
        }
        
        let spriteNames = [
            "Croissant",
            "Cupcake",
            "Danish",
            "Donut",
            "Macaroon",
            "SugarCookie",
            "Croissant_Combo",
            "Cupcake_Combo",
            "Danish_Combo",
            "Donut_Combo",
            "Macaroon_Combo",
            "SugarCookie_Combo"]
        
        return spriteNames[rawValue - 1]
    }
    
    var description: String {
        return spriteName
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    static func random() -> CookieType {
        return CookieType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
}

func == (lhs: CookieType, rhs: CookieType) -> Bool {

    var desOne = lhs.description
    var desTwo = rhs.description
    if desOne == desTwo {
        return true
    } else if (desOne.hasPrefix(desTwo)) {
        return true
    } else if (desTwo.hasPrefix(desOne)) {
        return true
    }
    return false
}

class Cookie: Hashable, Printable {
    var column: Int
    var row: Int
    var cookieType: CookieType
    var sprite: SKSpriteNode?
    var hashValue: Int {return row * 10 + column}
    
    var description: String {
        return "type:\(cookieType) square:(\(column),\(row))"
    }
    
    init(column: Int, row: Int, cookieType: CookieType) {
        self.column = column
        self.row = row
        self.cookieType = cookieType
    }
    
    func setType(cookietype: CookieType) {
        self.cookieType = cookietype
    }
    
    func changeTypeToCombo() {
        if self.cookieType == CookieType.Croissant {
            self.cookieType = CookieType.Croissant_Combo
        } else if self.cookieType == CookieType.Cupcake {
            self.cookieType = CookieType.Cupcake_Combo
        } else if self.cookieType == CookieType.Danish {
            self.cookieType = CookieType.Danish_Combo
        } else if self.cookieType == CookieType.Donut {
            self.cookieType = CookieType.Donut_Combo
        } else if self.cookieType == CookieType.Macaroon {
            self.cookieType = CookieType.Macaroon_Combo
        } else if self.cookieType == CookieType.SugarCookie {
            self.cookieType = CookieType.SugarCookie_Combo
        }
    }
}

func == (lhs: Cookie, rhs: Cookie) -> Bool { return lhs.column == rhs.column && lhs.row == rhs.row }
