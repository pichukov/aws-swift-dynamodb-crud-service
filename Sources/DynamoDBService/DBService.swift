//
//  DBService.swift
//  
//
//  Created by Alexey Pichukov on 28.08.2020.
//

import SotoDynamoDB
import Foundation
import NIO

public class DBService {
    
    private let db: DynamoDB
    private let tableName: String
    
    public init(httpClient: AWSClient, tableName: String, region: Region) {
        self.tableName = tableName
        self.db = DynamoDB(client: httpClient, region: region)
    }
    
    /// `CREATE` a `DynamoDBConvertable` item in DynamoDB
    ///
    /// - parameters:
    ///     - item: a generic type that confirm `DynamoDBConvertable` protocol
    public func create<T: DynamoDBConvertable>(item: T) -> EventLoopFuture<Result<T, DynamoDBError>> {
        
        let input = DynamoDB.PutItemInput(item: item.dbItem,
                                          tableName: tableName)
        
        return db.putItem(input).map { _ -> Result<T, DynamoDBError> in
            return .success(item)
        }
    }
    
    /// `READ` a `DynamoDBConvertable` item from DynamoDB
    ///
    /// - parameters:
    ///     - itemWithPrimaryKey: an `id` for the item that should be get from the DB
    public func read<T: DynamoDBConvertable>(itemWithPrimaryKey primaryKey: String) -> EventLoopFuture<Result<T, DynamoDBError>> {
        
        /// `NOTE`: the `primaryKey` in `DB` is a `string` here,
        ///         if you have some other type, change `.s()` to the one you have in `DB`
        let input = DynamoDB.GetItemInput(key: [T.primaryKeyField: .s(primaryKey)],
                                          tableName: tableName)
        
        return db.getItem(input).map { output -> Result<T, DynamoDBError> in
            guard let dbItem = output.item else {
                return .failure(.db)
            }
            guard let item = try? T(withDBItem: dbItem) else {
                return .failure(.db)
            }
            return .success(item)
        }
    }
    
    /// `READ ALL` `DynamoDBConvertable` items from DynamoDB
    public func readAll<T: DynamoDBConvertable>() -> EventLoopFuture<Result<[T], DynamoDBError>> {
        
        let input = DynamoDB.ScanInput(tableName: tableName)

        return db.scan(input).map { output -> Result<[T], DynamoDBError> in
            guard let items = output.items else {
                return .failure(.db)
            }

            return .success(items.compactMap { try? T(withDBItem: $0) })
        }
    }
    
    /// `UPDATE` a `DynamoDBConvertable` item in DynamoDB
    ///
    /// - parameters:
    ///     - item: a generic type that confirm `DynamoDBConvertable` protocol
    public func update<T: DynamoDBConvertable>(item: T) -> EventLoopFuture<Result<Void, DynamoDBError>> {
        
        /// `NOTE`: the `primaryKey` in `DB` is a `string` here,
        ///         if you have some other type, change `.s()` to the one you have in `DB`
        let input = DynamoDB.UpdateItemInput(conditionExpression: "\(T.primaryKeyField) = :\(item.primaryKeyValue)",
                                             expressionAttributeValues: item.dbItem,
                                             key: [T.primaryKeyField: .s(item.primaryKeyValue)],
                                             tableName: tableName)
        
        return db.updateItem(input).map { _ -> Result<Void, DynamoDBError> in
            return .success(Void())
        }
    }
    
    /// `DELETE` an item from DynamoDB
    ///
    /// - parameters:
    ///     - itemWithPrimaryKey: an `id` for the item that should be get from the DB
    ///     - keyFielName: a name of the `primaryKey` field in `DynamoDB`
    public func delete(itemWithPrimaryKey primaryKey: String, keyFieldName: String) -> EventLoopFuture<Result<Void, DynamoDBError>> {
        
        /// `NOTE`: the `primaryKey` in `DB` is a `string` here,
        ///         if you have some other type, change `.s()` to the one you have in `DB`
        let input = DynamoDB.DeleteItemInput(key: [keyFieldName: .s(primaryKey)],
                                             tableName: tableName)
        
        return db.deleteItem(input).map { _ -> Result<Void, DynamoDBError> in
            return .success(Void())
        }
    }
}
