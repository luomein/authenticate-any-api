//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/12/3.
//

import Foundation
import ComposableArchitecture

public struct AsyncUserWebAuthReducer : Reducer{
    public typealias AsyncRequestReducer = BaseAsyncRequestReducer<AsyncUserWebAuthAgent.Parameter,String>
    var fetchUserWebAuthClient : AsyncRequestClient
    
    public init(fetchUserWebAuthClient: AsyncRequestClient = .init(fetch: Self.fetchUserWebAuth(input:))
    ) {
        self.fetchUserWebAuthClient = fetchUserWebAuthClient
    }
    public struct State:Equatable{
        public var authorizedCode: String?
        public var joinStateAsyncRequestReducer : AsyncRequestReducer.State
        public init(debounceDuration : DispatchQueue.SchedulerTimeType.Stride) {
            self.joinStateAsyncRequestReducer = .init(debounceDuration: debounceDuration)
        }
    }
    public enum Action:Equatable{
        case joinActionAsyncRequestReducer(AsyncRequestReducer.Action)
        case userWebAuth(AsyncUserWebAuthAgent.Parameter)
        case receive(authorizedCode: String)
    }
    public var body: some Reducer<State, Action> {
        Scope(state: \.joinStateAsyncRequestReducer, action: /Action.joinActionAsyncRequestReducer) {
            BaseAsyncRequestReducer()
                .dependency(\.asyncRequestClient, fetchUserWebAuthClient)
        }
        Reduce { state, action in
            switch action{
            case .receive(let code):
                state.authorizedCode = code
            case .userWebAuth(let parameter):
                return .send(.joinActionAsyncRequestReducer(.debounceQueuedRequest(request: parameter)) )
            case .joinActionAsyncRequestReducer(let subAction):
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

extension AsyncUserWebAuthReducer{
    public static func fetchUserWebAuth(input: Sendable) async throws -> Sendable {
        let response = try await AsyncUserWebAuthAgent.authFlow(parameter: input as! AsyncUserWebAuthAgent.Parameter)
        return response
    }
}
