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
    
    
    init() {
        
        let server = try! Server("mongodb://heroku_h8lrwkbq:ntcqd6852m09ie14o2v6h4ktqv@ds129003.mlab.com:29003/heroku_h8lrwkbq")
        let database = server["heroku_h8lrwkbq"]
        if database.server.isConnected {
            hourColleciton = database["Hour"]
            dayCollection = database["Day"]
            weekCollection = database["Week"]
            print("Successfully connected!")
        } else {
            print("Connection failed")
        }
    }
    
    func saveHourRound(coins:[Coin]){
        
        guard coins.count != 0  else {
            
            return
        }
        
        try! hourColleciton.remove()
        
        var array:[String] = []
        
        for coin in coins {
            
            array.append(coin.id)
        }
        
        let document:Document = [
        
            "coins":array
        ]
        
        try! hourColleciton.insert(document)
    }
    
    func saveDayRound(coins:[Coin]){
        
        guard coins.count != 0  else {
            
            return
        }
        
        try! dayCollection.remove()
        
        var array:[String] = []
        
        for coin in coins {
            
            array.append(coin.id)
        }
        
        let document:Document = [
            
            "coins":array
        ]
        
        try! dayCollection.insert(document)
    }
    
    func saveWeekRound(coins:[Coin]){
        
        guard coins.count != 0  else {
            
            return
        }
        
        try! weekCollection.remove()
        
        var array:[String] = []
        
        for coin in coins {
            
            array.append(coin.id)
        }
        
        let document:Document = [
            
            "coins":array
        ]
        
        try! weekCollection.insert(document)
    }
    
    func lastHourRound() -> Document{
        
        let lastEntity: Document = try! hourColleciton.find().first!
        
        return lastEntity
    }
    
    func lastDayRound() -> Document{
        
        let lastEntity: Document = try! dayCollection.find().first!
        
        return lastEntity
    }
    
    func lastWeekRound() -> Document{
        
        let lastEntity: Document = try! weekCollection.find().first!
        
        return lastEntity
    }
    
    //let insertedID = try collection.insert(document)
    //let amountOfEntities: Int = try collection.count()
    //let allEntities: CollectionSlice<Document> = try collection.find()
    //let firstEntity: Document = try collection.findOne()
}
