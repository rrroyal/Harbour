//
//  ContainerDetailView+.swift
//  Harbour
//
//  Created by royal on 23/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import SwiftUI
import SwiftyJSON

/// Displays environment variables as list
struct ContainerEnvironmentView: View {
	var rawJSON: JSON
	
	var body: some View {
		List(rawJSON["Config"]["Env"].arrayObject as? [String] ?? [], id: \.self) { property in
			Text(property)
				.font(.system(.body, design: .monospaced))
				.onTapGesture {
					if (property.isEmpty) { return }
					generateHaptic(.light)
					UIPasteboard.general.string = property
					print("[!] Copied env property: \"\(property)\"")
			}
		}
		.navigationBarTitle(Text("Environment"))
	}
}

/// Displays network properties
struct ContainerNetworkView: View {
	@State var rawJSON: JSON
	@State var ports: [ExposedPort] = []
	
	struct ExposedPort: Hashable, Identifiable {
		var id: String
		var port: Int
		var protoc: String
		var hostIP: String?
		var hostPort: Int?
	}
	
	/* private struct NetworkSettings {
		var ipPrefixLen: Int
		var ports: [ExposedPort]
		var hairpinMode: Bool
		var sandboxID: String
		var globalIPv6PrefixLen: Int
		var sandboxKey: String
		
		var gateway: String?
		var secondaryIPAdresses: [Any]?
		var linkLocalIPv6PrefixLen: Int?
		var ipv6Gateway: String?
		var linkLocalIPv6Address: String?
		var macAddress: String?
		var secondaryIPv6Addresses: [Any]?
		var endpointID: String?
		var globalIPv6Address: String?
		var networks: [Any]?
		var bridge: String?
	} */
	
	private func formatPorts() {
		self.rawJSON["NetworkSettings"]["Ports"].dictionaryObject?.forEach({ key, value in
			let id = key
			let port: Int = Int(String(key.split(separator: "/")[0])) ?? 0
			let protoc: String = String(key.split(separator: "/")[1])
			var hostIP: String?
			var hostPort: Int?
			
			if let val = value as? [Any] {
				let json = JSON(val[0])
				hostIP = json["HostIp"].stringValue
				hostPort = json["HostPort"].intValue
			}
			
			self.ports.append(ExposedPort(id: id, port: port, protoc: protoc, hostIP: hostIP, hostPort: hostPort))
		})
		
		self.ports.sort(by: { $0.port < $1.port })
	}
	
	var body: some View {
		List {
			ForEach(ports) { port in
				Section(header: Text(port.id)) {
					// Protocol
					ListCellLabel(title: "Protocol", value: port.protoc, canCopy: true)
					
					// Port
					ListCellLabel(title: "Container Port", value: String(port.port), canCopy: true)
					
					/// Port is not always exposed
					if (port.hostIP != nil && port.hostPort != nil) {
						// Host Port
						ListCellLabel(title: "Host Port", value: "\(port.hostPort ?? 0)", canCopy: true)	// Compiler is throwing errors if I use String()
						
						// Host IP
						ListCellLabel(title: "Host IP", value: port.hostIP ?? "none", canCopy: true)
					}
				}
			.padding(.vertical, 2)
			}
		}
		.listStyle(GroupedListStyle())
		.environment(\.horizontalSizeClass, .regular)
		.navigationBarTitle(Text("Network"))
		.onAppear {
			self.formatPorts()
		}
	}
}

/// Displays mounted volumes and directories
struct ContainerMountsView: View {
	@State var rawJSON: JSON = JSON.null
	@State var mounts: [Mount] = []
	
	struct Mount: Hashable, Identifiable {
		var id: String
		var rw: Bool
		var driver: String?
		var name: String
		var source: String
		var propagation: String?
		var type: String
		var destination: String
		var mode: String?
	}
	
	private func formatMounts() {
		self.rawJSON["Mounts"].arrayObject?.forEach({ mount in
			let json: JSON = JSON(mount)
			
			let rw: Bool = json["RW"].boolValue
			let driver: String = json["Driver"].stringValue
			let source: String = json["Source"].stringValue
			let propagation: String = json["Propagation"].stringValue
			let type: String = json["Type"].stringValue
			let destination: String = json["Destination"].stringValue
			let mode: String = json["Mode"].stringValue
			
			var name: String = json["Name"].stringValue
			
			if (name.isEmpty) {
				name = "\(source):\(destination)"
			}
			
			if (type == "bind") {
				self.mounts.append(Mount(id: name, rw: rw, name: name, source: source, propagation: propagation, type: type, destination: destination))
			} else {
				self.mounts.append(Mount(id: name, rw: rw, driver: driver, name: name, source: source, type: type, destination: destination, mode: mode))
			}
		})
	}
	
	var body: some View {
		List {
			ForEach(mounts) { mount in
				Section(header: Text(mount.destination)) {
					// Name
					ListCellLabel(title: "Name", value: mount.name, canCopy: true)
					
					// Type
					ListCellLabel(title: "Type", value: mount.type, canCopy: true)
					
					// Source
					ListCellLabel(title: "Source", value: mount.source, canCopy: true)
					
					// Destination
					ListCellLabel(title: "Destination", value: mount.destination, canCopy: true)
					
					// RW
					ListCellLabel(title: "Read / Write", value: mount.rw ? "true" : "false")
					
					/// Volume-type specific labels
					if (mount.type == "volume") {
						// Driver
						ListCellLabel(title: "Driver", value: mount.driver ?? "none", canCopy: true)
						
						// Mode
						ListCellLabel(title: "Mode", value: mount.mode ?? "unknown", canCopy: true)
					} else {
						// Propagation
						ListCellLabel(title: "Propagation", value: mount.propagation ?? "unknown", canCopy: true)
					}
				}
				.padding(.vertical, 2)
			}
		}
		.listStyle(GroupedListStyle())
		.environment(\.horizontalSizeClass, .regular)
		.navigationBarTitle(Text("Mounts"))
		.onAppear {
			self.formatMounts()
		}
	}
}

/// Displays raw JSON string
struct JSONView: View {
	@State var rawJSON: JSON
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading) {
				Text("\(rawJSON.rawString() ?? "{}")")
					.font(.system(size: 12, weight: .regular, design: .monospaced))
					.lineLimit(nil)
					.multilineTextAlignment(.leading)
					.onTapGesture {
						generateHaptic(.light)
						UIPasteboard.general.string = self.rawJSON.rawString() ?? "{}"
						print("[!] Copied rawJSON (length: \(self.rawJSON.rawString()?.lengthOfBytes(using: .utf8) ?? 0)B)")
					}
			}
			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
			.padding([.top, .leading], 3)
			.padding(.trailing, 5)
		}
		.navigationBarTitle(Text("JSON"), displayMode: .inline)
	}
}

/// Displays container' logs
struct ContainerLogsView: View {
	@EnvironmentObject var Containers: ContainersModel
	@State var containerLogs: String = "Loading..."
	let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
	let containerID: String
	
	var body: some View {
		ScrollView {
			VStack (alignment: .leading) {
				Text("\(containerLogs)")
					.multilineTextAlignment(.leading)
					.lineLimit(nil)
					.font(.system(size: 12, weight: .regular, design: .monospaced))
					.onTapGesture {
						generateHaptic(.light)
						UIPasteboard.general.string = self.containerLogs
						print("[!] Copied logs of \"\(self.containerID)\" (length: \(self.containerLogs.lengthOfBytes(using: .utf8))B)")
					}
			}
			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
			.padding([.top, .leading], 3)
			.padding(.trailing, 5)
		}
		.navigationBarTitle(Text("Logs"), displayMode: .inline)
		.navigationBarItems(trailing: Button(action: {
			print("[!] Manually refreshing logs!")
			generateHaptic(.light)
			self.Containers.getLogs(id: self.containerID, completionHandler: { logs in
				self.containerLogs = logs
			})
		}) {
			Image(systemName: "arrow.clockwise")
				.font(.system(size: 20))
				.padding([.leading, .vertical])
				.padding(.trailing, 2)
		})
		.onAppear {
			// Cancel timer if automaticRefresh is disabled
			if (!SettingsModel().automaticRefresh) {
				print("[*] Cancelling timer")
				self.timer.upstream.connect().cancel()
			}
			
			// Cancel timer if Low Power mode is enabled
			if (ProcessInfo.processInfo.isLowPowerModeEnabled) {
				print("[!] Low power mode detected! Cancelling timer.")
				self.timer.upstream.connect().cancel()
			}
			
			self.Containers.getLogs(id: self.containerID, completionHandler: { logs in
				self.containerLogs = logs
			})
		}
		.onReceive(timer) { _ in
			print("[*] Refreshing logs...")
			self.Containers.getLogs(id: self.containerID, completionHandler: { logs in
				self.containerLogs = logs
			})
		}
	}
}

/// Drawer contents
struct DrawerContentView: View {
	@EnvironmentObject var Containers: ContainersModel
	@State var containerID: String
	@Binding var isPaused: Bool
	@Binding var isStopped: Bool
	@Binding var isRestarting: Bool
	let context: ContainerDetailView
	
	let buttonCornerRadius: CGFloat = 12
	let buttonWidth: CGFloat = 155
	let buttonHeight: CGFloat = 58
	let buttonBackground: Color = Color(UIColor.systemGray4).opacity(0.15)
	
	var body: some View {
		VStack {
			// Start, Resume
			HStack {
				// Start
				Button(action: {
					generateHaptic(.light)
					self.Containers.performAction(id: self.containerID, action: .start)
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						self.context.refreshContainer()
					}
				}) {
					Text("Start")
						.fontWeight(.semibold)
						.padding()
						.frame(width: buttonWidth, height: buttonHeight)
				}
					.background(RoundedRectangle(cornerRadius: buttonCornerRadius)
					.fill(buttonBackground))
					.disabled(!(!isPaused && isStopped) || isRestarting)
				
				Spacer()
				
				// Resume
				Button(action: {
					generateHaptic(.light)
					self.Containers.performAction(id: self.containerID, action: .unpause)
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						self.context.refreshContainer()
					}
				}) {
					Text("Resume")
						.fontWeight(.semibold)
						.padding()
						.frame(width: buttonWidth, height: buttonHeight)
				}
					.background(RoundedRectangle(cornerRadius: buttonCornerRadius)
					.fill(buttonBackground))
					.disabled(!(isPaused && !isStopped) || isRestarting)
			}
			.padding(.bottom)
			
			// Stop, Pause
			HStack {
				// Stop
				Button(action: {
					generateHaptic(.light)
					self.Containers.performAction(id: self.containerID, action: .stop)
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						self.context.refreshContainer()
					}
				}) {
					Text("Stop")
						.fontWeight(.semibold)
						.padding()
						.frame(width: buttonWidth, height: buttonHeight)
				}
					.background(RoundedRectangle(cornerRadius: buttonCornerRadius)
					.fill(buttonBackground))
					.disabled(!(!isPaused && !isStopped) || isRestarting)
				
				Spacer()
				
				// Pause
				Button(action: {
					generateHaptic(.light)
					self.Containers.performAction(id: self.containerID, action: .pause)
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						self.context.refreshContainer()
					}
				}) {
					Text("Pause")
						.fontWeight(.semibold)
						.padding()
						.frame(width: buttonWidth, height: buttonHeight)
				}
					.background(RoundedRectangle(cornerRadius: buttonCornerRadius)
					.fill(buttonBackground))
					.disabled(!(!isPaused && !isStopped) || isRestarting)
			}
			.padding(.bottom)
			
			// Restart, Kill
			HStack {
				// Restart
				Button(action: {
					generateHaptic(.light)
					self.Containers.performAction(id: self.containerID, action: .restart)
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						self.context.refreshContainer()
					}
				}) {
					Text("Restart")
						.fontWeight(.semibold)
						.padding()
						.frame(width: buttonWidth, height: buttonHeight)
				}
					.background(RoundedRectangle(cornerRadius: buttonCornerRadius)
					.fill(buttonBackground))
					.disabled(!(!isPaused && !isStopped) || isRestarting)
				
				Spacer()
				
				// Kill
				Button(action: {
					generateHaptic(.light)
					self.Containers.performAction(id: self.containerID, action: .kill)
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						self.context.refreshContainer()
					}
				}) {
					Text("Kill")
						.fontWeight(.semibold)
						.accentColor(Color(UIColor.systemRed))
						.padding()
						.frame(width: buttonWidth, height: buttonHeight)
				}
					.background(RoundedRectangle(cornerRadius: buttonCornerRadius)
					.fill(buttonBackground))
					.disabled(!(!isPaused && !isStopped) || isRestarting)
			}
			.padding(.bottom)
			
			Spacer()
		}
		.padding(.horizontal, 5)
		.padding(.vertical)
		.animation(.easeInOut)
		.transition(.opacity)
	}
}
