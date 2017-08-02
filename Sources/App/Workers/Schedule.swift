//
//  Schedule.swift
//  BullRun-Server
//
//  Created by Jonathan Green on 7/31/17.
//
//

import Foundation
import Jobs
import Vapor
class Schedule {
    
    let delay:Double = 600.0
    var drop:Droplet!

    init(drop:Droplet) {
        
        self.drop = drop
    }
    
    func seconds() {
        
        Jobs.add(interval: .seconds(2)) {
            
            var oldCoins:[Coin] = []
            var winningBets:Double = 0
            var pool:Double = 0
            var payouts:Double = 0
            var winingPlayers:[(String,Double)] = []
            
            ///payouts
            let round = MongoClient().lastHourRound()
            
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
                pool = pool - BOOK_PAY
                //////////////////
                
                for player in winingPlayers {
                    
                    let payout = Math().payout(winningBets: winningBets, currentBet: player.1, pool: pool, stake: stake)
                    
                    payouts += payout
                }
                
                let check = Math().payoutAmountCheck(payouts: payouts, pool: pool)
                
                print("paid out correct amount: \(check)")
                
                MongoClient().deleteHourBets()
            }
            
            let top10 = Ripple(drop: self.drop).top10()
            
            MongoClient().saveHourRound(coins:top10)
        }
    }
    
    func hourRound() {
        
        Jobs.delay(by: .seconds(delay), interval: .seconds(3600)) {
            
            var oldCoins:[Coin] = []
            var winningBets:Double = 0
            var pool:Double = 0
            var payouts:Double = 0
            var winingPlayers:[(String,Double)] = []
            
            ///payouts
            let round = MongoClient().lastHourRound()
            
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
                pool = pool - BOOK_PAY
                //////////////////
                
                for player in winingPlayers {
                    
                    
                    let payout = Math().payout(winningBets: winningBets, currentBet: player.1, pool: pool, stake: stake)
                    
                    payouts += payout
                }
                
                let check = Math().payoutAmountCheck(payouts: payouts, pool: pool)
                
                print("paid out correct amount: \(check)")
                
                MongoClient().deleteHourBets()
            }
            
            let top10 = Ripple(drop: self.drop).top10()
            
            MongoClient().saveHourRound(coins:top10)
        }
        
    }
    
    func dayRound() {
        
        Jobs.delay(by: .seconds(delay), interval: .days(1)) {
            
            var oldCoins:[Coin] = []
            var winningBets:Double = 0
            var pool:Double = 0
            var payouts:Double = 0
            var winingPlayers:[(String,Double)] = []
            
            ///payouts
            let round = MongoClient().lastDayRound()
            
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
                pool = pool - BOOK_PAY
                //////////////////
                
                for player in winingPlayers {
                    
                    let payout = Math().payout(winningBets: winningBets, currentBet: player.1, pool: pool, stake: stake)
                    
                    payouts += payout
                }
                
                let check = Math().payoutAmountCheck(payouts: payouts, pool: pool)
                
                print("paid out correct amount: \(check)")
                
                MongoClient().deleteDayBets()
            }
            
            let top10 = Ripple(drop: self.drop).top10()
            
            MongoClient().saveDayRound(coins:top10)
            
            
        }
    }
    
    func weekRound() {
        
        Jobs.delay(by: .seconds(delay), interval: .weeks(1)) {
            
            var oldCoins:[Coin] = []
            var winningBets:Double = 0
            var pool:Double = 0
            var payouts:Double = 0
            var winingPlayers:[(String,Double)] = []
            
            ///payouts
            let round = MongoClient().lastWeekRound()
            
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
                pool = pool - BOOK_PAY
                //////////////////
                
                for player in winingPlayers {
                    
                    let payout = Math().payout(winningBets: winningBets, currentBet: player.1, pool: pool, stake: stake)
                    
                    payouts += payout
                }
                
                let check = Math().payoutAmountCheck(payouts: payouts, pool: pool)
                
                print("paid out correct amount: \(check)")
                
                MongoClient().deleteWeekBets()
            }
            
            let top10 = Ripple(drop: self.drop).top10()
            
            MongoClient().saveWeekRound(coins:top10)
        }
    }
}

