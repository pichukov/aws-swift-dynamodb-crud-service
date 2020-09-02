//
//  DynamoDBError.swift
//  
//
//  Created by Alexey Pichukov on 28.08.2020.
//

public enum DynamoDBError: Error {
    case general
    case parsing
    case db
    case dataTransformation
}
