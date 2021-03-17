//
//  AddUserView.swift
//  CombineDemo
//
//  Created by Brian Hasenstab on 3/15/21.
//

import SwiftUI

struct AddUserView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        Text("Add User")
    }
}

struct AddUserView_Previews: PreviewProvider {
    static var previews: some View {
        AddUserView().environmentObject(AppState())
    }
}
