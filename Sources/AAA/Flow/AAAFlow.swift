//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/21.
//

import Foundation

public protocol AAARefreshableToken: Equatable{
    var refresh_token : String? {get}
}
public protocol AAAUserWebAuth: Equatable{
    var needUserWebAuth : Bool {get}
    func userWebAuthParameter(prefersEphemeralWebBrowserSession: Bool) ->  AuthorizationUrl.Parameter?
}

public protocol AAATokenOpenAPI: Equatable{
    associatedtype OpenAPIClientRequest : OpenAPIClientRequestProtocol
    

    var canRefreshToken : Bool {get}
    func requestToken(authorizedCode: String?)->OpenAPIClientRequest
    func refreshToken(refreshToken: String?)->OpenAPIClientRequest

}
public protocol AAAFlow: AAAUserWebAuth,AAATokenOpenAPI, Equatable{

}
