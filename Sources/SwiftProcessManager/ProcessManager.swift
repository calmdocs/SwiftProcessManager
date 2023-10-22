//
//  ProcessProvider.swift
//  SwiftProcessManager
//
//  Created by Iain McLaren on 12/7/2023.
//

import SwiftUI

#if os(macOS)

/// A ProcessManager error.
public enum ProcessManagerError: Error {
    /// Executable not found
    case executableNotFound
}

/// Run and monitor bundled binaries.
@available(iOS 13, macOS 10.15, *)
public class ProcessManager: ObservableObject {
    
    /// The Process variable used to run the procided binary.
    @Published public var task: Process
    
    /// Run and monitor bundled binaries.
    public init() {
        self.task = Process()
    }
    
    /// The arguments that are passed to the binary.
    public var arguments: [String] = [String]()
    
    /// Variable indicating whether ProcessManager has been cancelled.
    private var isCancelled: Bool = false
    
    /// Cancel the ProcessManager.  This also stops any running binary.
    public func cancel() {
        self.isCancelled = true
        self.terminateCurrentTask()
    }
    
    /// Terminate the currently running binary.
    /// If withRetry is set to true, the binary will restart.
    public func terminateCurrentTask() {
        DispatchQueue.main.async {
            if self.task.isRunning {
                self.task.terminate()
            }
        }
    }
    
    /// Add an argument to send to the binary.
    /// - Parameter value: Argument of type Any to add to the binary.
    public func addArgument<T>(_ value: T ) where T : Any {
        self.arguments.append("\(value)")
    }
    
    /// Add an argument to the binary in the form "-key=value".
    /// - Parameters:
    ///   - key: The key.
    ///   - value: The value.
    public func addArgument<T>(_ key: String, value: T ) where T : Any {
        self.arguments.append("-\(key)=\(value)")
    }
    
    /// Add the pid of this executable as an argument to the binary in the form "-key=PID".
    /// The binary can then use this PID to terminate when the calling parent terminates.
    /// - Parameter key: The argument..
    public func addPIDAsArgument(_ key: String) {
        self.addArgument(key, value: ProcessInfo.processInfo.processIdentifier)
    }
    
    /// Run the bundled binary.
    /// - Parameters:
    ///   - binName: The name of the bundled binary to run.
    ///   - withRetry: Restart the binary if it exits.
    ///   - standardOutput: Send the standard output to the provided function.
    ///   - taskExitNotification: Send an Error? to the provided function each time the binary exits.
    public func RunProces(
        binName: String,
        withRetry: Bool = false,
        standardOutput: @escaping (String) -> Void  = { _ in },
        taskExitNotification: @escaping (Error?) -> Void  = { _ in }
    ) async {
        await RunProces(
            binURL: Bundle.main.url(forResource: binName, withExtension: nil),
            withRetry: withRetry,
            standardOutput: standardOutput,
            taskExitNotification: taskExitNotification
        )
    }
    
    /// Run the bundled binary.
    /// - Parameters:
    ///   - binURL: The URL? of the bundled binary to run.
    ///   - withRetry: Restart the binary if it exits.
    ///   - standardOutput: Send the standard output to the provided function.
    ///   - taskExitNotification: Send an Error? to the provided function each time the binary exits.
    public func RunProces(
        binURL: URL?,
        withRetry: Bool = false,
        standardOutput: @escaping (String) -> Void  = { _ in },
        taskExitNotification: @escaping (Error?) -> Void  = { _ in }
     ) async {
        var done = false
        
        while !done {
            if self.isCancelled {
                done = true
                continue
            }
            
            if !withRetry {
                done = true
            }
            
            self.runTask(
                binURL: binURL,
                standardOutput: standardOutput,
                taskExitNotification: taskExitNotification
            )
        }
    }
    
    private func runTask(
        binURL: URL?,
        standardOutput: @escaping (String) -> Void  = { _ in },
        taskExitNotification: @escaping (Error?) -> Void  = { _ in }
        
    ) {
        // Stream output to results
        let pipe = Pipe()
        let outHandle = pipe.fileHandleForReading
        outHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: .utf8) {
                standardOutput(line)
            }
        }
        defer { 
            do {
                try pipe.fileHandleForReading.close()
            } catch {
                print("task pipe exit error:", error)
            }
        }
        
        // Create process
        self.task = Process()
        defer { self.task.terminate() }
        
        // Redirect stdout to our pipe
        self.task.standardOutput = pipe
        guard binURL != nil else {
            taskExitNotification(ProcessManagerError.executableNotFound)
            return
        }
        self.task.executableURL = binURL!
        self.task.arguments = self.arguments
        
        // Run the task
        do {
            try self.task.run()
        } catch {
            taskExitNotification(error)
            return
        }
        
        // Wait until done
        self.task.waitUntilExit()
        DispatchQueue.main.async {
            taskExitNotification(nil)
        }
    }
}
    
#endif
