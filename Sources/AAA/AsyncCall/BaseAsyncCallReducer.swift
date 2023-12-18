//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/13.
//

import Foundation
import ComposableArchitecture


public struct BaseAsyncCallReducer<RequestType:Equatable, ResponseType:Equatable>: Reducer{
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.asyncCallClient) var asyncCallClient
    @Dependency(\.errorHandler) var errorHandler
    public init(){}
    public struct State:Equatable{
        public var debounceDuration : DispatchQueue.SchedulerTimeType.Stride
        public var response : ResponseType? = nil
        public init(debounceDuration: DispatchQueue.SchedulerTimeType.Stride, response: ResponseType? = nil) {
            self.debounceDuration = debounceDuration
            self.response = response
        }
    }
    public enum Action:Equatable{
        case debounceQueuedRequest(request: RequestType)
        case response(TaskResult<ResponseType>)
    }
    private enum CancelID {
      case debounceRequest
    }
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .debounceQueuedRequest(let request):
            return
                .run(operation: {[request] send in
                    await send(.response(TaskResult{try await asyncCallClient.fetch(request) as! ResponseType}))
                })
                .debounce(id: CancelID.debounceRequest, for: state.debounceDuration, scheduler: mainQueue)
        case .response(.success(let response)):
            state.response = response
            break
        case .response(.failure(let error)):
            errorHandler.receive(error)
        }
        return .none
    }
}
