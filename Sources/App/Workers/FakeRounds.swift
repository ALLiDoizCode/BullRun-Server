//
//  FakeRounds.swift
//  BullRun-Server
//
//  Created by Jonathan Green on 8/1/17.
//
//

import Foundation
import Vapor

func bet(coins:[Coin],drop:Droplet) {
    
    let randomNum1:Int = Int(arc4random_uniform(UInt32(coins.count)))
    let randomNum2:Int = Int(arc4random_uniform(UInt32(coins.count)))
 
    
    let bet1 = Wallet()
    bet1.address = address1
    bet1.hourBet.amount = amount
    bet1.hourBet.coinId = coins[randomNum1].id
    
    let bet2 = Wallet()
    bet2.address = address1
    bet2.hourBet.amount = amount
    bet2.hourBet.coinId = coins[randomNum1].id
    
    for _ in 0 ..< 10 {
        
        let randomNum:Int = Int(arc4random_uniform(UInt32(coins.count)))
        
        let bet = Wallet()
        bet.address = address2
        bet.hourBet.amount = amount
        bet.hourBet.coinId = coins[randomNum].id
        Ripple(drop: drop).send(address1: address2, address2: address1, secret: secert2, amount: String(amount))
        MongoClient().saveHourBet(wallet: bet)
    }
    
    MongoClient().saveHourBet(wallet: bet1)
    MongoClient().saveHourBet(wallet: bet2)
}
