//
//  HotkeyManager.swift
//  btkey
//
//  Created by Aaron Mandle on 11/10/25.
//

import Cocoa
import Carbon

class HotkeyManager {
    static let shared = HotkeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    private init() {}

    func registerHotkey() {
        // Get the configured hotkey (default: Cmd+Shift+H)
        let keyCode = UserDefaults.standard.integer(forKey: "hotkeyCode")
        let modifiers = UserDefaults.standard.integer(forKey: "hotkeyModifiers")

        // Set defaults if not configured
        let actualKeyCode = keyCode != 0 ? UInt32(keyCode) : UInt32(kVK_ANSI_H)
        let actualModifiers = modifiers != 0 ? UInt32(modifiers) : UInt32(cmdKey | shiftKey)

        // Create event type spec
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        // Install event handler
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            HotkeyManager.shared.handleHotkeyPressed()
            return noErr
        }, 1, &eventType, nil, &eventHandler)

        // Register the hotkey
        let hotKeyID = EventHotKeyID(signature: OSType(0x48544B59), id: 1) // 'HTKY' 1
        RegisterEventHotKey(actualKeyCode, actualModifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)

        print("Hotkey registered: keyCode=\(actualKeyCode), modifiers=\(actualModifiers)")
    }

    func unregisterHotkey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }

    private func handleHotkeyPressed() {
        print("Hotkey pressed!")
        // Trigger Bluetooth connection
        BluetoothManager.shared.connectToConfiguredDevice()
    }
}
