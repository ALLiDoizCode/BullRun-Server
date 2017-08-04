//
//  MongoClient.swift
//  BullRun-Server
//
//  Created by Jonathan Green on 7/30/17.
//
//

import Foundation
import MongoKitten
import CryptoSwift

extension ObjectId {
    public init?(from string: String) throws {
        try self.init(string)
    }
}

class MongoClient {
    
    var hourColleciton:MongoCollection!
    var dayCollection:MongoCollection!
    var weekCollection:MongoCollection!
    var hourBetColleciton:MongoCollection!
    var dayBetCollection:MongoCollection!
    var weekBetCollection:MongoCollection!
    var hourAddressColleciton:MongoCollection!
    var dayAddressCollection:MongoCollection!
    var weekAddressCollection:MongoCollection!
    var payOutCollection:MongoCollection!
    var hourStatusCollection:MongoCollection!
    var dayStatusCollection:MongoCollection!
    var weekStatusCollection:MongoCollection!
    
    init(database:Database) {
        
        hourColleciton = database["Hour"]
        dayCollection = database["Day"]
        weekCollection = database["Week"]
        hourBetColleciton = database["BetHour"]
        dayBetCollection = database["BetDay"]
        weekBetCollection = database["BetWeek"]
        hourAddressColleciton = database["HourAddress"]
        dayAddressCollection = database["DayAddress"]
        weekAddressCollection = database["WeekAdsress"]
        payOutCollection = database["Payout"]
        hourStatusCollection = database["HourStatus"]
        dayStatusCollection = database["DayStatus"]
        weekStatusCollection = database["WeekStatus"]
        
    }
    
    
    func encrypt(text:String) -> String {
    
        let plain = text.bytes
        let encrypted = try! plain.encrypt(cipher:Rabbit(key: HASH_KEY))
        
        return encrypted.toHexString()
    }
    
    func decrypt(text:String) -> String{
        
        let bytes = Array<UInt8>(hex: text)
        
        let decrypted = try! bytes.decrypt(cipher: Rabbit(key: HASH_KEY))
        
        return decrypted.makeString()
    }
    
    func setHourStatus(status:Bool) {
        
        if try! hourStatusCollection.findOne() == nil {
            
            let document:Document = [
                
                "betweenRounds":status
            ]
            
            // Insert the document
            try! hourStatusCollection.insert(document)
            
        }else {
            
            var currentDocument = try! hourStatusCollection.findOne()
            
            let id = try currentDocument!["_id"]
            
            print("status id is \(String(id)!)")
            
            let document:Document = [
                
                "betweenRounds":status
            ]
            
            try! hourStatusCollection.update("_id" == ObjectId(String(id)!), to: document, upserting: true)
        }
        
    }
    
    func setDayStatus(status:Bool) {
        
        if try! dayStatusCollection.findOne() == nil {
            
            let document:Document = [
                
                "betweenRounds":status
            ]
            
            // Insert the document
            try! dayStatusCollection.insert(document)
            
        }else {
            
            var currentDocument = try! dayStatusCollection.findOne()
            
            let id = try currentDocument!["_id"]
            
            print("status id is \(String(id)!)")
            
            let document:Document = [
                
                "betweenRounds":status
            ]
            
            try! dayStatusCollection.update("_id" == ObjectId(String(id)!), to: document, upserting: true)
        }
        
    }
    
    func setWeekStatus(status:Bool) {
        
        if try! weekStatusCollection.findOne() == nil {
            
            let document:Document = [
                
                "betweenRounds":status
            ]
            
            // Insert the document
            try! weekStatusCollection.insert(document)
            
        }else {
            
            var currentDocument = try! weekStatusCollection.findOne()
            
            let id = try currentDocument!["_id"]
            
            print("status id is \(String(id)!)")
            
            let document:Document = [
                
                "betweenRounds":status
            ]
            
            try! weekStatusCollection.update("_id" == ObjectId(String(id)!), to: document, upserting: true)
        }
        
    }
    
    func getHourStatus() -> Bool {
        
        let results = try! hourStatusCollection.findOne()
        
        let status = results!["betweenRounds"]!
        
        return Bool(status)!
    }
    
    func getDayStatus() -> Bool {
        
        let results = try! dayStatusCollection.findOne()
        
        let status = results!["betweenRounds"]!
        
        return Bool(status)!
    }
    
    func getWeekStatus() -> Bool {
        
        let results = try! weekStatusCollection.findOne()
        
        let status = results!["betweenRounds"]!
        
        return Bool(status)!
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
    
    func savePayout(address:String,amount:Double) {
        
        let document:Document = [
            
            "address":address,
            "amount":amount
        ]
        
        try! payOutCollection.insert(document)
    }
    
    func payouts() -> [Document] {
        
        let results = try! payOutCollection.find().array
        
        return results
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
    
    func saveHourRound(coins:[Coin]){
        
        guard coins.count != 0  else {
            
            return
        }
        
        //try! hourAddressColleciton.remove()
        
        try! hourColleciton.remove()
        
        for coin in coins {
            
            let document:Document = [
                
                "coin":coin.id,
                "name":coin.name,
                "percent":coin.percent_change_1h,
                "usd":coin.price_usd,
                "BTC":coin.price_btc
            ]
            
            try! hourColleciton.insert(document)
        }
        
        /*let document:Document = [
            
            "address":address,
            "secret":secert
        ]
        
        try! hourAddressColleciton.insert(document)*/
        
    }
    
    func saveDayRound(coins:[Coin]){
        
        guard coins.count != 0  else {
            
            return
        }
        
        //try! dayAddressCollection.remove()
        try! dayCollection.remove()
        
        for coin in coins {
            
            let document:Document = [
                
                "coin":coin.id,
                "name":coin.name,
                "percent":coin.percent_change_1h,
                "usd":coin.price_usd,
                "BTC":coin.price_btc
            ]
            
            try! dayCollection.insert(document)
        }
        
        /*let document:Document = [
            
            "address":address,
            "secret":secert
        ]*/
        
        //try! dayAddressCollection.insert(document)
    }
    
    func saveWeekRound(coins:[Coin]){
        
        guard coins.count != 0  else {
            
            return
        }
        
        //try! weekAddressCollection.remove()
        try! weekCollection.remove()
        
        for coin in coins {
            
            let document:Document = [
                
                "coin":coin.id,
                "name":coin.name,
                "percent":coin.percent_change_1h,
                "usd":coin.price_usd,
                "BTC":coin.price_btc
            ]
            
            try! weekCollection.insert(document)
        }
        
        /*let document:Document = [
            
            "address":address,
            "secret":secert
        ]
        
        try! weekAddressCollection.insert(document)*/
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
