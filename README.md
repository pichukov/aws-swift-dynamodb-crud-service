# AWS Swift DynamoDB CRUD Service

This is a `CRUD` service for `AWS DynamoDB` made over `aws-sdk-swift-core` library

#### Installation

In your `Package.swift` file add a new dependency:
```swift
...
dependencies: [
    .package(url: "https://github.com/pichukov/aws-swift-dynamodb-crud-service.git", from: "1.0.0")
],
targets: [
    .target(
        ...
        dependencies: [
                .product(name: "DynamoDBService", package: "aws-swift-dynamodb-crud-service"),
                ...
            ]
    ),
    ...
]
...
```
And add `import DynamoDBService` in your file

#### Usage

The `item` representation from the data base should confirm `DynamoDBConvertable` protocol:

```swift
protocol DynamoDBConvertable {
    static var primaryKeyField: String { get }
    var primaryKeyValue: String { get }
    var dbItem: [String: DynamoDB.AttributeValue] { get }
    init(withDBItem dbItem: [String: DynamoDB.AttributeValue]) throws
}
```

- `primaryKeyField` is a name of `primaryKey` in `DynamoDB` table
- `primaryKeyValue` is a value of `primaryKey` in `item` object
- `dbItem` is a representation of your object for `DynamoDB`

For example your `Item` object can looks like this:

```swift
struct Item: Codable {
    
    let id: String
    let name: String
    let value: Double
    let customMap: [String: Double]
    
    struct DBField {
        static let id = "id"
        static let name = "name"
        static let value = "value"
        static let customMap = "customMap"
    }
}

extension Item: DynamoDBConvertable {
    
    static var primaryKeyField: String {
        return DBField.id
    }
    
    var primaryKeyValue: String {
        return id
    }
    
    var dbItem: [String: DynamoDB.AttributeValue] {
        return [
            DBField.id: .s(id),
            DBField.name: .s(name),
            DBField.value: .n(String(value)),
            DBField.customMap: .m(dbDictionary)
        ]
    }
    
    init(withDBItem dbItem: [String: DynamoDB.AttributeValue]) throws {
        if case .s(let id) = dbItem[DBField.id],
            case .s(let name) = dbItem[DBField.name],
            case .n(let value) = dbItem[DBField.value],
            case .m(let map) = dbItem[DBField.customMap]
        {
            guard let numValue = Double(value) else {
                throw ErrorType.dataTransformation
            }
            var numCustomMap: [String: Double] = [:]
            for key in map.keys {
                if case .n(let value) = map[key] {
                    guard let numValue = Double(value) else {
                        throw ErrorType.dataTransformation
                    }
                    numCustomMap[key] = numValue
                } else {
                    throw ErrorType.dataTransformation
                }
            }
            self.id = id
            self.name = name
            self.value = numValue
            self.customMap = numCustomMap
        } else {
            throw ErrorType.dataTransformation
        }
    }
    
    private var dbDictionary: [String: DynamoDB.AttributeValue] {
        var result: [String: DynamoDB.AttributeValue] = [:]
        for key in customMap.keys {
            guard let value = customMap[key] else {
                continue
            }
            result[key] = .n(String(value))
        }
        return result
    }
}
```

To use a service you need to create an instance of `DBService`:

```swift
import AWSDynamoDB
import AsyncHTTPClient
import DynamoDBService
...
private let dbService: DBService
...
dbService = DBService(httpClient: httpClient, tableName: tableName, region: region)
```

`DBService` use some stuff from `AWSDynamoDB` and `AsyncHTTPClient` packages, so you need to import it as well
- `httpClient` is a `HTTPClient` that can be created using `Lambda.InitializationContext`:

```swift
let httpClient = HTTPClient(eventLoopGroupProvider: .shared(context.eventLoop))
```

- `tableName` is a `String` that contains the name of your table in `DynamoDB` that you want to work with
- `region` is a `Region` type from `AWSDynamoDB` package