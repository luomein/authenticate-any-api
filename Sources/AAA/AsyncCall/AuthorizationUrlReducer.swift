//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/12/3.
//

import Foundation
import ComposableArchitecture

public struct AuthorizationUrlReducer : Reducer{
    public typealias AsyncCallReducer = BaseAsyncCallReducer<AuthorizationUrl.Parameter,String>
    var asyncCallClient : AsyncCallClient
    
    public init(asyncCallClient: AsyncCallClient = .init(fetch: Self.fetchAuthorizationUrl(input:))
    ) {
        self.asyncCallClient = asyncCallClient
    }
    public struct State:Equatable{
        public var authorizedCode: String?
        public var joinStateAsyncCallReducer : AsyncCallReducer.State
        public init(debounceDuration : DispatchQueue.SchedulerTimeType.Stride) {
            self.joinStateAsyncCallReducer = .init(debounceDuration: debounceDuration)
        }
    }
    public enum Action:Equatable{
        case joinActionAsyncCallReducer(AsyncCallReducer.Action)
        case asyncCall(AuthorizationUrl.Parameter)
        case receive(authorizedCode: String)
    }
    public var body: some Reducer<State, Action> {
        Scope(state: \.joinStateAsyncCallReducer, action: /Action.joinActionAsyncCallReducer) {
            AsyncCallReducer()
                .dependency(\.asyncCallClient, asyncCallClient)
        }
        Reduce { state, action in
            switch action{
            case .receive(let code):
                state.authorizedCode = code
            case .asyncCall(let parameter):
                return .send(.joinActionAsyncCallReducer(.debounceQueuedRequest(request: parameter)) )
            case .joinActionAsyncCallReducer(let subAction):
                switch subAction{
                case .response(.success(let code)):
                    return .send(.receive(authorizedCode: code))
                default:
                    break
                }
            }
            return .none
        }
    }
}

extension AuthorizationUrlReducer{
    public static func fetchAuthorizationUrl(input: Sendable) async throws -> Sendable {
        let authorizationUrl = AuthorizationUrl()
        let parameter = input as! AuthorizationUrl.Parameter
        let response = try await authorizationUrl.asyncPopupWebLogin(url: parameter.url
                                                           , callbackURLScheme: parameter.redirect_uri.scheme!, prefersEphemeralWebBrowserSession: parameter.prefersEphemeralWebBrowserSession)
        let responseComponents = URLComponents(url: response, resolvingAgainstBaseURL: false)
        let code = responseComponents!.queryItems!.first(where: {$0.name == parameter.response_type})!.value!
        return code
    }
}
