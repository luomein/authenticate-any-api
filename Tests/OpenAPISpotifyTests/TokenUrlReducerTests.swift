//
//  TokenUrlReducerTests.swift
//  
//
//  Created by MEI YIN LO on 2023/12/26.
//

import XCTest
import AAA
import AAASpotify
import ComposableArchitecture

@MainActor
@available(macOS 13.0, *)
final class TokenUrlReducerTests: XCTestCase {

    let debounceDuration : DispatchQueue.SchedulerTimeType.Stride = 0.1
    let prefersEphemeralWebBrowserSession = false
    let testQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.main
    typealias Reducer = TokenUrlReducer<AAASpotify.TokenUrl>
    typealias State = Reducer.State
   
    func testReducer() async throws {
        let authFlow = AAASpotify.clientCredentials(client_id: Credential.SpotifyAuth.client_id, client_secret: Credential.SpotifyAuth.client_secret)
        let store =  Store(initialState: State(debounceDuration: debounceDuration)) {
            Reducer()
        }withDependencies: { [self] in
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        }
        await store.send(.asyncCall(authFlow.requestToken(authorizedCode: nil))).finish()
        let code = store.withState{state in
            return state.response?.access_token
        }
        print(code)
    }
}
