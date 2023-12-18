//
//  SpotifyAuthorizationUrlTests.swift
//  
//
//  Created by MEI YIN LO on 2023/12/18.
//

import XCTest
import AAA

final class SpotifyAuthorizationUrlTests: XCTestCase {
    func fetchAuthorizationUrl(input: Sendable) async throws -> Sendable {
        let authorizationUrl = AuthorizationUrl()
        let parameter = input as! AuthorizationUrl.Parameter
        let response = try await authorizationUrl.asyncPopupWebLogin(url: parameter.url
                                                           , callbackURLScheme: parameter.redirect_uri.scheme!, prefersEphemeralWebBrowserSession: parameter.prefersEphemeralWebBrowserSession)
        let responseComponents = URLComponents(url: response, resolvingAgainstBaseURL: false)
        let code = responseComponents!.queryItems!.first(where: {$0.name == parameter.response_type})!.value!
        return code
    }
    func getURL(redirect_uri: URL, client_id: String, scope : [String]? = nil,  state : String? = nil
                                    , code_challenge_method : String? = nil
                                    , code_challenge : String? = nil
    ) -> URL{
        let base_url = "https://accounts.spotify.com/authorize"
        let convertScope : ([String]) -> String = { $0.joined(separator: " ") }
        var queryItems : [URLQueryItem] = [
            URLQueryItem(name: "client_id" , value: client_id),
            URLQueryItem(name: "redirect_uri" , value: redirect_uri.absoluteString),
            URLQueryItem(name: "response_type" , value: "code"),
            
       ]
        if let scope = scope, !scope.isEmpty{
            queryItems.append(URLQueryItem(name: "scope", value: convertScope(scope)))
        }
        if let state = state{
            queryItems.append(URLQueryItem(name: "state", value: state))
        }
        if let code_challenge{
            queryItems.append(URLQueryItem(name: "code_challenge_method" , value: code_challenge_method!))
            queryItems.append(URLQueryItem(name: "code_challenge" , value: code_challenge))
        }
        var components = URLComponents(string: base_url)!
        components.queryItems = queryItems
        return components.url!
    }
    func test() async throws {
        typealias credential = Credential.SpotifyAuth
        let url = getURL(redirect_uri: credential.redirect_uri
                                           , client_id: credential.client_id
                                           )
        let parameter = AuthorizationUrl.Parameter(url: url
                                                        , redirect_uri: credential.redirect_uri
                                                        , prefersEphemeralWebBrowserSession: false, response_type: "code")
        let response = try await fetchAuthorizationUrl(input: parameter)
        print(response)
    }

}
