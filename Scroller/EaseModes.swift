//
//  EaseModes.swift
//  Scoller
//
//  Created by Marvin K. on 07.10.23.
//  https://github.com/marv-in-k/
//

import SwiftUI

struct QuartEase: EaseMode {
    var name: String = "Quart"
    
    func easeFunction(x: Double) -> Double {
        return x < 0.5 ? 8 * x * x * x * x : 1 - pow(-2 * x + 2, 4) / 2
    }
}

struct EaseOutBounce: EaseMode {
    var name: String = "EaseOutBounce"
    
    func easeFunction(x: Double) -> Double {
        if x < 1/2.75 {
            return 7.5625 * x * x
        } else if x < 2/2.75 {
            return 7.5625 * (x - 1.5/2.75) * (x - 1.5/2.75) + 0.75
        } else if x < 2.5/2.75 {
            return 7.5625 * (x - 2.25/2.75) * (x - 2.25/2.75) + 0.9375
        } else {
            return 7.5625 * (x - 2.625/2.75) * (x - 2.625/2.75) + 0.984375
        }
    }
}


struct ElasticEase: EaseMode {
    var name: String = "Elastic"
    
    func easeFunction(x: Double) -> Double {
        if x == 0 {
              return 0
          }
          if x == 1 {
              return 1
          }
          
          let p = 0.45
          let s = p / 4.0
          return pow(2.0, -10.0 * x) * sin((x * 10 - s) * (2.0 * Double.pi) / p) + 1.0
    }
}
