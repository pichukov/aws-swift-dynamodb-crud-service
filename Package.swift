// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "aws-swift-dynamodb-crud-service",
    products: [
      .library(name: "DynamoDBService", targets: ["DynamoDBService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/soto-project/soto.git", from: "5.0.0-beta.2")
    ],
    targets: [
        .target(
            name: "DynamoDBService",
            dependencies: [
                .product(name: "SotoDynamoDB", package: "soto")
            ]
        ),
        .testTarget(
            name: "DynamoDBServiceTests",
            dependencies: ["DynamoDBService"]),
    ]
)
