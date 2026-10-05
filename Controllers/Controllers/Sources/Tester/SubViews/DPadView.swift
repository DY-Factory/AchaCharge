//
//  DPadView.swift
//  Controllers
//
//  Created by 강동영 on 5/26/25.
//

import SwiftUI

struct DPadView: View {
    let xValue: Float
    let yValue: Float
    
    var body: some View {
        ZStack {
            // 기본 D-패드
            Image(systemName: "dpad")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 140)
                .foregroundColor(.primary)
            
            // 활성화된 방향 표시
            if abs(xValue) > 0.3 || abs(yValue) > 0.3 {
                Image(systemName: getDirectionImageName())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140)
                    .foregroundColor(.blue)
            }
        }
    }
    
    private func getDirectionImageName() -> String {
        if abs(xValue) > abs(yValue) {
            return xValue > 0 ? "dpad.right.filled" : "dpad.left.filled"
        } else {
            return yValue > 0 ? "dpad.up.filled" : "dpad.down.filled"
        }
    }
}

