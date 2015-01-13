//
//  Chain.swift
//  CookieCrush
//
//  Created by Dennis Li on 12/16/14.
//  Copyright (c) 2014 Dennis Li. All rights reserved.
//

import Foundation


class Chain: Hashable, Printable {
    var score = 0
    var cookies = [Cookie]()
    
    enum ChainType: Printable {
        case Horizontal
        case Vertical
    
        var description: String {
            switch self {
                case .Horizontal: return "Horizontal"
                case .Vertical: return "Vertical"
            }
        }
    }
    
    var chainType: ChainType
    
    init(chainType: ChainType) {
        self.chainType = chainType
    }
    
    func addCookie(cookie: Cookie) {
        cookies.append(cookie)
    }
    
    func firstCookie() -> Cookie {
        return cookies[0]
    }
    
    func lastCookie() -> Cookie {
        return cookies[cookies.count - 1]
    }
    
    func length() -> Int {
        return cookies.count
    }
    
    var description: String {
        return "type:\(chainType) cookies:\(cookies)"
    }
    
    var hashValue: Int {
        return reduce(cookies, 0) {
            $0.hashValue ^ $1.hashValue
        }
    }
    
    func clearCookies() {
        self.cookies = [Cookie]()
    }
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
    return lhs.cookies == rhs.cookies
}
