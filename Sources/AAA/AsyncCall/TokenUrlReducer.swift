//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/12/25.
//

import Foundation
import ComposableArchitecture

public struct TokenUrlReducer<T: TokenUrlProtocol>: Reducer{
    public struct State:Equatable{
        public var response: T.Response?
        public var joinStateOpenAPIClientRequestReducer : OpenAPIClientRequestReducer<T>.State
        public init(debounceDuration : DispatchQueue.SchedulerTimeType.Stride) {
            self.joinStateOpenAPIClientRequestReducer = .init(debounceDuration: debounceDuration)
        }
    }
    public enum Action:Equatable{
        case joinActionOpenAPIClientRequestReducer(OpenAPIClientRequestReducer<T>.Action)
        case asyncCall(T)
        case receive(T.Response)
    }
    public var body: some Reducer<State, Action> {
        Scope(state: \.joinStateOpenAPIClientRequestReducer, action: /Action.joinActionOpenAPIClientRequestReducer) {
            OpenAPIClientRequestReducer<T>()
        }
        Reduce { state, action in
            switch action{
            case .asyncCall(let request):
                return .send(.joinActionOpenAPIClientRequestReducer(.asyncCall(request)) )
            case .joinActionOpenAPIClientRequestReducer(let subAction):
                switch subAction{
                case .receive(let response):
                    return .send(.receive(response))
                default:
                    break
                }
            case .receive(let response):
                state.response = response
            }
            return .none
        }
    }
}
