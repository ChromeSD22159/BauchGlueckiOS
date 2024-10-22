//
//  PageIdentifier.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.10.24.
//

protocol PageIdentifier {
    var page: Destination { get }
    func navigate(to destination: Destination)
}
