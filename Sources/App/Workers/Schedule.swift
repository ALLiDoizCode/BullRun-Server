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
        
        Jobs.add(interval: .seconds(5)) {
            
            var oldCoins:[Coin] = []
            var winningBets:Double = 0
            var pool:Double = 0
            var payouts:Double = 0
            var winingPlayers:[(String,Double)] = []
            var currentRoundAddress:String = ""
            var currentRoundSecret:String = ""
            
            ///payouts
            let round = MongoClient().lastHourRound()
        
            if round.0.count != 0 {
                
                currentRoundAddress = String(describing: round.2["address"])
                currentRoundSecret = String(describing: round.2["secret"])
                
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
                    
                    print("paided out \(payout) to address \(player.0)")
                    
                    if player.0 == address2 {
                        
                        Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: player.0, secret: currentRoundSecret, amount: String(payout))
                    }
                    
                    payouts += payout
                }
                
                let check = Math().payoutAmountCheck(payouts: payouts, pool: pool)
                
                print("paid out correct amount: \(check), payouts:\(payouts),pool:\(pool)")
                
                MongoClient().deleteHourBets()
                
                
            }
            
            let top10 = Ripple(drop: self.drop).top10()
            
            let roundWallet = Ripple(drop: self.drop).generateWallet()
            
            let roundAddress = roundWallet["address"]?.string
            let roundSecret = roundWallet["secret"]?.string
        
            MongoClient().saveHourRound(coins:top10, address: roundAddress!, secert: roundSecret!)
            
            bet(coins: top10,drop:self.drop)
        }
        
    }
    
    func hourRound() {
        
        Jobs.delay(by: .seconds(delay), interval: .seconds(3600)) {
            
            var oldCoins:[Coin] = []
            var winningBets:Double = 0
            var pool:Double = 0
            var payouts:Double = 0
            var winingPlayers:[(String,Double)] = []
            var currentRoundAddress:String = ""
            var currentRoundSecret:String = ""
            
            ///payouts
            let round = MongoClient().lastHourRound()
            
            currentRoundAddress = String(describing: round.2["address"])
            currentRoundSecret = String(describing: round.2["secret"])
            
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
                    
                    print("paided out \(payout) to address \(player.0)")
                    
                    Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: player.0, secret: currentRoundSecret, amount: String(payout))
                }
                
                let check = Math().payoutAmountCheck(payouts: payouts, pool: pool)
                
                print("paid out correct amount: \(check), payouts:\(payouts),pool:\(pool)")
                
                MongoClient().deleteHourBets()
            }
            
            let top10 = Ripple(drop: self.drop).top10()
            
            let roundWallet = Ripple(drop: self.drop).generateWallet()
            
            let roundAddress = roundWallet["address"]?.string
            let roundSecret = roundWallet["secret"]?.string
            
            MongoClient().saveHourRound(coins:top10, address: roundAddress!, secert: roundSecret!)
        }
        
    }
    
    func dayRound() {
        
        Jobs.delay(by: .seconds(delay), interval: .days(1)) {
            
            var oldCoins:[Coin] = []
            var winningBets:Double = 0
            var pool:Double = 0
            var payouts:Double = 0
            var winingPlayers:[(String,Double)] = []
            var currentRoundAddress:String = ""
            var currentRoundSecret:String = ""
            
            ///payouts
            let round = MongoClient().lastDayRound()
            
            currentRoundAddress = String(describing: round.2["address"])
            currentRoundSecret = String(describing: round.2["secret"])
            
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
                    
                    print("paided out \(payout) to address \(player.0)")
                    
                    Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: player.0, secret: currentRoundSecret, amount: String(payout))
                }
                
                let check = Math().payoutAmountCheck(payouts: payouts, pool: pool)
                
                print("paid out correct amount: \(check), payouts:\(payouts),pool:\(pool)")
                
                MongoClient().deleteDayBets()
            }
            
            let top10 = Ripple(drop: self.drop).top10()
            
            let roundWallet = Ripple(drop: self.drop).generateWallet()
            
            let roundAddress = roundWallet["address"]?.string
            let roundSecret = roundWallet["secret"]?.string
            
            MongoClient().saveDayRound(coins:top10, address: roundAddress!, secert: roundSecret!)
            
            
        }
    }
    
    func weekRound() {
        
        Jobs.delay(by: .seconds(delay), interval: .weeks(1)) {
            
            var oldCoins:[Coin] = []
            var winningBets:Double = 0
            var pool:Double = 0
            var payouts:Double = 0
            var winingPlayers:[(String,Double)] = []
            var currentRoundAddress:String = ""
            var currentRoundSecret:String = ""
            
            ///payouts
            let round = MongoClient().lastWeekRound()
            
            currentRoundAddress = String(describing: round.2["address"])
            currentRoundSecret = String(describing: round.2["secret"])
            
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
                    
                    print("paided out \(payout) to address \(player.0)")
                    
                    Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: player.0, secret: currentRoundSecret, amount: String(payout))
                }
                
                let check = Math().payoutAmountCheck(payouts: payouts, pool: pool)
                
                print("paid out correct amount: \(check), payouts:\(payouts),pool:\(pool)")
                
                MongoClient().deleteWeekBets()
            }
            
            let top10 = Ripple(drop: self.drop).top10()
            
            let roundWallet = Ripple(drop: self.drop).generateWallet()
            
            let roundAddress = roundWallet["address"]?.string
            let roundSecret = roundWallet["secret"]?.string
            
            MongoClient().saveWeekRound(coins:top10, address: roundAddress!, secert: roundSecret!)
        }
    }
}

