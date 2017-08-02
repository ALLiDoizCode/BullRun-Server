//
//  MongoClient.swift
//  BullRun-Server
//
//  Created by Jonathan Green on 7/30/17.
//
//

import Foundation
import MongoKitten

extension ObjectId {
    public init?(from string: String) throws {
        try self.init(string)
    }
}

class MongoClient {
    
    //var db:Database!
    
    var hourColleciton:MongoCollection!
    var dayCollection:MongoCollection!
    var weekCollection:MongoCollection!
    var hourBetColleciton:MongoCollection!
    var dayBetCollection:MongoCollection!
    var weekBetCollection:MongoCollection!
    var hourAddressColleciton:MongoCollection!
    var dayAddressCollection:MongoCollection!
    var weekAddressCollection:MongoCollection!
    
    
    init() {
        
        let server = try! Server("mongodb://heroku_h8lrwkbq:ntcqd6852m09ie14o2v6h4ktqv@ds129003.mlab.com:29003/heroku_h8lrwkbq")
        let database = server["heroku_h8lrwkbq"]
        if database.server.isConnected {
            hourColleciton = database["Hour"]
            dayCollection = database["Day"]
            weekCollection = database["Week"]
            hourBetColleciton = database["BetHour"]
            dayBetCollection = database["BetDay"]
            weekBetCollection = database["BetWeek"]
            hourAddressColleciton = database["HourAddress"]
            dayAddressCollection = database["DayAddress"]
            weekAddressCollection = database["WeekAdsress"]
            print("Successfully connected!")
        } else {
            print("Connection failed")
        }
    }
    
    func deleteHourBets() {
        
        try! hourBetColleciton.remove()
    }
    
    func deleteDayBets() {
        
        try! dayBetCollection.remove()
    }
    
    func deleteWeekBets() {
        
        try! weekBetCollection.remove()
    }
    
    func saveHourBet(wallet:Wallet) {
        
        let document:Document = [
            
            "address":wallet.address,
            "coin":wallet.hourBet.coinId,
            "amount":wallet.hourBet.amount
        ]
        
        try! hourBetColleciton.insert(document)
    }
    
    func saveDayBet(wallet:Wallet) {
        
        let document:Document = [
            
            "address":wallet.address,
            "coin":wallet.dayBet.coinId,
            "amount":wallet.dayBet.amount
        ]
        
        try! dayBetCollection.insert(document)
    }
    
    func saveWeekBet(wallet:Wallet) {
        
        let document:Document = [
            
            "address":wallet.address,
            "coin":wallet.weekBet.coinId,
            "amount":wallet.weekBet.amount
        ]
        
        try! weekBetCollection.insert(document)
    }
    
    func saveHourRound(coins:[Coin],address:String,secert:String){
        
        guard coins.count != 0  else {
            
            return
        }
        
        try! hourAddressColleciton.remove()
        
        try! hourColleciton.remove()
        
        for coin in coins {
            
            let document:Document = [
                
                "coin":coin.id
            ]
            
            try! hourColleciton.insert(document)
        }
        
        let document:Document = [
            
            "address":address,
            "secret":secert
        ]
        
        try! hourAddressColleciton.insert(document)
        
    }
    
    func saveDayRound(coins:[Coin],address:String,secert:String){
        
        guard coins.count != 0  else {
            
            return
        }
        
        try! dayAddressCollection.remove()
        try! dayCollection.remove()
        
        for coin in coins {
            
            let document:Document = [
                
                "coin":coin.id
            ]
            
            try! dayCollection.insert(document)
        }
        
        let document:Document = [
            
            "address":address,
            "secret":secert
        ]
        
        try! dayAddressCollection.insert(document)
    }
    
    func saveWeekRound(coins:[Coin],address:String,secert:String){
        
        guard coins.count != 0  else {
            
            return
        }
        
        try! weekAddressCollection.remove()
        try! weekCollection.remove()
        
        for coin in coins {
            
            let document:Document = [
                
                "coin":coin.id
            ]
            
            try! weekCollection.insert(document)
        }
        
        let document:Document = [
            
            "address":address,
            "secret":secert
        ]
        
        try! weekAddressCollection.insert(document)
    }
    
    func lastHourRound() -> ([Document],[Document],Document){
        
        let lastEntity: [Document] = try! hourColleciton.find().array
        let bets:[Document] = try! hourBetColleciton.find().array
        if let address:Document = try! hourAddressColleciton.findOne() {
            
            return (lastEntity,bets,address)
        }
        
        return (lastEntity,bets,Document())
    }
    
    func lastDayRound() -> ([Document],[Document],Document){
        
        let lastEntity: [Document] = try! dayCollection.find().array
        let bets:[Document] = try! dayBetCollection.find().array
        if let address:Document = try! dayAddressCollection.findOne() {
            
            return (lastEntity,bets,address)
        }
        
        return (lastEntity,bets,Document())
    }
    
    func lastWeekRound() -> ([Document],[Document],Document){
        
        let lastEntity: [Document] = try! weekCollection.find().array
        let bets:[Document] = try! weekBetCollection.find().array
        if let address:Document = try! weekAddressCollection.findOne() {
            
            return (lastEntity,bets,address)
        }
        
        return (lastEntity,bets,Document())
    }
    
    //let insertedID = try collection.insert(document)
    //let amountOfEntities: Int = try collection.count()
    //let allEntities: CollectionSlice<Document> = try collection.find()
    //let firstEntity: Document = try collection.findOne()
}
