//
//  NodeDecoder.swift
//  NodeDecoder
//
//  Copyright (c) 2021 Changbeom Ahn
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import node_api
import NodeBridge // FIXME: extract NodeAPI

public class NodeDecoder {
    let env: napi_env
    
    public init(env: napi_env) {
        self.env = env
    }
}

class _NodeDecoder {
    let env: napi_env
    
    let value: napi_value
    
    var codingPath: [CodingKey]
    
    var userInfo: [CodingUserInfoKey: Any]
    
    init(env: napi_env, value: napi_value, codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any] = [:]) {
        self.env = env
        self.value = value
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
}

public extension NodeDecoder {
    func decode<T>(_ type: T.Type, from value: napi_value) throws -> T where T : Decodable {
        try T(from: _NodeDecoder(env: env, value: value, codingPath: []))
    }
}

extension _NodeDecoder: Decoder {
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = KeyedContainer<Key>(env: env, value: value, codingPath: codingPath)
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        UnkeyedContainer(env: env, value: value, codingPath: codingPath)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        SingleValueContainer(env: env, value: value, codingPath: codingPath)
    }
}

struct KeyedContainer<Key>: KeyedDecodingContainerProtocol where Key: CodingKey {
    let env: napi_env
    
    let value: napi_value
    
    var codingPath: [CodingKey]
    
    var allKeys: [Key] {
        let keys = try! env.getPropertyNames(object: value)!
        let count = try! env.count(keys)
        return try! (0..<count)
            .map { try env.element(object: keys, index: $0)! }
            .map { (try? env.string($0)) ??
                Value(env: env, value: $0).description }
            .map { Key(stringValue: $0)! }
    }
    
    func contains(_ key: Key) -> Bool {
        var result = false
        try! check(napi_has_named_property(env, value, key.stringValue, &result))
//        print(#function, key, result)
        return result
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        let types: [ValueType] = [.null, .undefined]
        return types.contains(Value(env: env, value: try value(for: key)).type!)
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        try env.bool(value(for: key))
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        try env.string(value(for: key))!
    }
    
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
//        try env.double(value(for: key))
        var result: napi_value?
        try check(napi_coerce_to_number(env, value(for: key), &result))
        return try env.double(result!)
    }
    
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        fatalError()
    }
    
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        try env.int(value(for: key))
    }
    
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        fatalError()
    }
    
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        fatalError()
    }
    
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        fatalError()
    }
    
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        fatalError()
    }
    
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        fatalError()
    }
    
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        fatalError()
    }
    
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        fatalError()
    }
    
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        fatalError()
    }
    
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        fatalError()
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        try T(from: _NodeDecoder(env: env, value: try value(for: key), codingPath: codingPath + [key]))
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        fatalError()
    }
    
    func superDecoder() throws -> Decoder {
        fatalError()
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        fatalError()
    }
    
    func value(for key: Key) throws -> napi_value {
        var result: napi_value?
        try check(napi_get_named_property(env, value, key.stringValue, &result))
//        guard Value(env: env, value: result!).type != .undefined else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "", underlyingError: nil))
//        }
        return result!
    }
}

struct UnkeyedContainer: UnkeyedDecodingContainer {
    let env: napi_env
    
    let value: napi_value
    
    var codingPath: [CodingKey]
    
    let count: Int?
    
    var isAtEnd: Bool {
        currentIndex == count ?? 0
    }
    
    var currentIndex: Int = 0
    
    init(env: napi_env, value: napi_value, codingPath: [CodingKey]) {
        self.env = env
        self.value = value
        self.codingPath = codingPath
        count = try? env.count(value)
    }
    
    mutating func decode(_ type: String.Type) throws -> String {
        fatalError()
    }
    
    mutating func decode(_ type: Double.Type) throws -> Double {
        fatalError()
    }
    
    mutating func decode(_ type: Float.Type) throws -> Float {
        fatalError()
    }
    
    mutating func decode(_ type: Int.Type) throws -> Int {
        fatalError()
    }
    
    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        fatalError()
    }
    
    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        fatalError()
    }
    
    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        fatalError()
    }
    
    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        fatalError()
    }
    
    mutating func decode(_ type: UInt.Type) throws -> UInt {
        fatalError()
    }
    
    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        fatalError()
    }
    
    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        fatalError()
    }
    
    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        fatalError()
    }
    
    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        fatalError()
    }
    
    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try T(from: _NodeDecoder(env: env, value: element(), codingPath: codingPath))
    }
    
    mutating func decode(_ type: Bool.Type) throws -> Bool {
        fatalError()
    }
    
    mutating func decodeNil() throws -> Bool {
        fatalError()
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }
    
    mutating func superDecoder() throws -> Decoder {
        fatalError()
    }
    
    mutating func element() throws -> napi_value {
        defer { currentIndex += 1 }
        return try env.element(object: value, index: currentIndex)!
    }
}

struct SingleValueContainer: SingleValueDecodingContainer {
    let env: napi_env
    
    let value: napi_value
    
    var codingPath: [CodingKey]
    
    func decodeNil() -> Bool {
        Value(env: env, value: value).type == .null
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        fatalError()
    }
    
    func decode(_ type: String.Type) throws -> String {
        try env.string(value)!
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        fatalError()
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        fatalError()
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        fatalError()
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        fatalError()
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        fatalError()
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        fatalError()
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        fatalError()
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        fatalError()
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        fatalError()
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        fatalError()
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        fatalError()
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        fatalError()
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try T(from: _NodeDecoder(env: env, value: value, codingPath: codingPath))
    }
}
