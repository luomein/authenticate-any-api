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

public extension AAASpotify{
//    struct OpenAPIClientRequest: Equatable{
//        public static func == (lhs: Self, rhs: Self) -> Bool {
//            return true
//        }
//
//        public var client: Client
//        public var request: Components.Schemas.access_token_request
//
//
//    }
    public enum OpenAPIClientRequest :  OpenAPIClientRequestProtocol{

        case request_token(code: String?, authFlow: AAASpotify)
        case refresh_token(refresh_token: String, authFlow: AAASpotify)
        
        var grant_type : String{
            switch self{
            case .request_token(_, let auth):
                switch auth{
                case .authorization_code, .authorization_code_PKCE:
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
                case .authorization_code(let client_id, let client_secret, let redirect_uri, _ , _):
                    return Client(
                        serverURL: try! Servers.server1(),
                        transport: URLSessionTransport(),
                        middlewares: [AuthenticationMiddleware(clientId: client_id, clientSecret: client_secret)]
                    )
                case .authorization_code_PKCE(let client_id, let redirect_uri, _, let code_verifier, _ , _ ):
                    return Client(
                        serverURL: try! Servers.server1(),
                        transport: URLSessionTransport()
                    )
                case .clientCredentials(let client_id, let client_secret):
                    return Client(
                        serverURL: try! Servers.server1(),
                        transport: URLSessionTransport(),
                        middlewares: [AuthenticationMiddleware(clientId: client_id, clientSecret: client_secret)]
                    )
                }
            }
        }
        public var request : Components.Schemas.access_token_request{
            switch self{
            case .request_token(let code,let authFlow):
                switch authFlow{
                case .authorization_code(let client_id, let client_secret, let redirect_uri, _, _):
                    return .init(code: code,grant_type: self.grant_type, redirect_uri: redirect_uri.absoluteString)
                case .authorization_code_PKCE(client_id: let client_id, redirect_uri: let redirect_uri, code_challenge: let code_challenge, code_verifier: let code_verifier, _, _):
                    return .init(code: code,grant_type: self.grant_type, client_id: client_id, redirect_uri: redirect_uri.absoluteString,code_verifier: code_verifier)
                case .clientCredentials(client_id: let client_id, client_secret: let client_secret):
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
            let tokenResponse = try await clientRequest.client.api_sol_token(body: .urlEncodedForm(clientRequest.request))
            
            switch tokenResponse{
            case .ok(let okResponse):
                guard case .json(let jsonBody) = okResponse.body else{fatalError()}
                return jsonBody//.access_token
            case .undocumented(statusCode: let statusCode, _):
                //print("🥺 undocumented response: \(statusCode)")
                fatalError()
            }
        }
    }
}
