//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/26.
//

import Foundation


extension AAATwitter{
    public enum Scope:String{
        //https://developer.twitter.com/en/docs/authentication/oauth-2-0/authorization-code
        //https://developer.twitter.com/en/docs/authentication/guides/v2-authentication-mapping
        //"streaming" , "user-read-private" , "user-read-email", "user-modify-playback-state","user-read-playback-state"
        case tweet_read = "tweet.read"
        case offline_access = "offline.access"
        case follows_read = "follows.read"
        case users_read = "users.read"
    }
    
}
