//
//  CombineDemoApp.swift
//  CombineDemo
//
//  Created by Brian Hasenstab on 3/15/21.
//

import SwiftUI

@main
struct CombineDemoApp: App {
    @StateObject var state = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(state)
        }
    }
}
