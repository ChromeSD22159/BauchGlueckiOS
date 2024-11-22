//
//  DatabaseError.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 20.11.24.
//
import Foundation

enum DatabaseError: Error {
    case insertFailed(String) 
}
