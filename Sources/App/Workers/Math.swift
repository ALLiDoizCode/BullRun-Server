//
//  Math.swift
//  odds
//
//  Created by Jonathan Green on 7/26/17.
//
//

import Foundation
class Math {
    
    func winners1hr(coins:[Coin]) -> ([String],[Coin]) {
        
        var winningCoins:[String] = []
        var updatedCoins:[Coin] = []
        let max_1h = coins.map { $0.percent_change_1h }.max()
        
        for coin in coins {
            
            var newCoin = Coin()
            newCoin = coin
            
            if coin.percent_change_1h == max_1h {
                
                newCoin.hourWinnings.0 += 1
                winningCoins.append(coin.id)
                
            }else {
                
                newCoin.hourWinnings.1 += 1
            }
            
            updatedCoins.append(newCoin)
        }
        
        return (winningCoins,updatedCoins)
    }
    
    func winner24hr(coins:[Coin]) -> ([String],[Coin]) {
        
        var winningCoins:[String] = []
        var updatedCoins:[Coin] = []
        
        let max_24h = coins.map { $0.percent_change_24h }.max()
        
        for coin in coins {
            
            var newCoin = Coin()
            newCoin = coin
            
            if coin.percent_change_24h == max_24h {
                
                newCoin.dayWinnings.0 += 1
                winningCoins.append(coin.id)
                
            }else {
                
                newCoin.dayWinnings.1 += 1
            }
            
            updatedCoins.append(newCoin)
        }
        
        return (winningCoins,updatedCoins)
    }
    
    func winnerWeek(coins:[Coin]) -> ([String],[Coin]) {
        
        var winningCoins:[String] = []
        var updatedCoins:[Coin] = []
        
        let max_7d = coins.map { $0.percent_change_7d }.max()
        
        for coin in coins {
            
            var newCoin = Coin()
            newCoin = coin
            
            if coin.percent_change_7d == max_7d {
                
                newCoin.weekWinnings.0 += 1
                winningCoins.append(coin.id)
                
            }else {
                
                newCoin.weekWinnings.1 += 1
            }
            
            updatedCoins.append(newCoin)
            
        }
        
        return (winningCoins,updatedCoins)
    }
    
    func payout(winningBets:Double,currentBet:Double,pool:Double,stake:Double) -> Double {
        
        let points = currentBet / stake
        let take = (points / winningBets)
        let amount = pool * take
        let profit = amount - currentBet
        
        print("will divide \(points) by \(winningBets)")
        
        print("putin \(currentBet)")
        print("take \(take * 100) percent")
        print("bets \(winningBets)")
        print("points \(points)")
        print("profit \(profit)")
        print("payout \(amount)")
        
        return amount
    }
    
    /*typealias Rational = (num : Double, den : Double)
    
    func rationalApproximation(of x0 : Double, withPrecision eps : Double = 1.0E-6) -> Rational {
        var x = x0
        var a = x.rounded(.down)
        var (h1, k1, h, k) = (1, 0, Int(a), 1)
        
        while x - a > eps * Double(k) * Double(k) {
            x = 1.0/(x - a)
            a = x.rounded(.down)
            (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
        }
        return (Double(h), Double(k))
    }*/
}
