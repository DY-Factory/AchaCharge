//
//  ThumbstickView.swift
//  Controllers
//
//  Created by 강동영 on 5/26/25.
//

import SwiftUI

struct ThumbstickView: View {
    let direction: Direction
    let xValue: Float
    let yValue: Float
    
    var body: some View {
        ZStack {
            // 배경 원
            
            Circle()
                .stroke(Color.gray, lineWidth: 2)
                .frame(width: 70, height: 70)
            
            // 스틱 노브
            Image(systemName: directionToString())
                .resizable()
                .frame(width: 60, height: 60)
                .offset(x: CGFloat(xValue) * 20, y: -CGFloat(yValue) * 20)
        }
    }
    
    func directionToString() -> String {
        switch direction {
        case .left:
            "l.circle.fill"
        case .right:
            "r.circle.fill"
        }
    }
}
