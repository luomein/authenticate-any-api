//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/26.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes

public extension AAASpotify{
    struct OpenAPIClientRequest: Equatable{
        public static func == (lhs: Self, rhs: Self) -> Bool {
            return true
        }
       
        public var client: Client
        public var request: Components.Schemas.access_token_request
        
        
    }
}
