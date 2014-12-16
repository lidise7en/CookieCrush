//
//  swap.swift
//  CookieCrush
//
//  Created by Dennis Li on 12/15/14.
//  Copyright (c) 2014 Dennis Li. All rights reserved.
//

import Foundation


struct Swap: Printable, Hashable {
    let cookieA: Cookie
    let cookieB: Cookie
    var hashValue: Int {
        return cookieA.hashValue * cookieB.hashValue
    }
    
    init(cookieA: Cookie, cookieB: Cookie) {
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
}

func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.cookieA == rhs.cookieA && lhs.cookieB == rhs.cookieB) ||
    (lhs.cookieB == rhs.cookieA && lhs.cookieA == rhs.cookieB)
}