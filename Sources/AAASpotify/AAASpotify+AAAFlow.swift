//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/26.
//

import Foundation
import AAA
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes

extension AAASpotify: AAAFlow{
    public var needUserWebAuth : Bool{
        switch self {
        case .authorization_code, .authorization_code_PKCE:
            return true
        case .clientCredentials:
            return false
        }
    }
    
    public var canRefreshToken : Bool{
        switch self {
        case .authorization_code, .authorization_code_PKCE:
            return true
        case .clientCredentials:
            return false
        }
    }
    public func userWebAuthParameter(prefersEphemeralWebBrowserSession: Bool) ->  AsyncUserWebAuthAgent.Parameter?{
        guard needUserWebAuth else {return nil}
        switch self {
        case .authorization_code(let client_id, _, let redirect_uri, let scope, let state):
            let userWebAuthURL = Self.userWebAuthURL(redirect_uri: redirect_uri
                                                     , client_id: client_id
                                                     , scope: scope
                                                     , state: state)
            return .init(url: userWebAuthURL, redirect_uri: redirect_uri, prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession, response_type: Const.responseType)
        case .authorization_code_PKCE(client_id: let client_id, redirect_uri: let redirect_uri,  code_challenge: let code_challenge, _, let scope, let state):
            let userWebAuthURL = Self.userWebAuthURL(redirect_uri: redirect_uri
                                                     , client_id: client_id
                                                     , scope: scope
                                                     , state: state
                                                     , code_challenge_method: Const.codeChallengeMethod
                                                     , code_challenge: code_challenge
                                                     )
            return .init(url: userWebAuthURL, redirect_uri: redirect_uri, prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession, response_type: Const.responseType)
        default:
            return nil
        }
    }
    public func requestToken(authorizedCode: String?)->OpenAPIClientRequest{
        switch self {
        case .authorization_code(let client_id, let client_secret, let redirect_uri, _ , _):
            let client = Client(
                serverURL: try! Servers.server1(),
                transport: URLSessionTransport(),
                middlewares: [AuthenticationMiddleware(clientId: client_id, clientSecret: client_secret)]
            )
            let request = OpenAPIRequest.request_token(code: authorizedCode, authFlow: self).request
            return .init(client: client, request: request)
        case .authorization_code_PKCE(let client_id, let redirect_uri, _, let code_verifier, _ , _ ):
            let client = Client(
                serverURL: try! Servers.server1(),
                transport: URLSessionTransport()
            )
            let request = OpenAPIRequest.request_token(code: authorizedCode, authFlow: self).request
            return .init(client: client, request: request)
        case .clientCredentials(let client_id, let client_secret):
            let client = Client(
                serverURL: try! Servers.server1(),
                transport: URLSessionTransport(),
                middlewares: [AuthenticationMiddleware(clientId: client_id, clientSecret: client_secret)]
            )
            let request = OpenAPIRequest.request_token(code: authorizedCode, authFlow: self).request
            return .init(client: client, request: request)
        }
    }
    public func refreshToken(refreshToken: String?)->OpenAPIClientRequest{
        guard canRefreshToken, let refreshToken = refreshToken else{
            fatalError()
        }
        let grant_type = "refresh_token"
        switch self {
        case .authorization_code(let client_id, let client_secret, let redirect_uri, _ , _):
            let client = Client(
                serverURL: try! Servers.server1(),
                transport: URLSessionTransport(),
                middlewares: [AuthenticationMiddleware(clientId: client_id, clientSecret: client_secret)]
            )
            let request = OpenAPIRequest.refresh_token(refresh_token: refreshToken, authFlow: self).request
            return .init(client: client, request: request)
        case .authorization_code_PKCE(let client_id, let redirect_uri, _, let code_verifier, _ , _ ):
            let client = Client(
                serverURL: try! Servers.server1(),
                transport: URLSessionTransport()
            )
            let request = OpenAPIRequest.refresh_token(refresh_token: refreshToken, authFlow: self).request
            return .init(client: client, request: request)
        case .clientCredentials:
            fatalError()
        }
    }
    public static func fetchRequest(clientRequest: OpenAPIClientRequest)async throws->OpenAPIResponse{
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
