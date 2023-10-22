# SwiftProcessManager
Swift package to manage running a binary using Process().

```
import SwiftProcessManager

let processManager = ProcessManager()
await self.processProvider.RunProces(
    url: Bundle.main.url(forResource: "bundled-binary", withExtension: nil),
    withRetry: true,                    // Retry running the binary when it exits.
    standardOutput: { output in
        print(output)
    },
    taskExitNotification: { err in
        if err != nil {
          processManager.cancel()       // Optionally stop retrying running the binary if the binary returns an error.
          print(err)
        }
    }
)
```
