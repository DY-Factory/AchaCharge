//
//  ControllersWidgetBundle.swift
//  ControllersWidget
//
//  Created by 강동영 on 2023/06/07.
//

import WidgetKit
import SwiftUI

@main
struct ControllersWidgetBundle: WidgetBundle {
    var body: some Widget {
        ControllersWidget()
        if #available(iOS 16.1, *) {
            ControllerLiveActivity()
        }
    }
}
