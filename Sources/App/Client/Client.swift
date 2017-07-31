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
    
    func send(address1:String,address2:String,secret:String,amount:String)  {
        
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
            let json = try JSON(bytes: response.body.bytes!)
            print(json)
            
        } catch {
            
            print("request error was \(error)")
            
        }
    }
    
    func generateWallet() {
        
        /*let params = [
            
            "description": "Customer for Mo-B",
            "email":email,
            "source":token
            
        ]*/
        
        do {
            let request = try Request(method: .get, uri: "https://ripple-server.herokuapp.com/newAddress")
            //request.formURLEncoded = try params.makeNode()
            //request.headers["Authorization"] = "Bearer \(SECERT)"
            let response = try drop.client.respond(to: request)
            let json = try JSON(bytes: response.body.bytes!)
            print(json)
            
        } catch {
            
        }
    }
}
