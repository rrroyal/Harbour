//
//  Portainer+PreviewData.swift
//  Harbour
//
//  Created by royal on 14/01/2022.
//

#if DEBUG || WIDGET
import Foundation
import PortainerKit

let containerData = """
{
	"Command": "",
	"Created": 0,
	"HostConfig": {},
	"Id": "",
	"Image": "",
	"ImageID": "",
	"Labels": {},
	"Mounts": [],
	"Names": ["/Containy"],
	"NetworkSettings": {},
	"Ports": [],
	"State": "running",
	"Status": "Up 1 day"
 }
"""

extension Portainer {
	struct PreviewData {
		static let container: PortainerKit.Container = try! JSONDecoder().decode(PortainerKit.Container.self, from: containerData.data(using: .utf8)!)
	}
}
#endif
