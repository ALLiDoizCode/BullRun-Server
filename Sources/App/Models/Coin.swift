//
//  Coin.swift
//  odds
//
//  Created by Jonathan Green on 7/26/17.
//
//

import Foundation
import Unbox
class Coin {
    
    var id:String = ""
    var name:String! = nil
    var _24h_volume_usd:Double!
    var available_supply:Double!
    var percent_change_1h:Double!
    var percent_change_24h:Double!
    var percent_change_7d:Double!
    var price_usd:Double!
    var price_btc:Double!
    var rank:Int!
    var symbol:String!
    var total_supply:String!
    var hourWinnings:(Int,Int) = (0,0)
    var dayWinnings:(Int,Int) = (0,0)
    var weekWinnings:(Int,Int) = (0,0)
    
    /*func odds(bets:[Bet]) -> (Double,Double) {
        
        var thisCoin:Double = 0
        var otherCoin:Double = 0
        
        for bet in bets {
            
            if bet.coinId == self.id {
                
                thisCoin += 1
                
            }else {
                
                otherCoin += 1
                
            }
        }
        
        return (thisCoin,otherCoin)
    }*/
    
}
