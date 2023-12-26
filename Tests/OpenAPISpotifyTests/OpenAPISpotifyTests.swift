//
//  OpenAPISpotifyTests.swift
//  
//
//  Created by MEI YIN LO on 2023/11/27.
//

import XCTest
import AAA
import AAASpotify
import ComposableArchitecture

@MainActor
@available(macOS 13.0, *)
final class OpenAPISpotifyTests: XCTestCase {
    let debounceDuration : DispatchQueue.SchedulerTimeType.Stride = 0.1
    let testQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.main
    typealias Reducer = AAAFlowReducer<AAASpotify>
    typealias State = Reducer.State
   
    func testReducer() async throws {
        let authFlow = AAASpotify.authorization_code(client_id: Credential.SpotifyAuth.client_id, client_secret: Credential.SpotifyAuth.client_secret, redirect_uri: Credential.SpotifyAuth.redirect_uri, scope: [.playlist_read_private, .user_read_playback_state, .user_read_private], state: nil)
        let store =  Store(initialState: State(authFlow: authFlow, prefersEphemeralWebBrowserSession: false, debounceDuration: debounceDuration)) {
            Reducer()
        }withDependencies: { [self] in
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        }
        await store.send(.auth).finish()
        let access_token = store.withState { state in
            print(state.accessTokenResponse )
            return state.accessTokenResponse!.access_token
        }
        let client = OpenAPISpotifyClient(accessToken: access_token)
        let response  = try! await client.get_hyphen_the_hyphen_users_hyphen_currently_hyphen_playing_hyphen_track(.init())
        print(response)
    }
}

