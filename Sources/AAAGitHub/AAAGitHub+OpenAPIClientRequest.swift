//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/12/3.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes
import AAA

extension Components.Schemas.access_token_response : AAARefreshableToken{
    
}

extension AAAGitHub{

    public enum TokenUrl :  TokenUrlProtocol{
        case request_token(code: String, authFlow: AAAGitHub)
        //case refresh_token(refresh_token: String, authFlow: AAAGitHub)
        
        public var client: Client{
            switch self {
            case .request_token(_ , let authFlow):
                switch authFlow {
                case .github_app_user_access_token_webflow,
                        .oauth_app_user_access_token_webflow:
                    return Client(
                        serverURL: try! Servers.server1(),
                        transport: URLSessionTransport()
                        //middlewares: [AuthenticationMiddleware(clientId: client_id, clientSecret: client_secret)]
                    )
                }
            }
        }
        public var request : Components.Schemas.access_token_request{
            switch self{
            case .request_token(let code, let authFlow):
                switch authFlow{
                case .github_app_user_access_token_webflow(client_id: let client_id, client_secret: let client_secret, redirect_uri: let redirect_uri):
                    return .init(code: code, client_id: client_id, client_secret: client_secret, redirect_uri: redirect_uri.absoluteString)
                case .oauth_app_user_access_token_webflow(client_id: let client_id, client_secret: let client_secret, redirect_uri: let redirect_uri, _):
                    return .init(code: code, client_id: client_id, client_secret: client_secret, redirect_uri: redirect_uri.absoluteString )
                
                }
            }
            
        }
        public typealias Response = Components.Schemas.access_token_response
        
        public static func fetchOpenAPI(clientRequest: Self)async throws->Response{
            let tokenResponse = try await clientRequest.client.login_sol_oauth_sol_access_token(body: .urlEncodedForm(clientRequest.request))
            
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
