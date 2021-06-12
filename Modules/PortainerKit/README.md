# PortainerKit
Modern API for [Portainer](https://portainer.io).

## Usage
### Initialization
```swift
let url: URL = URL(string: "http://127.0.0.1:9000")!
let token: String? = nil	// Optional JWT token
let api: PortainerKit = PortainerKit(url: url, token: token)
```

### Logging in
```swift
let result = await api.login(username: "garyhost", password: "hunter2")
switch result {
	case .success(let token):
		// Save JWT token for later usage
	case .failure(let error):
		// Handle error
}
```

### Endpoints
```swift
let result = await api.getEndpoints()
switch result {
	case .success(let endpoints):
		// Do something with endpoints
	case .failure(let error):
		// Handle error
}
```

### Containers
```swift
let endpointID: Int = 0  // Grabbed from `getEndpoints()`
let result = await api.getContainers(endpointID: endpointID)
switch result {
	case .success(let containers):
		// Do something with containers
	case .failure(let error):
		// Handle error
}
```

### Executing actions
```swift
let endpointID: Int = 0  // Grabbed from `getEndpoints()`
let containerID: String = ""	// Grabbed from `getContainers(endpointID:)`
let action: PortainerKit.ExecuteAction = .start
let result = await api.execute(action, containerID: containerID, endpointID: endpointID)
switch result {
	case .success():
		// Handle success
	case .failure(let error):
		// Handle error
}
```
