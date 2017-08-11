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
import Console
import FluentProvider

final class ScheduleCommand: Command, ConfigInitializable {
    var console: ConsoleProtocol
    let id = "schedule"
    let driver: Driver
    let log: LogProtocol
    
    required init(config: Config) throws {
        console = try config.resolveConsole()
        driver = try config.resolveDriver()
        log = try config.resolveLog()
    }
    
    func run(arguments: [String]) throws {
        log.info("doing some scheduled work")
        
        do {
            Schedule(drop: Constant.drop!, database: Constant.database!).hourRound()
            Schedule(drop: Constant.drop!, database: Constant.database!).dayRound()
            Schedule(drop: Constant.drop!, database: Constant.database!).weekRound()
        }catch {
            
            log.error(error)
        }
    }
}

class Schedule {
    
    let delay:Double = 600.0
    var drop:Droplet!
    var database:MongoKitten.Database!
    
    static let jobsQueue = DispatchQueue(label: "Swift Metrics Jobs Queue")

    init(drop:Droplet,database:MongoKitten.Database) {
        
        self.database = database
        self.drop = drop
    }
    
    func getWinners(round:([Document],[Document],Document)) {
        
    }
    
    func hourRound() {
        
        var oldCoins:[Coin] = []
        var winningBets:Double = 0
        var pool:Double = 0
        var payouts:Double = 0
        var winingPlayers:[(String,Double)] = []
        var currentRoundAddress:String = ""
        var currentRoundSecret:String = ""
        
        ////payouts
        let round = MongoClient.sharedInstance.lastHourRound()
        
        let decryptAddress = MongoClient.sharedInstance.decrypt(text: String(describing: round.2["address"]!))
        
        let decryptSecert = MongoClient.sharedInstance.decrypt(text: String(describing: round.2["secret"]!))
        
        
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
           
            ///BOOK_PAY
            var BOOK_PAY = pool * fee
            var Owner2Pay:Double = 0
            var Owner1Pay:Double = 0
            //////////////////
            
            for player in winingPlayers {
                
                let payout = Math().payout(winningBets: winningBets, currentBet: player.1, pool: pool, stake: stake)
                
                payouts += payout
                
                let fee = Ripple(drop: self.drop).fee()
                
                let getBalance = Ripple(drop: self.drop).balance(address: currentRoundAddress)
                let balance = getBalance[0]!["value"]?.double
                
                let reSupply = Math().supplyRoundWallet(fee: fee, balance: balance!, currentPayout: payout,bookPay:BOOK_PAY)
                
                if reSupply == true {
                    
                    BOOK_PAY = BOOK_PAY - (fee + (fee * 0.33))
                }
                
                print("paided out \(payout) to address \(player.0)")
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: player.0, secret: currentRoundSecret, amount: String(payout), coin: "", round: "payout")
                
                
                
                /*if json["resultCode"]?.string == "tesSUCCESS" {
                    
                    MongoClient.sharedInstance.savePayout(address: player.0, amount: payout)
                }*/
                
                
            }
            print("Bar")
            ///pay myself fee
            if winingPlayers.count == 0 {
                
                BOOK_PAY = pool
                Owner2Pay = BOOK_PAY * 0.33
                Owner1Pay = BOOK_PAY - Owner2Pay
                
                 Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET, secret: currentRoundSecret, amount: String(Owner1Pay), coin: "", round: "")
                
                /*if json["resultCode"]?.string == "tesSUCCESS" {
                    
                    
                }*/
                
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET2, secret: currentRoundSecret, amount: String(Owner2Pay), coin: "", round: "")
                
                /*if json2["resultCode"]?.string == "tesSUCCESS" {
                    
                    
                }*/
                
                pool = pool - pool
                
            }else {
                
                Owner2Pay = BOOK_PAY * 0.33
                Owner1Pay = BOOK_PAY - Owner2Pay
                
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET, secret: currentRoundSecret, amount: String(Owner1Pay), coin: "", round: "")
                
                /*if json["resultCode"]?.string == "tesSUCCESS" {
                    
                    
                }*/
                
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET2, secret: currentRoundSecret, amount: String(Owner2Pay), coin: "", round: "")
                
                /*if json2["resultCode"]?.string == "tesSUCCESS" {
                    
                    
                }*/
                
                pool = pool - BOOK_PAY
                
                
            }
            //////////////////
            
            let check = Math().payoutAmountCheck(payouts: payouts, pool: pool)
            
            print("paid out correct amount: \(check), payouts:\(payouts),pool:\(pool)")
            
            MongoClient.sharedInstance.deleteHourBets()
        }
        
        let top10 = Ripple(drop: self.drop).top10()
        
       MongoClient.sharedInstance.saveHourRound(coins:top10)
        
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
        let round = MongoClient.sharedInstance.lastDayRound()
        
        let decryptAddress = MongoClient.sharedInstance.decrypt(text: String(describing: round.2["address"]!))
        let decryptSecert = MongoClient.sharedInstance.decrypt(text: String(describing: round.2["secret"]!))

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
            
            ///BOOK_PAY
            var BOOK_PAY = pool * fee
            var Owner2Pay:Double = 0
            var Owner1Pay:Double = 0
            //////////////////
            
            for player in winingPlayers {
                
                let payout = Math().payout(winningBets: winningBets, currentBet: player.1, pool: pool, stake: stake)
                
                payouts += payout
                
                let fee = Ripple(drop: self.drop).fee()
                
                let getBalance = Ripple(drop: self.drop).balance(address: currentRoundAddress)
                let balance = getBalance[0]!["value"]?.double
                
                let reSupply = Math().supplyRoundWallet(fee: fee, balance: balance!, currentPayout: payout,bookPay:BOOK_PAY)
                
                if reSupply == true {
                    
                    BOOK_PAY = BOOK_PAY - (fee + (fee * 0.33))
                }
                
                print("paided out \(payout) to address \(player.0)")
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: player.0, secret: currentRoundSecret, amount: String(payout), coin: "", round: "payout")
                
                
                /*if json["resultCode"]?.string == "tesSUCCESS" {
                    
                    MongoClient.sharedInstance.savePayout(address: player.0, amount: payout)
                }*/
            }
            ///pay myself fee
            if winingPlayers.count == 0 {
                
                BOOK_PAY = pool
                Owner2Pay = BOOK_PAY * 0.33
                Owner1Pay = BOOK_PAY - Owner2Pay
                
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET, secret: currentRoundSecret, amount: String(Owner1Pay), coin: "", round: "")
                
                /*if json["resultCode"]?.string == "tesSUCCESS" {
                    
                    
                }*/
                
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET2, secret: currentRoundSecret, amount: String(Owner2Pay), coin: "", round: "")
                
                
                pool = pool - pool
                
                /*if json2["resultCode"]?.string == "tesSUCCESS" {
                    
                    
                }*/
                
            }else {
                
                Owner2Pay = BOOK_PAY * 0.33
                Owner1Pay = BOOK_PAY - Owner2Pay
                
                let json = Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET, secret: currentRoundSecret, amount: String(Owner1Pay), coin: "", round: "")
                
                if json["resultCode"]?.string == "tesSUCCESS" {
                    
                    pool = pool - BOOK_PAY
                }
                
                let json2 = Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET2, secret: currentRoundSecret, amount: String(Owner2Pay), coin: "", round: "")
                
                /*if json2["resultCode"]?.string == "tesSUCCESS" {
                    
                    
                }*/
                
                
            }
            //////////////////
            
            let check = Math().payoutAmountCheck(payouts: payouts, pool: pool)
            
            print("paid out correct amount: \(check), payouts:\(payouts),pool:\(pool)")
            
            MongoClient.sharedInstance.deleteDayBets()
        }
        
        let top10 = Ripple(drop: self.drop).top10()
        
        MongoClient.sharedInstance.saveDayRound(coins:top10)
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
        let round = MongoClient.sharedInstance.lastWeekRound()
        
        let decryptAddress = MongoClient.sharedInstance.decrypt(text: String(describing: round.2["address"]!))
        let decryptSecert = MongoClient.sharedInstance.decrypt(text: String(describing: round.2["secret"]!))
        
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
            
            ///BOOK_PAY
            var BOOK_PAY = pool * fee
            var Owner2Pay:Double = 0
            var Owner1Pay:Double = 0
            //////////////////
            
            
            
            for player in winingPlayers {
                let payout = Math().payout(winningBets: winningBets, currentBet: player.1, pool: pool, stake: stake)
                
                payouts += payout
                
                let fee = Ripple(drop: self.drop).fee()
                
                let getBalance = Ripple(drop: self.drop).balance(address: currentRoundAddress)
                let balance = getBalance[0]!["value"]?.double
                
                let reSupply = Math().supplyRoundWallet(fee: fee, balance: balance!, currentPayout: payout,bookPay:BOOK_PAY)
                
                if reSupply == true {
                    
                    BOOK_PAY = BOOK_PAY - (fee + (fee * 0.33))
                }
                
                print("paided out \(payout) to address \(player.0)")
                let json = Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: player.0, secret: currentRoundSecret, amount: String(payout), coin: "", round: "payout")
                
                
                /*if json["resultCode"]?.string == "tesSUCCESS" {
                    
                    MongoClient.sharedInstance.savePayout(address: player.0, amount: payout)
                }*/
            }
            ///pay myself fee
            if winingPlayers.count == 0 {
                
                BOOK_PAY = pool
                Owner2Pay = BOOK_PAY * 0.33
                Owner1Pay = BOOK_PAY - Owner2Pay
                
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET, secret: currentRoundSecret, amount: String(Owner1Pay), coin: "", round: "")
                
                /*if json["resultCode"]?.string == "tesSUCCESS" {
                    
                    
                }*/
                
                Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET2, secret: currentRoundSecret, amount: String(Owner2Pay), coin: "", round: "")
                
                /*if json2["resultCode"]?.string == "tesSUCCESS" {
                    
                    
                }*/
                
                pool = pool - pool
                
            }else {
                
                Owner2Pay = BOOK_PAY * 0.33
                Owner1Pay = BOOK_PAY - Owner2Pay
                
                let json = Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET, secret: currentRoundSecret, amount: String(Owner1Pay), coin: "", round: "")
                
                if json["resultCode"]?.string == "tesSUCCESS" {
                    
                    pool = pool - BOOK_PAY
                }
                
                let json2 = Ripple(drop: self.drop).send(address1: currentRoundAddress, address2: OWNER_WALLET2, secret: currentRoundSecret, amount: String(Owner2Pay), coin: "", round: "")
                
                if json2["resultCode"]?.string == "tesSUCCESS" {
                    
                    
                }
                
                
            }
            //////////////////
            
            let check = Math().payoutAmountCheck(payouts: payouts, pool: pool)
            
            print("paid out correct amount: \(check), payouts:\(payouts),pool:\(pool)")
            
            MongoClient.sharedInstance.deleteWeekBets()
        }
        
        let top10 = Ripple(drop: self.drop).top10()
        
        MongoClient.sharedInstance.saveWeekRound(coins:top10)
    }
}

