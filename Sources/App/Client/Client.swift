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
import MongoKitten
class Ripple {
    
    var drop:Droplet!
    static var jobIds:[String:WebSocket] = [:]
    init(drop:Droplet){
        self.drop = drop
    }
    
    func fee() ->Double {
        
        var json:JSON!
        
        do {
            let request = try Request(method: .get, uri: "https://ripple-server.herokuapp.com/fee")
            print("1")
            //request.formURLEncoded = try Node(node: params)
            print("2")
            //request.headers["Authorization"] = "Bearer \(SECERT)"
            let response = try drop.client.respond(to: request)
            print("3")
            json = try JSON(bytes: response.body.bytes!)
            print(json)
            
        } catch {
            
            print("request error was \(error)")
            
        }
        
        print("fee is \(String(format:"%.8f", json.double!))")
        
        return json.double!
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
    
    func accountInfo(address:String) -> JSON {
        
        var json:JSON!
        
        let params = [
            "address":address
        ]
        
        print("address is \(address)")
        
        do {
            let request = try Request(method: .post, uri: "https://ripple-server.herokuapp.com/accountInfo")
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
    
    func send(address1:String,address2:String,secret:String,amount:String,coin:String,round:String) -> JSON {
        
        var json:JSON!
        
        
        let params = [
         
         "address1":address1,
         "address2":address2,
         "secret":secret,
         "amount":amount,
         "coin":coin,
         "round":round
         
         ]
        
        do {
            print("Bar 1")
            let request = try Request(method: .post, uri: "https://ripple-server.herokuapp.com/send")
            print("Bar 2")
            request.formURLEncoded = try Node(node: params)
            print("Bar 3")
            //request.headers["Authorization"] = "Bearer \(SECERT)"
            let response = try drop.client.respond(to: request)
            print("Bar 4")
            json = response.json
            print("Bar 5")
            print(json)
            print("Bar 6")
            
        } catch {
            
            print("request error was \(error)")
            
        }
        
        return "sending ripple"
    }
    
    func getCoin(coinId:String) -> Coin {
        
        var responseJson:JSON!
        let coin = Coin()
        
        do {
            let request = try Request(method: .get, uri: "https://api.coinmarketcap.com/v1/ticker/\(coinId)/")
            //request.headers["Authorization"] = "Bearer \(SECERT)"
            let response = try drop.client.respond(to: request)
            responseJson = response.json
            
            if responseJson.array?.count != 0 {
                
                coin.id = (responseJson.array?[0].object?["id"]?.string)!
                coin.name = responseJson.array?[0].object?["name"]?.string
                coin._24h_volume_usd = responseJson.array?[0].object?["24h_volume_usd"]?.double
                coin.available_supply = responseJson.array?[0].object?["available_supply"]?.double
                coin.percent_change_1h = responseJson.array?[0].object?["percent_change_1h"]?.double
                coin.percent_change_24h = responseJson.array?[0].object?["percent_change_24h"]?.double
                coin.percent_change_7d = responseJson.array?[0].object?["percent_change_7d"]?.double
                coin.price_usd = responseJson.array?[0].object?["price_usd"]?.double
                coin.price_btc = responseJson.array?[0].object?["price_btc"]?.double
                coin.rank = responseJson.array?[0].object?["rank"]?.int
                coin.symbol = responseJson.array?[0].object?["symbol"]?.string
                coin.total_supply = responseJson.array?[0].object?["total_supply"]?.string
            }
            
        } catch {
            
        }
        
        return coin
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
            let request = try Request(method: .get, uri:"https://ripple-server.herokuapp.com/newAddress")
            //request.headers["Authorization"] = "Bearer \(SECERT)"
            let response = try drop.client.respond(to: request)
            json = response.json
            print(json)
            
            
        } catch {
            
        }
        
        return json
    }
    
}
