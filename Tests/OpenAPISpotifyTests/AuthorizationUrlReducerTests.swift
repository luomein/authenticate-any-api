//
//  AuthorizationUrlReducerTests.swift
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
final class AuthorizationUrlReducerTests: XCTestCase {

    let debounceDuration : DispatchQueue.SchedulerTimeType.Stride = 0.1
    let prefersEphemeralWebBrowserSession = false
    let testQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.main
    typealias Reducer = AuthorizationUrlReducer
    typealias State = Reducer.State
   
    func testReducer() async throws {
        let authFlow = AAASpotify.authorization_code(client_id: Credential.SpotifyAuth.client_id, client_secret: Credential.SpotifyAuth.client_secret, redirect_uri: Credential.SpotifyAuth.redirect_uri, scope: [.playlist_read_private, .user_read_playback_state, .user_read_private], state: nil)
        let store =  Store(initialState: State(debounceDuration: debounceDuration)) {
            Reducer()
        }withDependencies: { [self] in
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        }
        await store.send(.asyncCall(authFlow.authorizationUrlParameter(prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession)!)).finish()
        let code = store.withState{state in
            return state.authorizedCode
        }
        print(code)
    }
}
