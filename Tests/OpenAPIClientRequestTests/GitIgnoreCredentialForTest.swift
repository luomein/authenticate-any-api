//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/8/27.
//

import Foundation

public struct Credential{
    public struct OpenGovAuthorization{
        public static let authorization = "CWA-1A23512B-96DF-40A2-9411-B957BFD786E1" //"CWB-03F37A86-6310-4697-B987-BD64C4E10E89"
    }
    public struct GoogleAuth{
        public static let redirect_uri = URL(  string:  "com.googleusercontent.apps.891824018884-i7e0cgst7gf0udk2udfr23lqgaani06b:/oauth2redirect/google" )!
        public static let  client_id = "891824018884-i7e0cgst7gf0udk2udfr23lqgaani06b.apps.googleusercontent.com"
        
    }
    public struct TwitterAuth{
        public static let redirect_uri = URL(  string:  "lUO://" )!
        public static let  client_id = "Z3NQbHljU3NtTG9jZFY4d1FQdEk6MTpjaQ"
         public static let client_secret = "pOROq_vbP7zah3rLmalIElbDChx16N26yMvKpHSSws2U0ZekNc" 
    }
    public struct SpotifyAuth{
        public static let redirect_uri = URL(  string:  "myScheme://myHost/myPath" )!
        public static let  client_id = "738cae3e65a64f52a5353a0b23aa08c4"
        public static let client_secret = "84ea82066379441998871fe33d95cac3"
    }
    public struct GithubAuth{
        public static let redirect_uri = URL(  string:  "githubviz://oauth-callback/github" )!
        public static let  client_id = "d6f53b4216b6ab3c6289"
        public static let client_secret = "413453b77c45fd98c3d5d950c1c10909a98fbf48"
    }
}
