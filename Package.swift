// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "aws-swift-dynamodb-crud-service",
    products: [
      .library(name: "DynamoDBService", targets: ["DynamoDBService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-aws/aws-sdk-swift.git", from: "5.0.0-alpha.4")
    ],
    targets: [
        .target(
            name: "DynamoDBService",
            dependencies: [
                .product(name: "AWSDynamoDB", package: "aws-sdk-swift")
            ]
        ),
        .testTarget(
            name: "DynamoDBServiceTests",
            dependencies: ["DynamoDBService"]),
    ]
)
