//
//  AAAGitHubTests.swift
//  
//
//  Created by MEI YIN LO on 2023/12/4.
//

import XCTest
import AAA
import AAAGitHub
import ComposableArchitecture

@MainActor
@available(macOS 13.0, *)
final class OpenAPIGitHubTests: XCTestCase {
    let debounceDuration : DispatchQueue.SchedulerTimeType.Stride = 0.1
    let prefersEphemeralWebBrowserSession = false
    let testQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.main
    typealias Reducer = AAAFlowReducer<AAAGitHub>
    typealias State = Reducer.State

    
    func testReducer() async throws {
        let authFlow = AAAGitHub.github_app_user_access_token_webflow(client_id: Credential.GithubAuth.client_id
                                                   , client_secret: Credential.GithubAuth.client_secret
                                                   , redirect_uri: Credential.GithubAuth.redirect_uri)
        let store : StoreOf<Reducer> = .init(initialState: State.init(authFlow: authFlow
                                                                      , prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession
                                                                      , debounceDuration: debounceDuration)) {
            Reducer()
        } withDependencies: { [self] in
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        }
        await store.send(.auth).finish()
        let access_token = store.withState { state in
            print(state.accessTokenResponse )
            return state.accessTokenResponse!.access_token
        }
        //print(access_token)
        let client = OpenAPIGitHubClient(accessToken: access_token)
        let response  = try! await client.users_sol_get_hyphen_authenticated()
        print(response)
    }

}
