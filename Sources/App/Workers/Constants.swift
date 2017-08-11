//
//  Constants.swift
//  BullRun-Server
//
//  Created by Jonathan Green on 8/1/17.
//
//

import Foundation
import Vapor
import MongoKitten

class Constant {
    
    static var database:Database!
    static var drop:Droplet!
    
    init(database:Database,drop:Droplet) {
        
        Constant.database = database
        Constant.drop =  drop
    }
}

let stake:Double = 10.0
let fee:Double = 0.042
let OWNER_WALLET:String = "rNhd9kzNBS4foYxm6NLHBj5Ve3XPVeBo2k"
let OWNER_WALLET2:String = "rBWbvMfb1NxPFNn1FJmDeiwCrdVo4gaEG5"
let HASH_KEY = "penutbutterjelly"
let iv = "amberjonathan"


