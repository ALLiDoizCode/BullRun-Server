import Vapor
import MongoKitten
import Jobs
extension Droplet {
    
    
    func setupRoutes() throws {
        
        let server = try! Server("mongodb://heroku_h8lrwkbq:ntcqd6852m09ie14o2v6h4ktqv@ds129003.mlab.com:29003/heroku_h8lrwkbq")
        let database = server["heroku_h8lrwkbq"]
        if database.server.isConnected {
            Constant(database:database,drop:self)

            print("Successfully connected!")
            
            MongoClient.sharedInstance = MongoClient(database: database)
            
        } else {
            print("Connection failed")
        }
        
        /*self.socket("transcation", handler: { (req, ws) in
            
            Jobs.add(interval: .seconds(4)) {
                
                try ws.ping()
            }
            
            ws.onText = { ws, text in
                
                Ripple.jobIds[text] = ws
            }
            
            ws.onClose = { ws, _, _, _ in
                
            }
        })*/
        
        get("loaderio-d58ed4d0fbe205d391f2c16dee45f3eb") { req in
            
            return MongoClient.sharedInstance.benchMark()
        }
        
        get("accountInfo") { req in
            
            guard let address = req.data["address"]?.string else {
                
                throw Abort.badRequest
            }
            let json = Ripple(drop:self).accountInfo(address: address)
            
            return json
            
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
            
            let decryptedSender = MongoClient.sharedInstance.decrypt(text: address1)
            let decryptedReciever = MongoClient.sharedInstance.decrypt(text: address2)
            let decryptedSenderSecret = MongoClient.sharedInstance.decrypt(text: secret)
            
            print(decryptedSender)
            print(decryptedSenderSecret)
            
            let json = Ripple(drop: self).send(address1: decryptedSender, address2: decryptedReciever, secret: decryptedSenderSecret, amount: String(amount), coin: "", round: "")
            
            print(json["resultCode"]?.string)
            return json
            
        }
        
        post("betHour") { req in
            print(1)
            
            guard MongoClient.sharedInstance.getHourStatus() == false else {
                
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
            
            let roundAddress = String(describing: MongoClient.sharedInstance.lastHourRound().2["address"]!)
            
            let decrypted = MongoClient.sharedInstance.decrypt(text: roundAddress)
            //let decryptedSender = MongoClient.sharedInstance.decrypt(text: address)
            //let decryptedSenderSecret = MongoClient.sharedInstance.decrypt(text: secret)
            
            //print(decrypted)
            //print(decryptedSender)
            //print(decryptedSenderSecret)
            
            let json = Ripple(drop: self).send(address1: address, address2: decrypted, secret: secret, amount: String(amount),coin:coin, round: "hour")
            
            let success = json["resultCode"]?.string
            
            /*if success == "tesSUCCESS" {
                
                print("currency sent")
                
                MongoClient.sharedInstance.saveHourBet(wallet: wallet)
            }*/
            
            return json
        }
        
        post("betDay") { req in
            
            guard MongoClient.sharedInstance.getDayStatus() == false else {
                
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
            
            let roundAddress = String(describing: MongoClient.sharedInstance.lastDayRound().2["address"]!)
            
            let decrypted = MongoClient.sharedInstance.decrypt(text: roundAddress)
            //let decryptedSender = MongoClient.sharedInstance.decrypt(text: address)
            //let decryptedSenderSecret = MongoClient.sharedInstance.decrypt(text: secret)
            
            print(decrypted)
            //print(decryptedSender)
            //print(decryptedSenderSecret)
            
            let json = Ripple(drop: self).send(address1: address, address2: decrypted, secret: secret, amount: String(amount),coin:coin, round: "day")
            
            let success = json["resultCode"]?.string
            
            /*if success == "tesSUCCESS" {
                
                print("currency sent")
                
                MongoClient.sharedInstance.saveDayBet(wallet: wallet)
            }*/
            
            return json
        }
        
        post("betWeek") { req in
            
            guard MongoClient.sharedInstance.getWeekStatus() == false else {
                
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
            
            let roundAddress = String(describing: MongoClient.sharedInstance.lastWeekRound().2["address"]!)
            
            let decrypted = MongoClient.sharedInstance.decrypt(text: roundAddress)
            //let decryptedSender = MongoClient.sharedInstance.decrypt(text: address)
            //let decryptedSenderSecret = MongoClient.sharedInstance.decrypt(text: secret)
            
            print(decrypted)
            //print(decryptedSender)
            //print(decryptedSenderSecret)
            
            let json = Ripple(drop: self).send(address1: address, address2: decrypted, secret: secret, amount: String(amount),coin:coin, round: "week")
            
            let success = json["resultCode"]?.string
            
            
            return json
        }
        
        get("insertBets") { req in
            
            //MongoClient.sharedInstance.insertHourBets()
            //MongoClient.sharedInstance.insertDayBets()
            //MongoClient.sharedInstance.insertweekBets()
            
            return "Inserted Bets to Database"
        }
        
        post("savePayout") { req in
            
            guard let address = req.data["address"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let amount = req.data["amount"]?.double else {
                
                throw Abort.badRequest
            }
            
            guard let coin = req.data["coin"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let jobId = req.data["jobId"]?.string else {
                
                throw Abort.badRequest
            }
            
            
            print(address)
            print(amount)
            print(coin)
            let wallet = Wallet()
            wallet.address = address
            wallet.hourBet.amount = amount
            wallet.hourBet.coinId = coin
            
            MongoClient.sharedInstance.savePayout(address: address, amount: amount)
            
            print("saved job \(jobId)")
            
            //let ws = Ripple.jobIds[jobId]
            
            //try! ws?.send("Bet Succesful")
            
            return "saved payout"
        }
        
        post("saveHourBets") { req in
            
            guard let address = req.data["address"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let amount = req.data["amount"]?.double else {
                
                throw Abort.badRequest
            }
            
            guard let coin = req.data["coin"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let jobId = req.data["jobId"]?.string else {
                
                throw Abort.badRequest
            }
            
            
            print(address)
            print(amount)
            print(coin)
            let wallet = Wallet()
            wallet.address = address
            wallet.hourBet.amount = amount
            wallet.hourBet.coinId = coin
            
            MongoClient.sharedInstance.saveHourBet(wallet: wallet)
            MongoClient.sharedInstance.insertHourBets()
            
            print("saved job \(jobId)")
            
            //let ws = Ripple.jobIds[jobId]
            
            //try! ws?.send("Bet Succesful")
            
            return "saved job \(jobId)"
        }
        
        post("saveDayBets") { req in
            
            guard let address = req.data["address"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let amount = req.data["amount"]?.double else {
                
                throw Abort.badRequest
            }
            
            guard let coin = req.data["coin"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let jobId = req.data["jobId"]?.string else {
                
                throw Abort.badRequest
            }
            
            let wallet = Wallet()
            wallet.address = address
            wallet.dayBet.amount = amount
            wallet.dayBet.coinId = coin
            
            MongoClient.sharedInstance.saveDayBet(wallet: wallet)
            MongoClient.sharedInstance.insertDayBets()
            
            print("saved job")
            
            //let ws = Ripple.jobIds[jobId]
            
            //try! ws?.send("Bet Succesful")
            
            return "saved job "
        }
        
        post("saveWeekBets") { req in
            
            guard let address = req.data["address"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let amount = req.data["amount"]?.double else {
                
                throw Abort.badRequest
            }
            
            guard let coin = req.data["coin"]?.string else {
                
                throw Abort.badRequest
            }
            
            guard let jobId = req.data["jobId"]?.string else {
                
                throw Abort.badRequest
            }
            
            let wallet = Wallet()
            wallet.address = address
            wallet.weekBet.amount = amount
            wallet.weekBet.coinId = coin
            
            MongoClient.sharedInstance.saveWeekBet(wallet: wallet)
            MongoClient.sharedInstance.insertweekBets()
            print("saved job \(jobId)")
            
            //let ws = Ripple.jobIds[jobId]
            
            //try! ws?.send("Bet Succesful")
            
            return "saved job "
        }
        
        get("newAddress") { req in
            
            let json = Ripple(drop: self).generateWallet()
        
            return json
        }
        
        get("hourRound") { req in 
            
            MongoClient.sharedInstance.setHourStatus(status: true)
            
            //MongoClient.sharedInstance.insertHourBets()
           
            //MongoClient.hourBetArray = []
            
            Jobs.oneoff {
                
                Schedule(drop: self,database: database).hourRound()
                
            }
            

            return "Running Hour Round"
            
        }
        
        get("dailyRound") { req in
            
           MongoClient.sharedInstance.setDayStatus(status: true)
            
            //let insertedDocuments = MongoClient.sharedInstance.insertDayBets()
            
            //MongoClient.dayBetArray = []
            
            Jobs.oneoff {
                
                Schedule(drop: self,database: database).dayRound()
                
            }
            
            return "Running Day Round"
            
        }
        
        get("weekRound") { req in
            
            MongoClient.sharedInstance.setWeekStatus(status: true)
            
            //let insertedDocuments = MongoClient.sharedInstance.insertweekBets()
            
            //MongoClient.weekBetArray = []
            
            Jobs.oneoff {
                
                Schedule(drop: self,database: database).weekRound()
                
            }
            
            return "Running week Round"
            
        }
        
        get("payout") { req in
            
            let json = MongoClient.sharedInstance.payouts()
            
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
            
            let coins = MongoClient.sharedInstance.lastHourRound().0.array
            let bets = MongoClient.sharedInstance.lastHourRound().1.array
            let betCounts = MongoClient.sharedInstance.lastHourRound().1.count
            
            var coinObject:[JSON] = []
            var betObject:[JSON] = []
            var oddsObject:[JSON] = []
            for coin in coins {
                
                let currentCoin = String(coin["coin"]!)!
                
                var coinBets = 0
                
                for bet in bets {
                    
                    let coinId = String(bet["coin"]!)!
                    
                    if coinId == currentCoin {
                        
                        coinBets += 1
                    }
                }
                
                let odds = try! JSON(node: [
                    
                    "coin":coin["coin"],
                    "bets":coinBets
                    ])
                oddsObject.append(odds)
                
                let object = try! JSON(node: [
                    
                        "coin":coin["coin"],
                        "name":coin["name"],
                        "percent":coin["percent"],
                        "usd":coin["usd"],
                        "BTC":coin["BTC"],
                        "created":coin["created"],
                        "currentBets":coinBets,
                        
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
                    "betCounts":betCounts,
                    "odds":oddsObject
                ])
            
            
            return jsonObject
        }
        
        get("DayCoins") { req in
            
            let coins = MongoClient.sharedInstance.lastDayRound().0.array
            let bets = MongoClient.sharedInstance.lastDayRound().1.array
            let betCounts = MongoClient.sharedInstance.lastDayRound().1.count
            
            var coinObject:[JSON] = []
            var betObject:[JSON] = []
            var oddsObject:[JSON] = []
            
            for coin in coins {
                
                let currentCoin = String(coin["coin"]!)!
                
                var coinBets = 0
                
                for bet in bets {
                    
                    let coinId = String(bet["coin"]!)!
                    
                    if coinId == currentCoin {
                        
                        coinBets += 1
                    }
                }
                
                let odds = try! JSON(node: [
                    
                        "coin":coin["coin"],
                        "bets":coinBets
                    ])
                oddsObject.append(odds)
                
                let object = try! JSON(node: [
                    
                    "coin":coin["coin"],
                    "name":coin["name"],
                    "percent":coin["percent"],
                    "usd":coin["usd"],
                    "BTC":coin["BTC"],
                    "created":coin["created"]
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
                "betCounts":betCounts,
                "odds":oddsObject
                
                ])
            
            
            return jsonObject
        }
        
        get("check") { req in
            
            let round = MongoClient.sharedInstance.lastHourRound()
            
            let decryptAddress = MongoClient.sharedInstance.decrypt(text: String(describing: round.2["address"]!))
            
            let round2 = MongoClient.sharedInstance.lastDayRound()
            
            let decryptAddress2 = MongoClient.sharedInstance.decrypt(text: String(describing: round2.2["address"]!))
            
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
            
            let coins = MongoClient.sharedInstance.lastWeekRound().0.array
            let bets = MongoClient.sharedInstance.lastWeekRound().1.array
            let betCounts = MongoClient.sharedInstance.lastWeekRound().1.count
            
            var coinObject:[JSON] = []
            var betObject:[JSON] = []
            
            for coin in coins {
                
                let currentCoin = String(coin["coin"]!)!
                
                var coinBets = 0
                
                for bet in bets {
                    
                    let coinId = String(bet["coin"]!)!
                    
                    if coinId == currentCoin {
                        
                        coinBets += 1
                    }
                }
                
                let object = try! JSON(node: [
                    
                    "coin":coin["coin"],
                    "name":coin["name"],
                    "percent":coin["percent"],
                    "usd":coin["usd"],
                    "BTC":coin["BTC"],
                    "created":coin["created"],
                    "bets":coinBets
                    
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
