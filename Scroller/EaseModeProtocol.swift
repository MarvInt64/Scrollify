//
//  EaseModeProtocol.swift
//  Scoller
//
//  Created by Marvin K. on 07.10.23.
//  https://github.com/marv-in-k/
//

protocol EaseMode {
    var name: String { get }
    func easeFunction(x: Double) -> Double
}
