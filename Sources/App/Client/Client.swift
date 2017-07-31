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
    
    func generateWallet() -> JSON {
        
        var json:JSON!
        
        do {
            let request = try Request(method: .get, uri: "https://ripple-server.herokuapp.com/newAddress")
            //request.headers["Authorization"] = "Bearer \(SECERT)"
            let response = try drop.client.respond(to: request)
            json = response.json
            print(json)
            
            
        } catch {
            
        }
        
        return json
    }
}
