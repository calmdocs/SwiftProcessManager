//
//  ExitAppIfAlreadyOpen.swift
//  SwiftProcessManager
//
//  Created by Iain McLaren on 12/7/2023.
//

import SwiftUI

#if os(macOS)

/// Terminate the running executable if another copy of the executable is already running.
public func ExitAppIfAlreadyOpen() {
    let bundleID = Bundle.main.bundleIdentifier!
    let numInstances = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).count
    if numInstances > 1 {
       print("Application already opened.  Exiting ...")
       NSApplication.shared.terminate(nil)
    }
}

#endif

