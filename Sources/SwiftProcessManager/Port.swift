//
//  SystemArchitecture.swift
//  SwiftProcessManager
//
//  Created by Iain McLaren on 12/7/2023.
//

import SwiftUI

#if os(macOS)

public func RandomOpenPort(_ range: Range<Int>) -> Int {
    var port = Int.random(in: range)
    while !IsOpenPort(port){
        port = Int.random(in: range)
    }
    return port
} 

// From https://stackoverflow.com/questions/56167320/ios-swift-how-to-check-if-port-is-open
public func IsOpenPort(_ port: Int) -> Bool {
    let inPort = in_port_t(port)
    
    let socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0)
    if socketFileDescriptor == -1 {
        return false
    }

    var addr = sockaddr_in()
    let sizeOfSockkAddr = MemoryLayout<sockaddr_in>.size
    addr.sin_len = __uint8_t(sizeOfSockkAddr)
    addr.sin_family = sa_family_t(AF_INET)
    addr.sin_port = Int(OSHostByteOrder()) == OSLittleEndian ? _OSSwapInt16(inPort) : inPort
    addr.sin_addr = in_addr(s_addr: inet_addr("0.0.0.0"))
    addr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
    var bind_addr = sockaddr()
    memcpy(&bind_addr, &addr, Int(sizeOfSockkAddr))

    if Darwin.bind(socketFileDescriptor, &bind_addr, socklen_t(sizeOfSockkAddr)) == -1 {
        return false
    }
    let isOpen = listen(socketFileDescriptor, SOMAXCONN ) != -1
    Darwin.close(socketFileDescriptor)
    return isOpen
}

#endif
