//
//  Router.swift
//  BullRun-Server
//
//  Created by Jonathan Green on 7/28/17.
//
//

import Foundation
import Alamofire

enum RippleRouter: URLRequestConvertible {
    case generateWallet()
    
    /*let realServer = "https://104.45.238.97"
    let testServer = "wss://s.altnet.rippletest.net:51233"
    let wallet1 = "rLC8p3HFDgSkfPnW8qsExWD724mLP4ZiYd"
    let secert1 = "snrHuTY3tT3iEM3BEqon3ZjwsvL8a"
    let wallet2 = "rJUDTXW7gUCUrfg7vfsKBjdmCwH4XVbWtk"
    let secert2 = "ssqc9ZnkGGXfiEWtAhsVR27rKdBQE"*/
    static var baseURLString = " https://ripple-server.herokuapp.com"
    
    var method: HTTPMethod {
        switch self {
        case .generateWallet:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .generateWallet():
            return "/newAddress"
        }
    }
    
    // MARK: URLRequestConvertible
    
        public func asURLRequest() throws -> URLRequest {
            let url = URL(string: "\(RippleRouter.baseURLString)\(self.path)")!
            var request = URLRequest(url: url)
            print("url is \(String(describing: request.url))")
            request.httpMethod = method.rawValue
            //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            //request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
            //request.httpShouldUsePipelining = false
            //request.setValue("di3twater", forHTTPHeaderField: "admin_user")
            //request.setValue("AMber19*", forHTTPHeaderField: "admin_password")
            /*if let token = Router.OAuthToken {
             request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
             }*/
            
        switch self {
            case .generateWallet():
                /*let raw:Data! = try! phrase.data(using: .utf8)
                
                if let data = raw {
                    request.httpBody = data
                } else {
                    assertionFailure()
                }*/
                return request
            
                default: return request
            }
            
            return request
        }
}
