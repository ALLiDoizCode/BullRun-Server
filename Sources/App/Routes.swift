import Vapor

extension Droplet {
    func setupRoutes() throws {
        
        
        get("balance") { req in
            
            guard let address = req.data["address"]?.string else {
                
                return Abort.badRequest.reason
            }
            let json = Ripple(drop:self).balance(address: address)
            
            return json
            
        }
        
        post("send") { req in
            
            guard let address1 = req.data["address1"]?.string else {
                
                return Abort.badRequest.reason
            }
            
            guard let address2 = req.data["address2"]?.string else {
                
                return Abort.badRequest.reason
            }
            
            guard let secret = req.data["secret"]?.string else {
                
                return Abort.badRequest.reason
            }
            
            guard let amount = req.data["amount"]?.string else {
                
                return Abort.badRequest.reason
            }
            
            let json = Ripple(drop:self).send(address1: address1, address2: address2, secret: secret, amount: amount)
            
            return json
            
        }
        
        post("betHour") { req in
            
            guard let address = req.data["address"]?.string else {
                
                return Abort.badRequest.reason
            }
            
            guard let secret = req.data["secret"]?.string else {
                
                return Abort.badRequest.reason
            }
            
            guard let amount = req.data["amount"]?.double else {
                
                return Abort.badRequest.reason
            }
            
            guard let coin = req.data["coin"]?.string else {
                
                return Abort.badRequest.reason
            }
            
            let wallet = Wallet()
            wallet.address = address
            wallet.hourBet.amount = amount
            wallet.dayBet.coinId = coin
            
            let roundAddress = String(describing: MongoClient().lastHourRound().2["address"])
            
            let json = Ripple(drop: self).send(address1: wallet.address, address2: roundAddress, secret: secret, amount: String(amount))
            
            let success = json["resultCode"]?.string
            
            if success == "tesSUCCESS" {
                
                print("currency sent")
                
                MongoClient().saveHourBet(wallet: wallet)
            }
            
            return json
        }
        
        post("betDay") { req in
            
            guard let address = req.data["address"]?.string else {
                
                return Abort.badRequest.reason
            }
            
            guard let secret = req.data["secret"]?.string else {
                
                return Abort.badRequest.reason
            }
            
            guard let amount = req.data["amount"]?.double else {
                
                return Abort.badRequest.reason
            }
            
            guard let coin = req.data["coin"]?.string else {
                
                return Abort.badRequest.reason
            }
            
            let wallet = Wallet()
            wallet.address = address
            wallet.dayBet.amount = amount
            wallet.dayBet.coinId = coin
            
            let roundAddress = String(describing: MongoClient().lastDayRound().2["address"])
            
            let json = Ripple(drop: self).send(address1: wallet.address, address2: roundAddress, secret: secret, amount: String(amount))
            
            let success = json["resultCode"]?.string
            
            if success == "tesSUCCESS" {
                
                print("currency sent")
                
                MongoClient().saveDayBet(wallet: wallet)
            }
            
            return json
        }
        
        post("betWeek") { req in
            
            guard let address = req.data["address"]?.string else {
                
                return Abort.badRequest.reason
            }
            
            guard let secret = req.data["secret"]?.string else {
                
                return Abort.badRequest.reason
            }
            
            guard let amount = req.data["amount"]?.double else {
                
                return Abort.badRequest.reason
            }
            
            guard let coin = req.data["coin"]?.string else {
                
                return Abort.badRequest.reason
            }
            
            let wallet = Wallet()
            wallet.address = address
            wallet.weekBet.amount = amount
            wallet.weekBet.coinId = coin
            
            let roundAddress = String(describing: MongoClient().lastWeekRound().2["address"])
            
            let json = Ripple(drop: self).send(address1: wallet.address, address2: roundAddress, secret: secret, amount: String(amount))
            
            let success = json["resultCode"]?.string
            
            if success == "tesSUCCESS" {
                
                print("currency sent")
                
                MongoClient().saveWeekBet(wallet: wallet)
            }
            
            return json
        }
        
        get("newAddress") { req in
            
            let json = Ripple(drop: self).generateWallet()
        
            return json
        }
        
        get("hourRound") { req in 
            
            Schedule(drop: self).hourRound()
            
            return "Running Hour Round"
            
        }
        
        get("dailyRound") { req in
            
            Schedule(drop: self).dayRound()
            
            return "Running Day Round"
            
        }
        
        get("weekRound") { req in
            
            Schedule(drop: self).weekRound()
            
            return "Running week Round"
            
        }
        
        get("payout") { req in
            
            let json = MongoClient().payouts()
            
            return json
        }
        
        get("HourCoins") { req in
            
            let json = MongoClient().lastHourRound().0.makeExtendedJSON()
            let bets = MongoClient().lastHourRound().1.makeExtendedJSON()
            let betCounts = MongoClient().lastHourRound().0.count
            
            let jsonObject:JSON = [
            
                "coin":json as! JSON,
                "bets":bets as! JSON,
                "betCounts":JSON(betCounts)
            ]
            
            return jsonObject
        }
        
        get("DayCoins") { req in
            
            let json = MongoClient().lastDayRound().0.makeExtendedJSON()
            let bets = MongoClient().lastDayRound().1.makeExtendedJSON()
            let betCounts = MongoClient().lastDayRound().0.count
            
            let jsonObject:JSON = [
                
                "coin":json as! JSON,
                "bets":bets as! JSON,
                "betCounts":JSON(betCounts)
            ]
            
            return jsonObject
        }
        
        get("WeekCoins") { req in
            
            let json = MongoClient().lastWeekRound().0.makeExtendedJSON()
            let bets = MongoClient().lastWeekRound().1.makeExtendedJSON()
            let betCounts = MongoClient().lastWeekRound().0.count
            
            let jsonObject:JSON = [
                
                "coin":json as! JSON,
                "bets":bets as! JSON,
                "betCounts":JSON(betCounts)
            ]
            
            return jsonObject
        }
        
        try resource("posts", PostController.self)
    }
}
