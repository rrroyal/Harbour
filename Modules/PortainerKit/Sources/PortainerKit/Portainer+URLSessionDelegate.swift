//
//  Portainer+URLSessionDelegate.swift
//  PortainerKit
//
//  Created by royal on 17/10/2021.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

internal extension Portainer {
	final class URLSessionDelegate: NSObject, Foundation.URLSessionDelegate {
		func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
			if let trust = challenge.protectionSpace.serverTrust {
				return (.useCredential, URLCredential(trust: trust))
			} else {
				return (.useCredential, nil)
			}
		}
	}
}
