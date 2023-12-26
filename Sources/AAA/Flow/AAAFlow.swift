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
public protocol AAAAuthorizationUrl: Equatable{
    var needAuthorizationUrl : Bool {get}
    func authorizationUrlParameter(prefersEphemeralWebBrowserSession: Bool) ->  AuthorizationUrl.Parameter?
}

public protocol AAATokenUrl: Equatable{
    associatedtype TokenUrl : TokenUrlProtocol
    

    var canRefreshToken : Bool {get}
    func requestToken(authorizedCode: String?)-> Self.TokenUrl
    func refreshToken(refreshToken: String?)-> Self.TokenUrl

}
public protocol AAAFlow: AAAAuthorizationUrl,AAATokenUrl, Equatable{

}
