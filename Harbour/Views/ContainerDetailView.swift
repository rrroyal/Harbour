//
//  ContainerDetailView.swift
//  Harbour
//
//  Created by royal on 15/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import SwiftUI
import SwiftyJSON

struct ContainerDetailView: View {
	@EnvironmentObject var Containers: ContainersModel
	@State var containerData: JSON = JSON.null
	@State var isDrawerExpanded: Bool = false
	@State var isPaused: Bool = false
	@State var isStopped: Bool = false
	@State var isRestarting: Bool = true
	@State var isDrawerPresented: Bool = false
	let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
	var container: Container
	
	init(container: Container) {
		self.container = container
	}
	
	public func refreshContainer() {
		// print("[!] Refreshing container with ID \"\(self.container.id)\"")
		self.Containers.lookupContainer(id: self.container.id, completionHandler: { container in
			self.containerData = container
			
			switch (container["State"]["Status"]) {
			case "running":				self.isPaused = false; self.isStopped = false; self.isRestarting = false; break
			case "paused":				self.isPaused = true; self.isStopped = false; self.isRestarting = false; break
			case "exited", "failed":	self.isPaused = false; self.isStopped = true; self.isRestarting = false; break
			default: print("[!] Uncaught type of status: \(container["State"]["Status"])"); break
			}
			
			if (container["State"]["Restarting"].boolValue || container["State"]["Health"]["Status"] == "starting") {
				self.isPaused = false; self.isStopped = true; self.isRestarting = true
			}
		})
	}
	
	var body: some View {
		ScrollView {
			VStack(alignment: .center) {
				// Subviews
				if (UIScreen.main.bounds.width > 400) {
					HStack {
						// Mounts
						NavigationLink(destination: ContainerMountsView(rawJSON: self.containerData), label: {
							ContainerDetailCell(label: "Mounts")
						})
						// Network
						NavigationLink(destination: ContainerNetworkView(rawJSON: self.containerData), label: {
							ContainerDetailCell(label: "Network")
						})
						// Environment
						NavigationLink(destination: ContainerEnvironmentView(rawJSON: self.containerData), label: {
							ContainerDetailCell(label: "Environment")
						})
						// JSON
						NavigationLink(destination: JSONView(rawJSON: self.containerData), label: {
							ContainerDetailCell(label: "JSON")
						})
						Spacer()
					}
					.padding(.bottom)
				} else {
					VStack {
						HStack {
							// Mounts
							NavigationLink(destination: ContainerMountsView(rawJSON: self.containerData), label: {
								ContainerDetailCell(label: "Mounts")
							})
							// Network
							NavigationLink(destination: ContainerNetworkView(rawJSON: self.containerData), label: {
								ContainerDetailCell(label: "Network")
							})
						}
						HStack {
							// Environment
							NavigationLink(destination: ContainerEnvironmentView(rawJSON: self.containerData), label: {
								ContainerDetailCell(label: "Environment")
							})
							// JSON
							NavigationLink(destination: JSONView(rawJSON: self.containerData), label: {
								ContainerDetailCell(label: "JSON")
							})
						}
					}
					.padding(.bottom)
				}
			
				VStack(alignment: .leading) {
					// General
					Section(header: Text("General").font(.title).bold().padding(.bottom, 5)) {
						// Status
						DetailLabel(title: "Status", value: self.containerData["State"]["Status"].stringValue, canCopy: true)
					
						// ID
						DetailLabel(title: "ID", value: self.containerData["Id"].stringValue, monospaced: true, canCopy: true)
						
						// Platform
						DetailLabel(title: "Platform", value: self.containerData["Platform"].stringValue, canCopy: true)
						
						// Created
						DetailLabel(title: "Created", value: self.containerData["Created"].stringValue, canCopy: true)
						
						// Image
						DetailLabel(title: "Image", value: self.containerData["Config"]["Image"].stringValue, canCopy: true)
						
						// Hostname
						DetailLabel(title: "Hostname", value: self.containerData["Config"]["Hostname"].stringValue, monospaced: true, canCopy: true)
						
						// Driver
						DetailLabel(title: "Driver", value: self.containerData["Driver"].stringValue, canCopy: true)
					}
					
					Spacer()
										
					// State
					Section(header: Text("State").font(.title).bold().padding(.bottom, 5)) {
						// PID
						DetailLabel(title: "PID", value: String(self.containerData["State"]["Pid"].intValue), canCopy: true)
						
						// FinishedAt
						DetailLabel(title: "FinishedAt", value: self.containerData["State"]["FinishedAt"].stringValue, canCopy: true)
						
						// Running
						DetailLabel(title: "Running", value: self.containerData["State"]["Running"].boolValue ? "true" : "false")
						
						// Error
						DetailLabel(title: "Error", value: self.containerData["State"]["Error"].stringValue != "" ? self.containerData["State"]["Error"].stringValue : "none", canCopy: true)
						
						// Paused
						DetailLabel(title: "Paused", value: self.containerData["State"]["Paused"].boolValue ? "true" : "false")
						
						// Dead
						DetailLabel(title: "Dead", value: self.containerData["State"]["Dead"].boolValue ? "true" : "false")
						
						// Restarting
						DetailLabel(title: "Restarting", value: self.containerData["State"]["Restarting"].boolValue ? "true" : "false")
						
						// OOMKilled
						DetailLabel(title: "OOMKilled", value: self.containerData["State"]["OOMKilled"].boolValue ? "true" : "false")
						
						// ExitCode
						DetailLabel(title: "ExitCode", value: String(self.containerData["State"]["ExitCode"].intValue), canCopy: true)
					}
					
					Spacer()
					
					// Health
					if (self.containerData["State"]["Health"].exists()) {
						Section(header: Text("Health").font(.title).bold().padding(.bottom, 5)) {
							// Status
							DetailLabel(title: "Status", value: self.containerData["State"]["Health"]["Status"].stringValue, canCopy: true)
							
							// FailingStreak
							DetailLabel(title: "FailingStreak", value: String(self.containerData["State"]["Health"]["FailingStreak"].intValue), canCopy: true)
							
							// Latest log
							if ((self.containerData["State"]["Health"]["Log"].arrayObject?.count ?? 0) > 0) {
								// Output
								DetailLabel(title: "Latest Output", value: "\((self.containerData["State"]["Health"]["Log"].arrayObject?.last as! [String: Any])["Output"] ?? "unknown")", monospaced: true, canCopy: true)
								
								// Exit code
								DetailLabel(title: "Latest Exit Code", value: "\((self.containerData["State"]["Health"]["Log"].arrayObject?.last as! [String: Any])["ExitCode"] ?? "unknown")", canCopy: true)
								
								// Start
								DetailLabel(title: "Latest Start", value: "\((self.containerData["State"]["Health"]["Log"].arrayObject?.last as! [String: Any])["Start"] ?? "unknown")", canCopy: true)
								
								// End
								DetailLabel(title: "Latest End", value: "\((self.containerData["State"]["Health"]["Log"].arrayObject?.last as! [String: Any])["End"] ?? "unknown")", canCopy: true)
							}
						}
						
						Spacer()
					}
				}
				.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
			}
			.accentColor(.primary)
			.padding()
			.padding(.bottom, SettingsModel().enableDrawer ? 100 : 0)
		}
		// .transition(.opacity)
		// .animation(.easeInOut)
		.navigationBarTitle(Text(container.name))
		.navigationBarItems(trailing: NavigationLink(destination: ContainerLogsView(containerID: container.id).environmentObject(Containers)) {
			Image(systemName: "text.alignleft")
				.font(.system(size: 20))
				.padding([.leading, .vertical])
				.padding(.trailing, 2)
		})
		.overlay(
			SettingsModel().enableDrawer ?
				AnyView(DrawerView(isExpanded: $isDrawerExpanded, content: DrawerContentView(containerID: self.container.id, isPaused: $isPaused, isStopped: $isStopped, isRestarting: $isRestarting, context: self)).environmentObject(Containers).offset(x: 0, y: self.isDrawerPresented ? 0 : 150))
				: AnyView(EmptyView())
		)
		.onAppear {
			// Present drawer
			 self.isDrawerPresented = true
			
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
			
			self.refreshContainer()
		}
		.onReceive(timer) { _ in
			print("[*] Automatically refreshing...")
			withAnimation {
				self.refreshContainer()
			}
		}
	}
}

struct ContainerDetailView_Previews: PreviewProvider {
    static var previews: some View {
		ContainerDetailView(container: Container(id: "ID", name: "NAME", createdAt: 0, state: .unknown, statusColor: .red))
	}
}
