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
import Dispatch

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
    var loadTestCollection:MongoCollection!
    var database:Database!
    
    static var hourBetArray:[Document] = []
    static var dayBetArray:[Document] = []
    static var weekBetArray:[Document] = []
    
    static var sharedInstance:MongoClient!
    
    let queue = DispatchQueue(label: "insertion", attributes: .concurrent)
    let dispatchGroup = DispatchGroup()
    let parallel = true
    
    init(database:Database) {
        self.database = database
        hourColleciton = self.database["Hour"]
        dayCollection = self.database["Day"]
        weekCollection = self.database["Week"]
        hourBetColleciton = self.database["BetHour"]
        dayBetCollection = self.database["BetDay"]
        weekBetCollection = self.database["BetWeek"]
        hourAddressColleciton = self.database["HourAddress"]
        dayAddressCollection = self.database["DayAddress"]
        weekAddressCollection = self.database["WeekAdsress"]
        payOutCollection = self.database["Payout"]
        hourStatusCollection = self.database["HourStatus"]
        dayStatusCollection = self.database["DayStatus"]
        weekStatusCollection = self.database["WeekStatus"]
        loadTestCollection = self.database["loadtest"]
        MongoClient.sharedInstance = self
        
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
    
    func benchMark() -> String {
        
        let results = try! loadTestCollection.findOne()
        
        let key = results!["key"]
        
        return String(describing: key!)
        
    }
    
    func setHourStatus(status:Bool) {
        
        if try! hourStatusCollection.findOne() == nil {
            
            let document:Document = [
                
                "betweenRounds":status
            ]
            
            if parallel {
                queue.async(group: dispatchGroup) {
                    // Insert the document
                    try! self.hourStatusCollection.insert(document)
                    
                }
            } else {
                // Insert the document
                try! hourStatusCollection.insert(document)
            }
            
            if parallel {
                dispatchGroup.wait()
            }
            
        }else {
            
            var currentDocument = try! hourStatusCollection.findOne()
            
            let id = try currentDocument!["_id"]
            
            print("status id is \(String(id)!)")
            
            let document:Document = [
                
                "betweenRounds":status
            ]
            
            if parallel {
                queue.async(group: dispatchGroup) {
                    // Insert the document
                    try! self.hourStatusCollection.update("_id" == ObjectId(String(id)!), to: document, upserting: true)
                    
                }
            } else {
                // Insert the document
                try! hourStatusCollection.update("_id" == ObjectId(String(id)!), to: document, upserting: true)
            }
            
            if parallel {
                dispatchGroup.wait()
            }
        }
        
    }
    
    func setDayStatus(status:Bool) {
        
        if try! dayStatusCollection.findOne() == nil {
            
            let document:Document = [
                
                "betweenRounds":status
            ]
            
            if parallel {
                queue.async(group: dispatchGroup) {
                    // Insert the document
                    try! self.dayStatusCollection.insert(document)
                    
                }
            } else {
                // Insert the document
                try! dayStatusCollection.insert(document)
            }
            
            if parallel {
                dispatchGroup.wait()
            }
            
        }else {
            
            var currentDocument = try! dayStatusCollection.findOne()
            
            let id = try currentDocument!["_id"]
            
            print("status id is \(String(id)!)")
            
            let document:Document = [
                
                "betweenRounds":status
            ]
            
            if parallel {
                queue.async(group: dispatchGroup) {
                    // Insert the document
                    try! self.dayStatusCollection.update("_id" == ObjectId(String(id)!), to: document, upserting: true)
                    
                }
            } else {
                // Insert the document
                try! dayStatusCollection.update("_id" == ObjectId(String(id)!), to: document, upserting: true)
            }
            
            if parallel {
                dispatchGroup.wait()
            }
        }
        
    }
    
    func setWeekStatus(status:Bool) {
        
        if try! weekStatusCollection.findOne() == nil {
            
            let document:Document = [
                
                "betweenRounds":status
            ]
            
            if parallel {
                queue.async(group: dispatchGroup) {
                    // Insert the document
                    try! self.weekStatusCollection.insert(document)
                    
                }
            } else {
                // Insert the document
                try! weekStatusCollection.insert(document)
            }
            
            if parallel {
                dispatchGroup.wait()
            }
            
            print("Finished deleting week bet documents from the database")
            
        }else {
            
            var currentDocument = try! weekStatusCollection.findOne()
            
            let id = try currentDocument!["_id"]
            
            print("status id is \(String(id)!)")
            
            let document:Document = [
                
                "betweenRounds":status
            ]
            
            if parallel {
                queue.async(group: dispatchGroup) {
                    // Insert the document
                    try! self.weekStatusCollection.update("_id" == ObjectId(String(id)!), to: document, upserting: true)
                    
                }
            } else {
                // Insert the document
                try! weekStatusCollection.update("_id" == ObjectId(String(id)!), to: document, upserting: true)
            }
            
            if parallel {
                dispatchGroup.wait()
            }
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
        
        if parallel {
            queue.async(group: dispatchGroup) {
                try! self.hourBetColleciton.remove()
                
            }
        } else {
            try! hourBetColleciton.remove()
        }
        
        if parallel {
            dispatchGroup.wait()
        }
        
        print("Finished deleting hour bet documents from the database")
    }
    
    func deleteDayBets() {
        
        if parallel {
            queue.async(group: dispatchGroup) {
                try! self.dayBetCollection.remove()
                
            }
        } else {
            try! dayBetCollection.remove()
        }
        
        if parallel {
            dispatchGroup.wait()
        }
        
        print("Finished deleting day bet documents from the database")
    }
    
    func deleteWeekBets() {
        
        if parallel {
            queue.async(group: dispatchGroup) {
                try! self.weekBetCollection.remove()
                
            }
        } else {
            try! weekBetCollection.remove()
        }
        
        if parallel {
            dispatchGroup.wait()
        }
        
        print("Finished deleting week bet documents from the database")
    }
    
    func savePayout(address:String,amount:Double) {
        
        let document:Document = [
            
            "address":address,
            "amount":amount
        ]
        
        if parallel {
            queue.async(group: dispatchGroup) {
                try! self.payOutCollection.insert(document)
                
            }
        } else {
            try! payOutCollection.insert(document)
        }
        
        if parallel {
            dispatchGroup.wait()
        }
        
        print("Finished saving payout documents to the database")
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
        
        MongoClient.hourBetArray.append(document)
        
        /*if parallel {
            queue.async(group: dispatchGroup) {
                 try! self.hourBetColleciton.insert(document)
                
            }
        } else {
             try! hourBetColleciton.insert(document)
        }
    
        if parallel {
            dispatchGroup.wait()
        }
    
        print("Finished adding HourBet documents to the database")*/
    
    }
    
    func saveDayBet(wallet:Wallet) {
        
        let document:Document = [
            
            "address":wallet.address,
            "coin":wallet.dayBet.coinId,
            "amount":wallet.dayBet.amount
        ]
        
        MongoClient.dayBetArray.append(document)
        
        /*if parallel {
            queue.async(group: dispatchGroup) {
                try! self.dayBetCollection.insert(document)
                
            }
        } else {
            try! dayBetCollection.insert(document)
        }
        
        if parallel {
            dispatchGroup.wait()
        }
        
        print("Finished adding DayBet documents to the database")*/
    }
    
    func saveWeekBet(wallet:Wallet) {
        
        let document:Document = [
            
            "address":wallet.address,
            "coin":wallet.weekBet.coinId,
            "amount":wallet.weekBet.amount
        ]
        
        /*if parallel {
            queue.async(group: dispatchGroup) {
                try! self.weekBetCollection.insert(document)
                
            }
        } else {
            try! weekBetCollection.insert(document)
        }
        
        if parallel {
            dispatchGroup.wait()
        }
        
        print("Finished adding WeekBet documents to the database")*/
        
        MongoClient.weekBetArray.append(document)
    }
    
    func insertHourBets() {
        
        guard MongoClient.hourBetArray.count != 0 else {
            
            return
        }
        
        if parallel {
            queue.async(group: dispatchGroup) {
                // Insert the document
                let savedDocuments = try! self.hourBetColleciton.insert(contentsOf: MongoClient.hourBetArray)
                
                print("docs insertd \(savedDocuments)")
                print("docsArray \(MongoClient.hourBetArray.count)")
                
                for _ in 0 ..< savedDocuments.count {
                    
                    MongoClient.hourBetArray.remove(at: 0)
                }
                
            }
        } else {
            // Insert the document
            let savedDocuments = try! hourBetColleciton.insert(contentsOf: MongoClient.hourBetArray)
            
            print("docs insertd \(savedDocuments)")
            print("docsArray \(MongoClient.hourBetArray.count)")
            
            for _ in 0 ..< savedDocuments.count {
                
                MongoClient.hourBetArray.remove(at: 0)
            }
        }
        
        if parallel {
            dispatchGroup.wait()
        }
    }
    
    func insertDayBets() {
        
        guard MongoClient.dayBetArray.count != 0 else {
            
            return
        }
        
        if parallel {
            queue.async(group: dispatchGroup) {
                // Insert the document
                let savedDocuments = try! self.dayBetCollection.insert(contentsOf: MongoClient.dayBetArray)
                
                print("docs insertd \(savedDocuments)")
                print("docsArray \(MongoClient.dayBetArray.count)")
                
                for _ in 0 ..< savedDocuments.count {
                    
                    MongoClient.dayBetArray.remove(at: 0)
                }
                
            }
        } else {
            // Insert the document
            let savedDocuments = try! dayBetCollection.insert(contentsOf: MongoClient.dayBetArray)
            
            print("docs insertd \(savedDocuments)")
            print("docsArray \(MongoClient.dayBetArray.count)")
            
            for _ in 0 ..< savedDocuments.count {
                
                MongoClient.dayBetArray.remove(at: 0)
            }
        }
        
        if parallel {
            dispatchGroup.wait()
        }
    }
    
    func insertweekBets() {
        
        guard MongoClient.weekBetArray.count != 0 else {
            
            return 
        }
        
        if parallel {
            queue.async(group: dispatchGroup) {
                // Insert the document
                let savedDocuments = try! self.weekBetCollection.insert(contentsOf: MongoClient.weekBetArray)
                
                print("docs insertd \(savedDocuments)")
                print("docsArray \(MongoClient.weekBetArray.count)")
                
                for _ in 0 ..< savedDocuments.count {
                    
                    MongoClient.weekBetArray.remove(at: 0)
                }
                
            }
        } else {
            // Insert the document
            let savedDocuments = try! weekBetCollection.insert(contentsOf: MongoClient.weekBetArray)
            
            print("docs insertd \(savedDocuments)")
            print("docsArray \(MongoClient.weekBetArray.count)")
            
            for _ in 0 ..< savedDocuments.count {
                
                MongoClient.weekBetArray.remove(at: 0)
            }
        }
        
        if parallel {
            dispatchGroup.wait()
        }
    }
    
    func saveHourRound(coins:[Coin]){
        
        guard coins.count != 0  else {
            
            return
        }
        
        try! hourColleciton.remove()
        
        for coin in coins {
            
            let document:Document = [
                
                "coin":coin.id,
                "name":coin.name,
                "percent":coin.percent_change_1h,
                "usd":coin.price_usd,
                "BTC":coin.price_btc
            ]
            
            if parallel {
                queue.async(group: dispatchGroup) {
                    try! self.hourColleciton.insert(document)
                    
                }
            } else {
                try! hourColleciton.insert(document)
            }
            
            if parallel {
                dispatchGroup.wait()
            }
            
            print("Finished adding HourRound documents to the database")
        }
        
    }
    
    func saveDayRound(coins:[Coin]){
        
        guard coins.count != 0  else {
            
            return
        }
    
        try! dayCollection.remove()
        
        for coin in coins {
            
            let document:Document = [
                
                "coin":coin.id,
                "name":coin.name,
                "percent":coin.percent_change_1h,
                "usd":coin.price_usd,
                "BTC":coin.price_btc
            ]
            
            if parallel {
                queue.async(group: dispatchGroup) {
                    try! self.dayCollection.insert(document)
                    
                }
            } else {
                try! dayCollection.insert(document)
            }
            
            if parallel {
                dispatchGroup.wait()
            }
            
            print("Finished adding DayRound documents to the database")
            
        }
        
    }
    
    func saveWeekRound(coins:[Coin]){
        
        guard coins.count != 0  else {
            
            return
        }
        
        try! weekCollection.remove()
        
        for coin in coins {
            
            let document:Document = [
                
                "coin":coin.id,
                "name":coin.name,
                "percent":coin.percent_change_1h,
                "usd":coin.price_usd,
                "BTC":coin.price_btc
            ]
            
            if parallel {
                queue.async(group: dispatchGroup) {
                    try! self.weekCollection.insert(document)
                    
                }
            } else {
                try! weekCollection.insert(document)
            }
            
            if parallel {
                dispatchGroup.wait()
            }
            
            print("Finished adding weekRound documents to the database")
            
        }
        
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

}
