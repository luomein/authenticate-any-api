// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AAA",
    platforms: [
        .macOS(.v11),.iOS(.v16),.watchOS(.v8)
        ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AAA",
            targets: ["AAA"]),
        .library(
            name: "AAAGitHub",
            targets: ["AAAGitHub"]),
        .library(
            name: "AAASpotify",
            targets: ["AAASpotify"]),
        .library(
            name: "AAATwitter",
            targets: ["AAATwitter"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-generator",  .exactItem("0.3.4")), //"0.1.11"
        .package(url: "https://github.com/apple/swift-openapi-runtime", .exactItem( "0.3.6")), //"0.1.10"
        .package(url: "https://github.com/apple/swift-openapi-urlsession", .exactItem( "0.3.0")),//"0.1.2"
        
        //.package(url: "https://github.com/apple/swift-http-types", from: "1.0.0"),
            .package(url: "https://github.com/pointfreeco/swift-composable-architecture",
                     .exactItem("1.3.0") ) ,
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AAA",
            dependencies: [
                .product(
                    name: "OpenAPIRuntime",
                    package: "swift-openapi-runtime"
                ),
                .product(
                    name: "OpenAPIURLSession",
                    package: "swift-openapi-urlsession"
                ),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]),
        .target(
            name: "AAAGitHub",
            dependencies: [
                "AAA",
                .product(
                    name: "OpenAPIRuntime",
                    package: "swift-openapi-runtime"
                ),
                .product(
                    name: "OpenAPIURLSession",
                    package: "swift-openapi-urlsession"
                ),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            plugins: [
                            .plugin(
                                name: "OpenAPIGenerator",
                                package: "swift-openapi-generator"
                            )
                        ]),
        .target(
            name: "AAASpotify",
            dependencies: [
                "AAA",
                .product(
                    name: "OpenAPIRuntime",
                    package: "swift-openapi-runtime"
                ),
                .product(
                    name: "OpenAPIURLSession",
                    package: "swift-openapi-urlsession"
                ),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            plugins: [
                            .plugin(
                                name: "OpenAPIGenerator",
                                package: "swift-openapi-generator"
                            )
                        ]
        ),
        .target(
            name: "AAATwitter",
            dependencies: [
                "AAA",
                .product(
                    name: "OpenAPIRuntime",
                    package: "swift-openapi-runtime"
                ),
                .product(
                    name: "OpenAPIURLSession",
                    package: "swift-openapi-urlsession"
                ),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            plugins: [
                            .plugin(
                                name: "OpenAPIGenerator",
                                package: "swift-openapi-generator"
                            )
                        ]
        ),
        //
        .testTarget(
            name: "AAATests",
            dependencies: ["AAA", "AAAGitHub","AAASpotify", "AAATwitter"]),
        .testTarget(name: "OpenAPISpotifyTests",
                   dependencies: ["AAA",  "AAASpotify"
                                 , .product(
                                    name: "OpenAPIRuntime",
                                    package: "swift-openapi-runtime"
                                ),
                                .product(
                                    name: "OpenAPIURLSession",
                                    package: "swift-openapi-urlsession"
                                ),
                                 ],
                    plugins: [
                                    .plugin(
                                        name: "OpenAPIGenerator",
                                        package: "swift-openapi-generator"
                                    )
                                ]),
        .testTarget(name: "OpenAPIGitHubTests",
                   dependencies: ["AAA",  "AAAGitHub"
                                 , .product(
                                    name: "OpenAPIRuntime",
                                    package: "swift-openapi-runtime"
                                ),
                                .product(
                                    name: "OpenAPIURLSession",
                                    package: "swift-openapi-urlsession"
                                ),
                                 ],
                    plugins: [
                                    .plugin(
                                        name: "OpenAPIGenerator",
                                        package: "swift-openapi-generator"
                                    )
                                ]),
        .testTarget(name: "OpenAPITwitterTests",
                   dependencies: ["AAA",  "AAATwitter"
                                 , .product(
                                    name: "OpenAPIRuntime",
                                    package: "swift-openapi-runtime"
                                ),
                                .product(
                                    name: "OpenAPIURLSession",
                                    package: "swift-openapi-urlsession"
                                ),
                                 ],
                    plugins: [
                                    .plugin(
                                        name: "OpenAPIGenerator",
                                        package: "swift-openapi-generator"
                                    )
                                ])
    ]
)
