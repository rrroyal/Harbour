<p align="center">
	<img width="200" src="Resources/Icon/Harbour@2x.png" alt="Harbour Logo"><br>
	<h3 align="center">Harbour</h3>
	<p align="center">Docker management app for iOS written in SwiftUI.</p>
</p>

## Screenshots
<p align=center>
	<img height="450" src="Resources/Screenshots/Light/Dashboard.png" alt="Dashboard">
	<img height="450" src="Resources/Screenshots/Light/Detail.png" alt="Detail">
	<img height="450" src="Resources/Screenshots/Light/Mounts.png" alt="Mounts">
	<img height="450" src="Resources/Screenshots/Light/Network.png" alt="Network">
</p>

## Features
- 100% native and made in SwiftUI
- Light and Dark Mode
- Control and inspect containers
- Display logs
- Design based on Apple's *Human Interface Guidelines*
- iPad app

## How to use
![Xcode Build](https://github.com/rrroyal/Harbour/workflows/Xcode%20Build/badge.svg)
### Installation
1. Clone the repo.
2. Open the project in Xcode >= 11.4.
3. Change the Bundle Identifier and Signing Identity to your own.
4. Build and run!

### Docker setup
Download and install [Portainer](https://portainer.io). Then, login with your profile username and password in Harbour. **You can also use any other HTTP-based Docker reverse-proxy, but at this time only [Portainer](https://portainer.io) is officially supported.**

## Known bugs
- Container view doesn't update when in context menu
- NavigationView titles sometimes bug

## TODO
- [ ] Cursor support
- [ ] Battery optimization
- [ ] Localization
- [ ] Accessibility
- [ ] Shortcuts
- [ ] Fix context menu (properly scale icons, make UI update)
- [ ] Quick actions
- [ ] Allow selection of text in certain views
- [ ] Further optimization
- [ ] Fix NavigationViewTitle size bug
- [ ] CloudKit
- [ ] Stacks support
- [ ] Widget (?)
- [ ] Catalyst app
- [ ] watchOS app
- [ ] Create new containers (+ drag and drop)
- [ ] Edit containers
- [ ] Better logs support (streams)
- [ ] Notifications
- [ ] SiriKit
