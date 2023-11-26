//
//  AsyncUserWebAuthAgentTests.swift
//  
//
//  Created by MEI YIN LO on 2023/11/26.
//

import XCTest
//@testable import AAA
import AAA
import AAAGitHub
import AAASpotify

final class AsyncUserWebAuthAgentTests: XCTestCase {

    
    func testGitHub() async throws {
        typealias credential = Credential.GithubAuth
        typealias AAA = AAAGitHub
        let url = AAA.userWebAuthURL(redirect_uri: credential.redirect_uri
                                           , client_id: credential.client_id
                                           , scope: [.repo,.user])
        let parameter = AsyncUserWebAuthAgent.Parameter(url: url
                                                        , redirect_uri: credential.redirect_uri
                                                        , prefersEphemeralWebBrowserSession: false, response_type: AAA.responseType)
        let response = try await AsyncUserWebAuthAgent.authFlow(parameter: parameter)
        print(response)
    }
    
    func testSpotify() async throws {
        typealias credential = Credential.SpotifyAuth
        typealias AAA = AAASpotify
        let url = AAA.userWebAuthURL(redirect_uri: credential.redirect_uri
                                           , client_id: credential.client_id
                                           )
        let parameter = AsyncUserWebAuthAgent.Parameter(url: url
                                                        , redirect_uri: credential.redirect_uri
                                                        , prefersEphemeralWebBrowserSession: false, response_type: AAA.Const.responseType)
        let response = try await AsyncUserWebAuthAgent.authFlow(parameter: parameter)
        print(response)
    }

}
