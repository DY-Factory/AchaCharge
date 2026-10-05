//
//  TriggerButtonView.swift
//  Controllers
//
//  Created by 강동영 on 5/26/25.
//

import SwiftUI

struct TriggerButtonView: View {
    let systemName: String
    let value: Float
    
    var body: some View {
        VStack {
            ControllerButton(systemName: systemName, isPressed: value > 0.1)
            ProgressView(value: Double(value))
                .frame(width: 80)
//                .tint(value > 0.7 ? .red : (value > 0.3 ? .orange : .blue))
        }
    }
}
