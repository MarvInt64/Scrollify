//
//  EaseModeManager.swift
//  Scoller
//
//  Created by Marvin K. on 07.10.23.
//  https://github.com/marv-in-k/
//

class EaseModeManager {
    private(set) var easeModes: [EaseMode] = []
    
    func register(easeMode: EaseMode) {
        easeModes.append(easeMode)
    }
    
    func getEaseFunction(for name: String) -> ((Double) -> Double)? {
        return easeModes.first(where: { $0.name == name })?.easeFunction
    }
}
