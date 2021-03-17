//
//  ContentView.swift
//  CombineDemo
//
//  Created by Brian Hasenstab on 3/15/21.
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    private var subscriptions: Set<AnyCancellable> = []
}

struct UserRow: View {
    @ObservedObject var user: User
    
    var body: some View {
        Text("User Row")
    }
}

struct ContentView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationView {
            Text("Hello users")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
