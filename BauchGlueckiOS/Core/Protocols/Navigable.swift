//
//  Navigable.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 18.10.24.
//

protocol Navigable {
    var navigate: (Screen) -> Void { get set }
}
