//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/26.
//

import Foundation
import ComposableArchitecture

public struct ErrorHandler{
    public var receive: (Error) -> Void
    
    public static var fataError = Self(receive: {
        fatalError($0.localizedDescription)
    })
    
}
extension ErrorHandler:DependencyKey{
    public static let liveValue: Self = ErrorHandler.fataError
    public static let previewValue: Self = ErrorHandler.fataError
    public static let testValue: Self = ErrorHandler.fataError
    

}
extension DependencyValues{
    public var errorHandler: ErrorHandler{
        get { self[ErrorHandler.self] }
        set { self[ErrorHandler.self] = newValue }
    }
}
