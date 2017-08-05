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
        
        get("loaderio-d58ed4d0fbe205d391f2c16dee45f3eb") { req in
            
            return MongoClient(database: database).benchMark()
        }
        
        get("balance") { req in
            
            guard let address = req.data["address"]?.string else {
                
                throw Abort.badRequest
            }
            let json = Ripple(drop:self).balance(address: address)
            
            return json
            
        }
        
        post("send") { req in
            
            guard let address1 = req.data["address1"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let address2 = req.data["address2"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let secret = req.data["secret"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let amount = req.data["amount"]?.string else {
                
                throw Abort.badRequest
            }
            
            let json = Ripple(drop:self).send(address1: address1, address2: address2, secret: secret, amount: amount)
            print(json["resultCode"]?.string)
            return json
            
        }
        
        post("betHour") { req in
            print(1)
            
            guard MongoClient(database: database).getHourStatus() == false else {
                
                return try! JSON(node:[
                        "betweenRounds":true
                    
                    ])
            }
            
            guard let address = req.data["address"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let secret = req.data["secret"]?.string else {
                
                throw Abort.badRequest
            }
            
            print(2)
            
            guard let amount = req.data["amount"]?.string else {
                
                throw Abort.badRequest
            }
            print(3)
            guard let coin = req.data["coin"]?.string else {
                
                throw Abort.badRequest
            }
            print(4)
            
            print(Double(amount)!)
            
            let wallet = Wallet()
            wallet.address = address
            wallet.hourBet.amount = Double(amount)!
            wallet.hourBet.coinId = coin
            
            let roundAddress = String(describing: MongoClient(database:database).lastHourRound().2["address"]!)
            
            let decrypted = MongoClient(database: database).decrypt(text: roundAddress)
            
            print(decrypted)
            
            let json = Ripple(drop: self).send(address1: wallet.address, address2: decrypted, secret: secret, amount: String(amount))
            
            let success = json["resultCode"]?.string
            
            if success == "tesSUCCESS" {
                
                print("currency sent")
                
                MongoClient(database:database).saveHourBet(wallet: wallet)
            }
            
            return json
        }
        
        post("betDay") { req in
            
            guard MongoClient(database: database).getDayStatus() == false else {
                
                return try! JSON(node:[
                    "betweenRounds":true
                    
                    ])
            }
            
            guard let address = req.data["address"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let secret = req.data["secret"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let amount = req.data["amount"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let coin = req.data["coin"]?.string else {
                
                throw Abort.badRequest
            }
            
            let wallet = Wallet()
            wallet.address = address
            wallet.dayBet.amount = Double(amount)!
            wallet.dayBet.coinId = coin
            
            let roundAddress = String(describing: MongoClient(database:database).lastDayRound().2["address"]!)
            
            let decrypted = MongoClient(database: database).decrypt(text: roundAddress)
            
            print(decrypted)
            
            let json = Ripple(drop: self).send(address1: wallet.address, address2: decrypted, secret: secret, amount: String(amount))
            
            let success = json["resultCode"]?.string
            
            if success == "tesSUCCESS" {
                
                print("currency sent")
                
                MongoClient(database:database).saveDayBet(wallet: wallet)
            }
            
            return json
        }
        
        post("betWeek") { req in
            
            guard MongoClient(database: database).getWeekStatus() == false else {
                
                return try! JSON(node:[
                    "betweenRounds":true
                    
                    ])
            }
            
            guard let address = req.data["address"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let secret = req.data["secret"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let amount = req.data["amount"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let coin = req.data["coin"]?.string else {
                
                throw Abort.badRequest
            }
            
            let wallet = Wallet()
            wallet.address = address
            wallet.weekBet.amount = Double(amount)!
            wallet.weekBet.coinId = coin
            
            let roundAddress = String(describing: MongoClient(database:database).lastWeekRound().2["address"]!)
            
            let decrypted = MongoClient(database: database).decrypt(text: roundAddress)
            
            print(decrypted)
            
            let json = Ripple(drop: self).send(address1: wallet.address, address2: decrypted, secret: secret, amount: String(amount))
            
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
            
            MongoClient(database: database).setHourStatus(status: true)
            
            Schedule(drop: self,database: database).hourRound()
            
            MongoClient(database: database).setHourStatus(status: false)
            
            return "Running Hour Round"
            
        }
        
        get("dailyRound") { req in
            
            MongoClient(database: database).setDayStatus(status: true)
            
            Schedule(drop: self,database: database).dayRound()
            
            MongoClient(database: database).setDayStatus(status: false)
            
            return "Running Day Round"
            
        }
        
        get("weekRound") { req in
            
            MongoClient(database: database).setWeekStatus(status: true)
            
            Schedule(drop: self,database: database).weekRound()
            
            MongoClient(database: database).setWeekStatus(status: false)
            
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
        
        get("check") { req in
            
            Schedule(drop: self, database: database).hourRound()
            
            let round = MongoClient(database: database).lastHourRound()
            
            let decryptAddress = MongoClient(database: database).decrypt(text: String(describing: round.2["address"]!))
            
            let round2 = MongoClient(database: database).lastDayRound()
            
            let decryptAddress2 = MongoClient(database: database).decrypt(text: String(describing: round2.2["address"]!))
            
            let json = Ripple(drop:self).balance(address: decryptAddress)
            let json2 = Ripple(drop:self).balance(address: decryptAddress2)
            
            print(json)
            print(json2)
            
            return try! JSON(node:[
                
                    "hour":json,
                    "day":json2
                ])
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
