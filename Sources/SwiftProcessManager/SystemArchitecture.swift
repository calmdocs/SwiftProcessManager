//
//  SystemArchitecture.swift
//  SwiftProcessManager
//
//  Created by Iain McLaren on 12/7/2023.
//

import SwiftUI

#if os(macOS)

/// Return the macOS system architecture.
/// - Returns: The system architecture as a string (e.g. "arm64").
public func SystemArchitecture() -> String {
    return utsname.sMachine
}
extension utsname {
    static var sMachine: String {
        var utsname = utsname()
        uname(&utsname)
        return withUnsafePointer(to: &utsname.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: Int(_SYS_NAMELEN)) {
                String(cString: $0)
            }
        }
    }
    static var isAppleSilicon: Bool {
        sMachine == "arm64"
    }
}

#endif
