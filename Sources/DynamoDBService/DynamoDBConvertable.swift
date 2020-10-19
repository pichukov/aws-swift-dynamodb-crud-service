//
//  DynamoDBConvertable.swift
//  
//
//  Created by Alexey Pichukov on 28.08.2020.
//

import SotoDynamoDB

public protocol DynamoDBConvertable {
    static var primaryKeyField: String { get }
    var primaryKeyValue: String { get }
    var dbItem: [String: DynamoDB.AttributeValue] { get }
    init(withDBItem dbItem: [String: DynamoDB.AttributeValue]) throws
}
