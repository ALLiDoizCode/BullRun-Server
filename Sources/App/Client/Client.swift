//
//  Client.swift
//  BullRun-Server
//
//  Created by Jonathan Green on 7/27/17.
//
//

import Foundation

import Vapor
import HTTP
import Unbox
class Ripple {
    
    var drop:Droplet!
    
    init(drop:Droplet){
        self.drop = drop
    }
    
    
    func balance(address:String) -> JSON {
        
        var json:JSON!
        
        let params = [
            "address":address
        ]
        
        print("address is \(address)")
        
        do {
            let request = try Request(method: .post, uri: "https://ripple-server.herokuapp.com/balance")
            print("1")
            request.formURLEncoded = try Node(node: params)
            print("2")
            //request.headers["Authorization"] = "Bearer \(SECERT)"
            let response = try drop.client.respond(to: request)
            print("3")
            json = try JSON(bytes: response.body.bytes!)
            print(json)
            
        } catch {
            
            print("request error was \(error)")
            
        }
        
        return json
    }
    
    func send(address1:String,address2:String,secret:String,amount:String) -> JSON {
        
        var json:JSON!
        
        let params = [
         
         "address1":address1,
         "address2":address2,
         "secret":secret,
         "amount":amount
         
         ]
        
        do {
            let request = try Request(method: .post, uri: "https://ripple-server.herokuapp.com/send")
            request.formURLEncoded = try Node(node: params)
            //request.headers["Authorization"] = "Bearer \(SECERT)"
            let response = try drop.client.respond(to: request)
            json = response.json
            print(json)
            
        } catch {
            
            print("request error was \(error)")
            
        }
        
        return json
    }
    
    func top10() -> [Coin] {
        
        var responseJson:JSON!
        var coins:[Coin] = []
        
        do {
            let request = try Request(method: .get, uri: "https://api.coinmarketcap.com/v1/ticker/?limit=10")
            //request.headers["Authorization"] = "Bearer \(SECERT)"
            let response = try drop.client.respond(to: request)
            responseJson = response.json
            
            for json in (responseJson.array)! {
                
                let coin = Coin()
                
                coin.id = (json.object?["id"]?.string)!
                coin.name = json.object?["name"]?.string
                coin._24h_volume_usd = json.object?["24h_volume_usd"]?.double
                coin.available_supply = json.object?["available_supply"]?.double
                coin.percent_change_1h = json.object?["percent_change_1h"]?.double
                coin.percent_change_24h = json.object?["percent_change_24h"]?.double
                coin.percent_change_7d = json.object?["percent_change_7d"]?.double
                coin.price_usd = json.object?["price_usd"]?.double
                coin.price_btc = json.object?["price_btc"]?.double
                coin.rank = json.object?["rank"]?.int
                coin.symbol = json.object?["symbol"]?.string
                coin.total_supply = json.object?["total_supply"]?.string
                
                coins.append(coin)
            }
        
            
            
        } catch {
            
        }
        
        return coins
    }
    
    func generateWallet() -> JSON {
        
        var json:JSON!
        
        do {
            let request = try Request(method: .get, uri: "https://api.coinmarketcap.com/v1/ticker/?limit=10")
            //request.headers["Authorization"] = "Bearer \(SECERT)"
            let response = try drop.client.respond(to: request)
            json = response.json
            print(json)
            
            
        } catch {
            
        }
        
        return json
    }
    
}
