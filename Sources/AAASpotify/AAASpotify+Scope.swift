//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/26.
//

import Foundation


extension AAASpotify{
    public enum Scope:String{
        //https://developer.spotify.com/documentation/web-api/concepts/scopes
        //"streaming" , "user-read-private" , "user-read-email", "user-modify-playback-state","user-read-playback-state"
        case streaming
        case user_read_private = "user-read-private"
        case user_read_email = "user-read-email"
        case user_read_playback_state = "user-read-playback-state"
        case user_read_currently_playing = "user-read-currently-playing"
        case playlist_read_private = "playlist-read-private"
    }
    
}
