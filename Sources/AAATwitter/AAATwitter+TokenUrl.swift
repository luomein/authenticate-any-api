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
import AAA

extension Components.Schemas.access_token_response : AAARefreshableToken{
    
}

public extension AAATwitter{

    enum TokenUrl :  TokenUrlProtocol{

        case request_token(code: String?, authFlow: AAATwitter)
        case refresh_token(refresh_token: String, authFlow: AAATwitter)
        
        var grant_type : String{
            switch self{
            case .request_token(_, let auth):
                switch auth{
                case   .authorization_code_PKCE:
                    return "authorization_code"
                case .clientCredentials:
                    return "client_credentials"
                }
                
            case .refresh_token:
                return  "refresh_token"
            }
        }
        public var client: Client{
            switch self {
            case .request_token(_ , let authFlow),
                    .refresh_token(_, let authFlow):
                switch authFlow {
                 
                case .authorization_code_PKCE(let client_id, let redirect_uri, _, let code_verifier, _ , _ ):
                    return Client(
                        serverURL: try! Servers.server1(),
                        transport: URLSessionTransport()
                    )
                //case .clientCredentials(let client_id, let client_secret):
                case .clientCredentials(consumer_api_key: let consumer_api_key, consumer_api_secret: let consumer_api_secret):
                    return Client(
                        serverURL: try! Servers.server1(),
                        transport: URLSessionTransport(),
                        middlewares: [AuthenticationMiddleware(clientId: consumer_api_key, clientSecret: consumer_api_secret)]
                    )
                }
            }
        }
        public var request : Components.Schemas.access_token_request{
            switch self{
            case .request_token(let code,let authFlow):
                switch authFlow{
                case .authorization_code_PKCE(client_id: let client_id, redirect_uri: let redirect_uri, code_challenge: let code_challenge, code_verifier: let code_verifier, _, _):
                    return .init(code: code,grant_type: self.grant_type, client_id: client_id, redirect_uri: redirect_uri.absoluteString,code_verifier: code_verifier)
                //case .clientCredentials(consumer: let client_id, client_secret: let client_secret):
                case .clientCredentials:
                    return .init(grant_type: self.grant_type)
                }
                
            case .refresh_token(let refresh_token, let authFlow):
                if case .authorization_code_PKCE(let client_id, _, _, _, _, _) = authFlow{
                    return .init(grant_type: self.grant_type, refresh_token: refresh_token, client_id: client_id)
                }
                else{
                    return .init(grant_type: self.grant_type, refresh_token: refresh_token)
                }
           
            }
        }
        public typealias Response = Components.Schemas.access_token_response
        
        public static func fetchOpenAPI(clientRequest: Self)async throws->Response{
            
            if clientRequest.grant_type == "client_credentials"{
                let tokenResponse = try await clientRequest.client.api_sol_token_sol_clientCredentials(body: .urlEncodedForm(clientRequest.request))
                switch tokenResponse{
                case .ok(let okResponse):
                    guard case .json(let jsonBody) = okResponse.body else{fatalError()}
                    return jsonBody//.access_token
                case .undocumented(statusCode: let statusCode, let payload):
                    //print("🥺 undocumented response: \(statusCode)")
                    print(payload)
                    fatalError()
                }
            }
            else{
                let tokenResponse = try await clientRequest.client.api_sol_token(body: .urlEncodedForm(clientRequest.request))
                switch tokenResponse{
                case .ok(let okResponse):
                    guard case .json(let jsonBody) = okResponse.body else{fatalError()}
                    return jsonBody//.access_token
                case .undocumented(statusCode: let statusCode, let payload):
                    //print("🥺 undocumented response: \(statusCode)")
                    print(payload)
                    fatalError()
                }
            }
            
        }
    }
}
