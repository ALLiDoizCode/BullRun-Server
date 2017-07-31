import Vapor

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            Ripple(drop:self).send(address1: "rNhd9kzNBS4foYxm6NLHBj5Ve3XPVeBo2k", address2: "rKTZNXALMGFHPM3GoxqS2MZ9P8dGA5yoVg", secret: "snYzgmDkteVeeGRNmaUeTowS1712K", amount: "0.01")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        try resource("posts", PostController.self)
    }
}
