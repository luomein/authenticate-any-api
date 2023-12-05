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
        let prefersEphemeralWebBrowserSession = true
        let allow_signup = true
        let login = "test"
        let url = AAA.UserWebAuthURL(redirect_uri: credential.redirect_uri
                                           , client_id: credential.client_id
                                           , scope: [.repo,.user]
                                     , login: login
                                     , allow_signup : allow_signup)
        let parameter = AsyncUserWebAuthAgent.Parameter(url: url
                                                        , redirect_uri: credential.redirect_uri
                                                        , prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession, response_type: AAA.Const.responseType)
        let response = try await AsyncUserWebAuthAgent.authFlow(parameter: parameter)
        print(response)
    }
    
    func testSpotify() async throws {
        typealias credential = Credential.SpotifyAuth
        typealias AAA = AAASpotify
        let url = AAA.UserWebAuthURL(redirect_uri: credential.redirect_uri
                                           , client_id: credential.client_id
                                           )
        let parameter = AsyncUserWebAuthAgent.Parameter(url: url
                                                        , redirect_uri: credential.redirect_uri
                                                        , prefersEphemeralWebBrowserSession: false, response_type: AAA.Const.responseType)
        let response = try await AsyncUserWebAuthAgent.authFlow(parameter: parameter)
        print(response)
    }

}
