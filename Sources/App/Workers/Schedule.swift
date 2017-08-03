//
//  Schedule.swift
//  BullRun-Server
//
//  Created by Jonathan Green on 7/31/17.
//
//

import Foundation
import Vapor
import MongoKitten
class Schedule {
    
    let delay:Double = 600.0
    var drop:Droplet!
    var database:Database!

    init(drop:Droplet,database:Database) {
        
        self.database = database
        self.drop = drop
    }
    
    func hourRound() {
        
        var oldCoins:[Coin] = []
        var winningBets:Double = 0
        var pool:Double = 0
        var payouts:Double = 0
        var winingPlayers:[(String,Double)] = []
        var currentRoundAddress:String = ""
        var currentRoundSecret:String = ""
        
        ///payouts
        let round = MongoClient(database: database).lastHourRound()
        
        let decryptAddress = MongoClient(database: database).decrypt(text: String(describing: round.2["address"]!))
        let decryptSecert = MongoClient(database: database).decrypt(text: String(describing: round.2["secret"]!))
        
        currentRoundAddress = decryptAddress
        currentRoundSecret = decryptSecert
        
        if round.1.count != 0 {
            
            for coin in round.0 {
                
                let result = String(coin["coin"])
                
                let oldCoin = Ripple(drop: self.drop).getCoin(coinId: result!)
                print(oldCoin.id)
                oldCoins.append(oldCoin)
            }
            
            let winners = Math().winners1hr(coins: oldCoins)
            
            for winningId in winners.0 {
                
                for player in round.1 {
                    
                    let address = String(player["address"])
                    let coin = String(player["coin"])
                    let bet = Double(player["amount"])
                    
                    pool += bet!
                    
                    if coin == winningId {
                        
                        winningBets += (bet!/stake)
                        let win:(String,Double) = (address!,bet!)
                        winingPlayers.append(win)
                        
                    }
                }
            }
            
            ///pay myself fee
            let BOOK_PAY = pool * fee
            if winingPlayers.count == 0 {
                
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET, secret: currentRoundSecret, amount: String(pool))
                
                pool = pool - pool
                
            }else {
                
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET, secret: currentRoundSecret, amount: String(BOOK_PAY))
                
                pool = pool - BOOK_PAY
            }
            
            //////////////////
            
            for player in winingPlayers {
                
                let payout = Math().payout(winningBets: winningBets, currentBet: player.1, pool: pool, stake: stake)
                
                payouts += payout
                
                print("paided out \(payout) to address \(player.0)")
                MongoClient(database: database).savePayout(address: player.0, amount: payout)
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: player.0, secret: currentRoundSecret, amount: String(payout))
            }
            
            let check = Math().payoutAmountCheck(payouts: payouts, pool: pool)
            
            print("paid out correct amount: \(check), payouts:\(payouts),pool:\(pool)")
            
            MongoClient(database: database).deleteHourBets()
        }
        
        let top10 = Ripple(drop: self.drop).top10()
        
        MongoClient(database: database).saveHourRound(coins:top10)
        
    }
    
    func dayRound() {
        
        var oldCoins:[Coin] = []
        var winningBets:Double = 0
        var pool:Double = 0
        var payouts:Double = 0
        var winingPlayers:[(String,Double)] = []
        var currentRoundAddress:String = ""
        var currentRoundSecret:String = ""
        
        ///payouts
        let round = MongoClient(database: database).lastDayRound()
        
        let decryptAddress = MongoClient(database: database).decrypt(text: String(describing: round.2["address"]!))
        let decryptSecert = MongoClient(database: database).decrypt(text: String(describing: round.2["secret"]!))

        currentRoundAddress = decryptAddress
        currentRoundSecret = decryptSecert
        
        if round.1.count != 0 {
            
            for coin in round.0 {
                
                let result = String(coin["coin"])
                
                
                let oldCoin = Ripple(drop: self.drop).getCoin(coinId: result!)
                print(oldCoin.id)
                oldCoins.append(oldCoin)
            }
            
            let winners = Math().winner24hr(coins: oldCoins)
            
            for winningId in winners.0 {
                
                for player in round.1 {
                    
                    let address = String(player["address"])
                    let coin = String(player["coin"])
                    let bet = Double(player["amount"])
                    
                    pool += bet!
                    
                    if coin == winningId {
                        
                        winningBets += (bet!/stake)
                        let win:(String,Double) = (address!,bet!)
                        winingPlayers.append(win)
                        
                    }
                }
            }
            
            ///pay myself fee
            let BOOK_PAY = pool * fee
            if winingPlayers.count == 0 {
                
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET, secret: currentRoundSecret, amount: String(pool))
                
                pool = pool - pool
                
            }else {
                
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET, secret: currentRoundSecret, amount: String(BOOK_PAY))
                
                pool = pool - BOOK_PAY
            }
            
            //////////////////
            
            for player in winingPlayers {
                
                let payout = Math().payout(winningBets: winningBets, currentBet: player.1, pool: pool, stake: stake)
                
                payouts += payout
                
                print("paided out \(payout) to address \(player.0)")
                MongoClient(database: database).savePayout(address: player.0, amount: payout)
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: player.0, secret: currentRoundSecret, amount: String(payout))
            }
            
            let check = Math().payoutAmountCheck(payouts: payouts, pool: pool)
            
            print("paid out correct amount: \(check), payouts:\(payouts),pool:\(pool)")
            
            MongoClient(database: database).deleteDayBets()
        }
        
        let top10 = Ripple(drop: self.drop).top10()
        
        MongoClient(database: database).saveDayRound(coins:top10)
    }
    
    func weekRound() {
        
        var oldCoins:[Coin] = []
        var winningBets:Double = 0
        var pool:Double = 0
        var payouts:Double = 0
        var winingPlayers:[(String,Double)] = []
        var currentRoundAddress:String = ""
        var currentRoundSecret:String = ""
        
        ///payouts
        let round = MongoClient(database: database).lastWeekRound()
        
        let decryptAddress = MongoClient(database: database).decrypt(text: String(describing: round.2["address"]!))
        let decryptSecert = MongoClient(database: database).decrypt(text: String(describing: round.2["secret"]!))
        
        currentRoundAddress = decryptAddress
        currentRoundSecret = decryptSecert
        
        if round.1.count != 0 {
            
            for coin in round.0 {
                
                let result = String(coin["coin"])
                
                
                let oldCoin = Ripple(drop: self.drop).getCoin(coinId: result!)
                print(oldCoin.id)
                oldCoins.append(oldCoin)
            }
            
            let winners = Math().winnerWeek(coins: oldCoins)
            
            for winningId in winners.0 {
                
                for player in round.1 {
                    
                    let address = String(player["address"])
                    let coin = String(player["coin"])
                    let bet = Double(player["amount"])
                    
                    pool += bet!
                    
                    if coin == winningId {
                        
                        winningBets += (bet!/stake)
                        let win:(String,Double) = (address!,bet!)
                        winingPlayers.append(win)
                        
                    }
                }
            }
            
            ///pay myself fee
            let BOOK_PAY = pool * fee
            
            if winingPlayers.count == 0 {
                
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET, secret: currentRoundSecret, amount: String(pool))
                
                pool = pool - pool
                
            }else {
                
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET, secret: currentRoundSecret, amount: String(BOOK_PAY))
                
                pool = pool - BOOK_PAY
            }
            
            //////////////////
            
            for player in winingPlayers {
                
                let payout = Math().payout(winningBets: winningBets, currentBet: player.1, pool: pool, stake: stake)
                
                payouts += payout
                
                print("paided out \(payout) to address \(player.0)")
                MongoClient(database: database).savePayout(address: player.0, amount: payout)
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: player.0, secret: currentRoundSecret, amount: String(payout))
            }
            
            let check = Math().payoutAmountCheck(payouts: payouts, pool: pool)
            
            print("paid out correct amount: \(check), payouts:\(payouts),pool:\(pool)")
            
            MongoClient(database: database).deleteWeekBets()
        }
        
        let top10 = Ripple(drop: self.drop).top10()
        
        MongoClient(database: database).saveWeekRound(coins:top10)
    }
}

