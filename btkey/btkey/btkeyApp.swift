//
//  btkeyApp.swift
//  btkey
//
//  Created by Aaron Mandle on 11/10/25.
//

import SwiftUI

@main
struct btkeyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
