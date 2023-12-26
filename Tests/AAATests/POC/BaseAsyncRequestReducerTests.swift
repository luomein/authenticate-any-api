//
//  BasicTests.swift
//  
//
//  Created by MEI YIN LO on 2023/12/18.
//

import XCTest
import ComposableArchitecture



@MainActor
@available(macOS 13.0, *)
final class BaseAsyncRequestReducerTests: XCTestCase {
    
    struct BaseAsyncCallReducer<RequestType:Equatable, ResponseType:Equatable>: Reducer{
        @Dependency(\.mainQueue) var mainQueue
        //@Dependency(\.asyncCallClient) var asyncCallClient
        @Dependency(\.errorHandler) var errorHandler
        var fetch: ( Sendable) async throws ->  Sendable
        //public init(){}
        public init(fetch: @escaping (Sendable)async throws -> Sendable) {
            self.fetch = fetch
        }
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
                        await send(.response(TaskResult{try await fetch(request) as! ResponseType}))
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
    
    let debounceDuration : DispatchQueue.SchedulerTimeType.Stride = 0.1
    let testQueue = DispatchQueue.test
    
    typealias TestReducer = BaseAsyncCallReducer<Int,Int>
    
    func passThroughFetch(input: Sendable) async throws -> Sendable{
        return input
    }
    func test() async throws {
        let store = TestStore(initialState: TestReducer.State(debounceDuration: debounceDuration)
        ) {
            TestReducer(fetch: passThroughFetch )
        } withDependencies: {
            $0.mainQueue = testQueue.eraseToAnyScheduler()
        }
        let intArray = 0...10
        for i in intArray{
            await store.send(.debounceQueuedRequest(request: i))
        }
        await testQueue.advance(by: debounceDuration * 2)
        await store.receive(.response(.success(intArray.last!)), timeout: .zero){
            $0.response = intArray.last!
        }
        
    }

}
