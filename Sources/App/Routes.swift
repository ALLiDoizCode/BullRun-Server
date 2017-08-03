import Vapor
import MongoKitten
extension Droplet {
    func setupRoutes() throws {
        
        let server = try! Server("mongodb://heroku_h8lrwkbq:ntcqd6852m09ie14o2v6h4ktqv@ds129003.mlab.com:29003/heroku_h8lrwkbq")
        let database = server["heroku_h8lrwkbq"]
        if database.server.isConnected {
            
            print("Successfully connected!")
            
        } else {
            print("Connection failed")
        }
        
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
            
            let roundAddress = String(describing: MongoClient(database:database).lastHourRound().2["address"])
            
            let json = Ripple(drop: self).send(address1: wallet.address, address2: roundAddress, secret: secret, amount: String(amount))
            
            let success = json["resultCode"]?.string
            
            if success == "tesSUCCESS" {
                
                print("currency sent")
                
                MongoClient(database:database).saveHourBet(wallet: wallet)
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
            
            let roundAddress = String(describing: MongoClient(database:database).lastDayRound().2["address"])
            
            let json = Ripple(drop: self).send(address1: wallet.address, address2: roundAddress, secret: secret, amount: String(amount))
            
            let success = json["resultCode"]?.string
            
            if success == "tesSUCCESS" {
                
                print("currency sent")
                
                MongoClient(database:database).saveDayBet(wallet: wallet)
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
            
            let roundAddress = String(describing: MongoClient(database:database).lastWeekRound().2["address"])
            
            let json = Ripple(drop: self).send(address1: wallet.address, address2: roundAddress, secret: secret, amount: String(amount))
            
            let success = json["resultCode"]?.string
            
            if success == "tesSUCCESS" {
                
                print("currency sent")
                
                MongoClient(database:database).saveWeekBet(wallet: wallet)
            }
            
            return json
        }
        
        get("newAddress") { req in
            
            let json = Ripple(drop: self).generateWallet()
        
            return json
        }
        
        get("hourRound") { req in 
            
            Schedule(drop: self,database: database).hourRound()
            
            return "Running Hour Round"
            
        }
        
        get("dailyRound") { req in
            
            Schedule(drop: self,database: database).dayRound()
            
            return "Running Day Round"
            
        }
        
        get("weekRound") { req in
            
            Schedule(drop: self,database: database).weekRound()
            
            return "Running week Round"
            
        }
        
        get("payout") { req in
            
            let json = MongoClient(database:database).payouts()
            
            var payouts:[JSON] = []
            
            for payout in json {
                
                let object = try! JSON(node: [
                    
                    "address":payout["address"],
                    "amount":payout["amount"]
                    
                    ])
                
                
                payouts.append(object)
            }
            
            let jsonObject = try! JSON(node: [
                
                    "payouts":payouts
                ])
            
            return jsonObject
        }
        
        get("HourCoins") { req in
            
            let coins = MongoClient(database:database).lastHourRound().0.array
            let bets = MongoClient(database:database).lastHourRound().1.array
            let betCounts = MongoClient(database:database).lastHourRound().1.count
            
            var coinObject:[JSON] = []
            var betObject:[JSON] = []
            
            for coin in coins {
                
                let object = try! JSON(node: [
                    
                        "coin":coin["coin"],
                        "name":coin["name"],
                        "percent":coin["percent"],
                        "usd":coin["usd"],
                        "BTC":coin["BTC"],
                        
                    ])
                
                
                coinObject.append(object)
            }
            
            for bet in bets {
                
                let object = try! JSON(node: [
                    
                    "address":bet["address"],
                    "coin":bet["coin"],
                    "amount":bet["amount"],
                    
                    ])
                
                
                betObject.append(object)
            }
            
            let jsonObject = try! JSON(node: [
                
                    "coin":coinObject,
                    "bets":betObject,
                    "betCounts":betCounts
                
                ])
            
            
            return jsonObject
        }
        
        get("DayCoins") { req in
            
            let coins = MongoClient(database:database).lastDayRound().0.array
            let bets = MongoClient(database:database).lastDayRound().1.array
            let betCounts = MongoClient(database:database).lastDayRound().1.count
            
            var coinObject:[JSON] = []
            var betObject:[JSON] = []
            
            for coin in coins {
                
                let object = try! JSON(node: [
                    
                    "coin":coin["coin"],
                    "name":coin["name"],
                    "percent":coin["percent"],
                    "usd":coin["usd"],
                    "BTC":coin["BTC"],
                    
                    ])
                
                
                coinObject.append(object)
            }
            
            for bet in bets {
                
                let object = try! JSON(node: [
                    
                    "address":bet["address"],
                    "coin":bet["coin"],
                    "amount":bet["amount"],
                    
                    ])
                
                
                betObject.append(object)
            }
            
            let jsonObject = try! JSON(node: [
                
                "coin":coinObject,
                "bets":betObject,
                "betCounts":betCounts
                
                ])
            
            
            return jsonObject
        }
        
        get("WeekCoins") { req in
            
            let coins = MongoClient(database:database).lastWeekRound().0.array
            let bets = MongoClient(database:database).lastWeekRound().1.array
            let betCounts = MongoClient(database:database).lastWeekRound().1.count
            
            var coinObject:[JSON] = []
            var betObject:[JSON] = []
            
            for coin in coins {
                
                let object = try! JSON(node: [
                    
                    "coin":coin["coin"],
                    "name":coin["name"],
                    "percent":coin["percent"],
                    "usd":coin["usd"],
                    "BTC":coin["BTC"],
                    
                    ])
                
                
                coinObject.append(object)
            }
            
            for bet in bets {
                
                let object = try! JSON(node: [
                    
                    "address":bet["address"],
                    "coin":bet["coin"],
                    "amount":bet["amount"],
                    
                    ])
                
                
                betObject.append(object)
            }
            
            let jsonObject = try! JSON(node: [
                
                "coin":coinObject,
                "bets":betObject,
                "betCounts":betCounts
                
                ])
            
            
            return jsonObject
        }
        
        try resource("posts", PostController.self)
    }
}
