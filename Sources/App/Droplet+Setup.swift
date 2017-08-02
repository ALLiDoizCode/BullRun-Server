@_exported import Vapor
import MongoKitten
extension Droplet {
    public func setup() throws {
        
        try setupRoutes()
        // Do any additional droplet setup
    }
}
