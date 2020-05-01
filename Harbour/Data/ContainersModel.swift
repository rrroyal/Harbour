//
//  ContainersModel.swift
//  Harbour
//
//  Created by royal on 15/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import SwiftUI
import Combine
import Alamofire
import SwiftyJSON
import KeychainAccess

/// Actions we can perform with a container
enum ContainerAction {
	case start
	case unpause
	case stop
	case pause
	case kill
	case restart
}

/// Container' statuses
enum ContainerState {
	case running
	case runningHealthy
	case runningUnhealthy
	case paused
	case starting
	case failed
	case exited
	case unknown
}

/// Struct containing necessary container data
struct Container: Hashable, Identifiable {
	let id: String
	var name: String
	var createdAt: Int
	var state: ContainerState
	var statusColor: Color
}

/// Model with our server data
class ContainersModel: ObservableObject {
	@Published var containers: [Container] = []
	@Published var status: String = ""
	
	private let keychain: Keychain = Keychain(service: "\(Bundle.main.bundleIdentifier ?? "harbour")-token").label("Harbour Token").synchronizable(true).accessibility(.afterFirstUnlock)
	
	private var retryCount: Int = 0
	
	private var jwt: String {
		get { return keychain["JWT"] ?? "" }
		set (value) { if (value == keychain["JWT"] ?? "") { return }; keychain["JWT"] = value }
	}
	
	public var username: String {
		get { return keychain["username"] ?? "" }
		set (value) { if (value == keychain["username"] ?? "") { return }; keychain["username"] = value }
	}
	private var password: String {
		get { return keychain["password"] ?? "" }
		set (value) { if (value == keychain["password"] ?? "") { return }; keychain["password"] = value }
	}
	
	public var loggedIn: Bool {
		get {
			return (UserDefaults.standard.bool(forKey: "loggedIn") && self.username != "" && self.password != "")
		}
		set (value) {
			if (UserDefaults.standard.bool(forKey: "loggedIn") != value) {
				print("[!] Updating loggedIn: \"\(value)\"")
				UserDefaults.standard.set(value, forKey: "loggedIn")
				
				if (value) {
					print("[*] Logging in")
					self.getToken(username: self.username, password: self.password, completionHandler: { success in
						if (!success) { return }
						self.getContainers()
					})
				} else {
					print("[*] Logging out")
					self.containers = []
					self.username = ""
					self.password = ""
					self.jwt = ""
					self.status = "Not logged in"
				}
			}
		}
	}
	
	public var isReachable: Bool {
		get {
			let val = NetworkReachabilityManager()?.isReachable ?? false
			if (!val) {
				self.status = "No internet connection"
				self.containers = []
				return false
			}
			return val
		}
	}
	
	public var endpointURL: String {
		get {
			return UserDefaults.standard.string(forKey: "endpointURL") ?? ""
		}
		set (value) {
			if (value != UserDefaults.standard.string(forKey: "endpointURL")) {
				print("[!] Setting endpointURL: \"\(value)\"")
				UserDefaults.standard.set(value, forKey: "endpointURL")
			}
		}
	}
	var selectedEndpointID: Int = 1
	
	// MARK: - init()
	init() {
		print("[*] ContainersModel initialized!")
		
		// Is endpointURL present?
		if (endpointURL == "") {
			print("[!] No URL found! (init)")
			self.loggedIn = false
			self.status = "No endpoint URL"
			return
		}
		
		// Is login data saved?
		if (username == "" || password == "" || !loggedIn) {
			print("[!] No login data found! (init)")
			self.loggedIn = false
			self.status = "Not logged in"
			return
		}
    }
	
	// MARK: - login()
	/// Login with supplied username and password. If any of the parameters is empty, it will log user out.
	/// - Parameters:
	///   - username: Endpoint user name
	///   - password: Endpoint user password
	/* public func login(username: String, password: String) {
		print("[!] Updating login info: \"\(username)\":\"\(password.lengthOfBytes(using: .utf8))B\"")
		
		if (username == "" || password == "") {
			print("[*] Logging out.")
			UserDefaults.standard.set(false, forKey: "loggedIn")
			self.username = ""
			self.password = ""
			self.jwt = ""
			self.status = "Not logged in"
			self.containers = []
		} else {
			print("[*] Updating token...")
			self.username = username
			self.password = password
			getToken(username: username, password: password, completionHandler: { success in
				if (!success) { return }
				self.getContainers()
			})
		}
	} */
	
	// MARK: - getToken()
	/// Get token from server URL
	/// - Parameters:
	///   - username: Username that we will log in with
	///   - password: Password for account with our username
	///   - refresh: Should we refresh after logging in?
	func getToken(username: String, password: String, refresh: Bool? = false, completionHandler: ((Bool) -> (Void))? = nil) {
		if (endpointURL == "") {
			print("[!] No URL found! (getToken)")
			status = "No endpoint URL"
			containers = []
			return
		}
		
		if (username == "" || password == "") {
			print("[!] No auth data supplied! (getToken(username: \"\(username)\", password: \"\(password.lengthOfBytes(using: .utf8))B\"))")
			status = "Not logged in"
			return
		}
		
		// Is there an internet connection?
		if (!isReachable) {
			print("[!] No internet connection!")
			return
		}
		
		let parameters = [
			"username": username,
			"password": password
		]
		print("[*] No token found! Logging in to \"\(self.endpointURL)\" as \"\(username):\(password.lengthOfBytes(using: .utf8))B\"...")
		
		AF.request(URL.init(string: "\(endpointURL)/api/auth")!, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
			switch response.result {
			case .success(_):
				if let responseValue = response.value {
					let json: JSON = JSON(responseValue)
					
					if (json["jwt"].stringValue == "") {
						print("[!] Invalid JWT response! JSON: \(json)")
						self.status = json["message"].stringValue
						(completionHandler ?? {_ in})(false)
						return
					}
					
					print("[*] Logged in! JWT length: \(String(self.keychain["JWT"] ?? "").count)")
					self.keychain["JWT"] = json["jwt"].stringValue
					self.retryCount = 0
					self.status = ""
					self.username = username
					self.password = password
					self.loggedIn = true
					if ((refresh ?? false) && self.retryCount < 3) {
						print("[*] Refreshing containers...")
						self.getContainers()
					}
					(completionHandler ?? {_ in })(true)
				}
				break
			case .failure(let error):
				print("[!] Login error! \(error)")
				if (self.retryCount < 3) {
					print("[*] Trying again \(self.retryCount)...")
					self.getToken(username: username, password: password)
				}
				self.retryCount += 1
				self.status = "Not logged in"
				self.username = ""
				self.password = ""
				self.jwt = ""
				self.containers = []
				break
			}
		}
	}
	
	// MARK: - getEndpoints()
	/// Get available endpoints from selected server
	public func getEndpoints() {
		if (endpointURL == "") {
			print("[!] No URL found! (getEndpoints)")
			status = "No endpoint URL"
			containers = []
			return
		}
		
		// Is there an internet connection?
		if (!isReachable) {
			print("[!] No internet connection!")
			return
		}
		
		if (jwt == "") {
			print("[!] No JWT found! (getEndpoints)")
			getToken(username: username, password: password)
		}
		
		if (!loggedIn) {
			print("[!] Not logged in! (getEndpoints)")
			status = "Not logged in"
			return
		}
						
		// Let's lookup endpoints
		print("[*] Looking up endpoints")
		AF.request(URL.init(string: "\(endpointURL)/api/endpoints")!, method: .get, encoding: JSONEncoding.default, headers: [
			"Authorization": "Bearer \(jwt)"
		]).responseJSON { (response) in
			switch response.result {
			case .success(_):
				if let responseValue = response.value {
					if (JSON(responseValue)["message"] == "Invalid JWT token") {
						print("[!] Invalid token (getEndpoints)")
						// self.keychain["JWT"] = ""
						self.status = JSON(responseValue)["message"].stringValue
						self.getToken(username: self.username, password: self.password)
						return
					}
					let rawJSON = JSON(responseValue)
					if (rawJSON.count > 1) {
						// TODO
						print("[!] There's more than one endpoints (\(rawJSON.count))")
					}
					print("[*] Found \(rawJSON.count) endpoints")
					self.selectedEndpointID = 1
					self.retryCount = 0
					self.status = ""
				}
				break
			case .failure(let error):
				print("[!] Endpoints error! \(error)")
				if (self.retryCount < 3) {
					print("[*] Trying again \(self.retryCount)...")
					self.getEndpoints()
				}
				self.retryCount += 1
				break
			}
		}
	}
	
	// MARK: - getContainers()
	/// Get available containers from selected endpoint
	public func getContainers() {
		if (endpointURL == "") {
			print("[!] No URL found! (getContainers)")
			status = "No endpoint URL"
			containers = []
			return
		}
		
		/* if (selectedEndpointID == -1) {
			print("[!] No endpointID found! (getContainers)")
			getEndpoints()
		} */
		
		if (self.username == "" || self.password == "") {
			print("[!] Not logged in! (getContainers)")
			status = "Not logged in"
			return
		}
		
		// Is there an internet connection?
		if (!isReachable) {
			print("[!] No internet connection!")
			return
		}
		
		if (jwt == "" || (!loggedIn && self.username != "" && self.password != "")) {
			print("[!] No JWT found! (getContainers)")
			self.retryCount += 1
			getToken(username: username, password: password, refresh: true)
			return
		}
								
		// Lookup containers
		print("[*] Looking up containers with endpointID \(selectedEndpointID)...")
		self.status = "Loading..."
		AF.request(URL.init(string: "\(endpointURL)/api/endpoints/\(selectedEndpointID)/docker/containers/json?all=1")!, method: .get, encoding: JSONEncoding.default, headers: [
			"Authorization": "Bearer \(jwt)"
		]).responseJSON { (response) in
			switch response.result {
			case .success(_):
				if let responseValue = response.value {
					let rawJSON: JSON = JSON(responseValue)
					
					if (JSON(responseValue)["message"] == "Invalid JWT token") {
						print("[!] Invalid token (getContainers)")
						// self.keychain["JWT"] = ""
						self.status = JSON(responseValue)["message"].stringValue
						self.getToken(username: self.username, password: self.password, refresh: true)
						return
					}
					self.retryCount = 0
					
					print("[*] Found \(rawJSON.count) containers.")
					
					if (rawJSON.count == 0) {
						self.status = "Nothing found"
						return
					}
					
					self.containers = []
					rawJSON.forEach({ (index, item) in
						let id: String = item["Id"].stringValue
						var name: String = item["Names"][0].stringValue
						let createdAt: Int = item["Created"].intValue
						let apiState: String = item["State"].stringValue
						let status: String = item["Status"].stringValue
						
						var statusColor: Color = .clear
						var state: ContainerState = .unknown
						
						name.remove(at: name.startIndex)
												
						switch (apiState) {
						case "running":	state = .running; break
						case "paused":	state = .paused; break
						case "failed":	state = .failed; break
						case "exited":	state = .exited; break
						default: break
						}
						
						if (state == .running && status.contains("unhealthy")) {
							state = .runningUnhealthy
						} else if (state == .running && status.contains("healthy")) {
							state = .runningHealthy
						} else if (state == .running && status.contains("starting")) {
							state = .starting
						}
						
						switch (state) {
						case .running, .runningHealthy:	statusColor = Color(UIColor.systemGreen); break
						case .runningUnhealthy:			statusColor = Color(UIColor.systemOrange); break
						case .starting:					statusColor = Color(UIColor.systemBlue); break
						case .paused:					statusColor = Color(UIColor.systemGray4); break
						case .exited:					statusColor = Color(UIColor.systemGray); break
						case .failed:					statusColor = Color(UIColor.systemRed); break
						case .unknown:					statusColor = Color(UIColor.clear); break
						}
						
						let container: Container = Container(id: id, name: name, createdAt: createdAt, state: state, statusColor: statusColor)
						self.containers.append(container)
					})
					self.status = ""
					self.retryCount = 0
				}
				break
			case .failure(let error):
				print("[!] Containers error! \(error)")
				break
			}
		}
	}
	
	// MARK: - lookupContainer()
	/// Lookup container with selected ID
	/// - Parameter id: ID of container
	/// - Parameter completionHandler: function that handles returned data after completion
	public func lookupContainer(id: String, completionHandler: @escaping (JSON) -> Void) {
		if (endpointURL == "") {
			print("[!] No URL found! (lookupContainer)")
			status = "No endpoint URL"
			containers = []
			return
		}
		
		// Is there an internet connection?
		if (!isReachable) {
			print("[!] No internet connection!")
			return
		}
		
		if (selectedEndpointID == -1) {
			print("[!] No endpointID found! (lookupContainer)")
			getEndpoints()
		}
		
		if (jwt == "") {
			print("[!] No JWT found! (lookupContainer)")
			getToken(username: username, password: password)
		}
				
		// Lookup container
		print("[*] Looking up container with ID \"\(id)\"...")
		AF.request(URL.init(string: "\(endpointURL)/api/endpoints/\(selectedEndpointID)/docker/containers/\(id)/json")!, method: .get, encoding: JSONEncoding.default, headers: [
			"Authorization": "Bearer \(jwt)"
		]).responseJSON { (response) in
			switch response.result {
			case .success(_):
				if let responseValue = response.value {
					let rawJSON = JSON(responseValue)
					print("[*] Found container with ID \(rawJSON["Id"].stringValue) (Name: \"\(rawJSON["Name"].stringValue)\").")
					self.retryCount = 0
					completionHandler(rawJSON)
				}
				break
			case .failure(let error):
				print("[!] Container lookup error! \(error)")
				/* if (self.retryCount < 3) {
					print("[*] Trying again \(self.retryCount)...")
					self.lookupContainer(id: id)
				} */
				self.retryCount += 1
				break
			}
		}
	}
	
	// MARK: - performAction()
	/// Perform action to a container
	/// - Parameters:
	///   - id: Container ID
	///   - action: Action to perform
	public func performAction(id: String, action: ContainerAction) {
		// Validate
		if (endpointURL == "") {
			print("[!] No URL found! (performAction)")
			status = "No endpoint URL"
			containers = []
			return
		}
		
		if (self.username == "" || self.password == "") {
			print("[!] Not logged in! (performAction)")
			status = "Not logged in"
			return
		}
		
		// Is there an internet connection?
		if (!isReachable) {
			print("[!] No internet connection!")
			return
		}
		
		if (jwt == "" || (!loggedIn && self.username != "" && self.password != "")) {
			print("[!] No JWT found! (performAction)")
			getToken(username: username, password: password)
		}
		
		// Perform action
		print("[*] Performing \"\(action)\" with ContainerID \"\(id)\"...")
		AF.request(URL.init(string: "\(endpointURL)/api/endpoints/\(selectedEndpointID)/docker/containers/\(id)/\(action)")!, method: .post, encoding: URLEncoding.httpBody, headers: [
			"Authorization": "Bearer \(jwt)"
		]).responseString { (response) in
			switch response.result {
			case .success(_):
				if let responseValue = response.value {
					print("[*] Success! Refreshing...")
					self.getContainers()
					if (responseValue != "") {
						print("[*] responseValue: \(responseValue.trimmingCharacters(in: .newlines))")
					}
				}
				break
			case .failure(let error):
				print("[!] performAction error! \(error)")
				/* if (self.retryCount < 3) {
					print("[*] Trying again \(self.retryCount)...")
					self.getEndpoints()
				}
				self.retryCount += 1 */
				break
			}
		}
	}
	
	// MARK: - getLogs()
	/// Get container logs as String object
	/// - Parameters:
	///   - id: ID of container
	///   - completionHandler: Cunction that handles returned data after completion
	public func getLogs(id: String, completionHandler: @escaping (String) -> Void) {
		if (endpointURL == "") {
			print("[!] No URL found! (lookupContainer)")
			status = "No endpoint URL"
			containers = []
			return
		}
		
		// Is there an internet connection?
		if (!isReachable) {
			print("[!] No internet connection!")
			return
		}
		
		if (selectedEndpointID == -1) {
			print("[!] No endpointID found! (lookupContainer)")
			getEndpoints()
		}
		
		if (jwt == "") {
			print("[!] No JWT found! (lookupContainer)")
			getToken(username: username, password: password)
		}
		
		// Amount of lines to output
		let tail = "1000"
		
		// Lookup logs
		print("[*] Looking up container logs with ID \"\(id)\"...")
		AF.request(URL.init(string: "\(endpointURL)/api/endpoints/\(selectedEndpointID)/docker/containers/\(id)/logs?stdout=true&stderr=true&timestamps=true&tail=\(tail)")!, method: .get, encoding: URLEncoding.httpBody, headers: [
			"Authorization": "Bearer \(jwt)"
		]).responseString { (response) in
			switch response.result {
			case .success(_):
				if let responseValue = response.value {
					print("[*] Found container logs with ID \(id). Length: \(responseValue.lengthOfBytes(using: .utf8))B.")
					self.retryCount = 0
					completionHandler("(Showing \(tail) latest lines)\n\(responseValue)")
				}
				break
			case .failure(let error):
				print("[!] Container logs error! \(error.localizedDescription)")
				/* if (self.retryCount < 3) {
					print("[*] Trying again \(self.retryCount)...")
					self.lookupContainer(id: id)
				} */
				self.retryCount += 1
				completionHandler("Error: \(error.localizedDescription)")
				break
			}
		}
	}
}
