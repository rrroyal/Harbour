//
//  ContainerLogsView+PreviewContext.swift
//  Harbour
//
//  Created by royal on 17/11/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

extension ContainerLogsView {
	enum PreviewContext {
		// swiftlint:disable all
		static let logs = """
[migrations] started
[migrations] no migrations found
usermod: no changes
───────────────────────────────────────

      ██╗     ███████╗██╗ ██████╗
      ██║     ██╔════╝██║██╔═══██╗
      ██║     ███████╗██║██║   ██║
      ██║     ╚════██║██║██║   ██║
      ███████╗███████║██║╚██████╔╝
      ╚══════╝╚══════╝╚═╝ ╚═════╝

   Brought to you by linuxserver.io
───────────────────────────────────────

To support LSIO projects visit:
https://www.linuxserver.io/donate/

───────────────────────────────────────
GID/UID
───────────────────────────────────────

User UID:    1001
User GID:    1001
───────────────────────────────────────
Linuxserver.io version: 5.0.1-r0-ls363
Build-date: 2024-11-10T06:55:27+00:00
───────────────────────────────────────
    
[custom-init] No custom files found, skipping...
WebUI will be started shortly after internal preparations. Please wait...

******** Information ********
To control qBittorrent, access the WebUI at: http://localhost:8080
Connection to localhost (::1) 8080 port [tcp/http-alt] succeeded!
[ls.io-init] done.
"""

		static let logsTimestamped = """
2024-11-17T13:38:17.374310633Z [migrations] started
2024-11-17T13:38:17.383140473Z [migrations] no migrations found
2024-11-17T13:38:17.510193092Z usermod: no changes
2024-11-17T13:38:17.518508503Z ───────────────────────────────────────
2024-11-17T13:38:17.518548423Z 
2024-11-17T13:38:17.518559233Z       ██╗     ███████╗██╗ ██████╗
2024-11-17T13:38:17.518569617Z       ██║     ██╔════╝██║██╔═══██╗
2024-11-17T13:38:17.518579714Z       ██║     ███████╗██║██║   ██║
2024-11-17T13:38:17.518589744Z       ██║     ╚════██║██║██║   ██║
2024-11-17T13:38:17.518599896Z       ███████╗███████║██║╚██████╔╝
2024-11-17T13:38:17.518610189Z       ╚══════╝╚══════╝╚═╝ ╚═════╝
2024-11-17T13:38:17.518620547Z 
2024-11-17T13:38:17.518630510Z    Brought to you by linuxserver.io
2024-11-17T13:38:17.518640380Z ───────────────────────────────────────
2024-11-17T13:38:17.519019790Z 
2024-11-17T13:38:17.519036009Z To support LSIO projects visit:
2024-11-17T13:38:17.519067914Z https://www.linuxserver.io/donate/
2024-11-17T13:38:17.519076528Z 
2024-11-17T13:38:17.519084510Z ───────────────────────────────────────
2024-11-17T13:38:17.519092942Z GID/UID
2024-11-17T13:38:17.519100680Z ───────────────────────────────────────
2024-11-17T13:38:17.536113326Z 
2024-11-17T13:38:17.536144723Z User UID:    1001
2024-11-17T13:38:17.536153664Z User GID:    1001
2024-11-17T13:38:17.536161804Z ───────────────────────────────────────
2024-11-17T13:38:17.542812086Z Linuxserver.io version: 5.0.1-r0-ls363
2024-11-17T13:38:17.544422175Z Build-date: 2024-11-10T06:55:27+00:00
2024-11-17T13:38:17.544477711Z ───────────────────────────────────────
2024-11-17T13:38:17.544487645Z     
2024-11-17T13:38:20.090330970Z [custom-init] No custom files found, skipping...
2024-11-17T13:38:20.698972776Z WebUI will be started shortly after internal preparations. Please wait...
2024-11-17T13:38:22.027133775Z 
2024-11-17T13:38:22.027194180Z ******** Information ********
2024-11-17T13:38:22.027203522Z To control qBittorrent, access the WebUI at: http://localhost:8080
2024-11-17T13:38:22.313666679Z Connection to localhost (::1) 8080 port [tcp/http-alt] succeeded!
2024-11-17T13:38:22.355048449Z [ls.io-init] done.
"""
		// swiftlint:enable all
	}
}
