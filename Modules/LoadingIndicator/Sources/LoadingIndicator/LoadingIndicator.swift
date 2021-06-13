//
//  LoadingIndicator.swift
//  LoadingIndicator
//
//  Created by royal on 12/03/2021.
//	Based on https://github.com/futuretap/FTLinearActivityIndicator
//

import UIKit

@available(iOS 13, *)
public class LoadingIndicatorView: UIView {
	// MARK: - Properties

	private let hasNotch: Bool

	private let duration: Double = 1.5
	private let leftGradientLayer = CAGradientLayer()
	private let rightGradientLayer = CAGradientLayer()
	private let leftAnimation = CABasicAnimation(keyPath: "position.x")
	private let rightAnimation = CABasicAnimation(keyPath: "position.x")

	public var animating: Bool = false

	init(frame: CGRect, hasNotch: Bool) {
		self.hasNotch = hasNotch
		super.init(frame: frame)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override public func layoutSubviews() {
		super.layoutSubviews()

		self.clipsToBounds = true
		self.layer.cornerRadius = self.hasNotch ? (bounds.size.height * 0.5) : 0

		self.isHidden = !self.animating
		self.layer.addSublayer(self.leftGradientLayer)
		self.layer.addSublayer(self.rightGradientLayer)
	}

	override public func tintColorDidChange() {
		super.tintColorDidChange()

		if animating {
			startAnimating()
		} else {
			startAnimating()
			stopAnimating()
		}
	}

	public func startAnimating() {
		self.animating = true

		let color: UIColor
		if let statusBarStyle = self.window?.windowScene?.statusBarManager?.statusBarStyle {
			switch statusBarStyle {
				case .lightContent: color = UIColor.white.withAlphaComponent(0.7)
				case .darkContent: color = UIColor.black.withAlphaComponent(0.7)
				case .default: color = UIColor.label.withAlphaComponent(0.7)
				@unknown default: color = self.tintColor.withAlphaComponent(0.7)
			}
		} else {
			color = UIColor.label.withAlphaComponent(0.7)
		}

		let clear = color.withAlphaComponent(0)

		self.leftGradientLayer.colors = [clear.cgColor, color.cgColor]
		self.leftGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
		self.leftGradientLayer.endPoint = CGPoint(x: 1, y: 0)
		self.leftGradientLayer.anchorPoint = CGPoint(x: 0, y: 0)
		self.leftGradientLayer.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
		self.leftGradientLayer.cornerRadius = self.hasNotch ? (bounds.size.height * 0.5) : 0
		self.leftGradientLayer.masksToBounds = true

		self.leftAnimation.fromValue = -self.bounds.size.width
		self.leftAnimation.toValue = self.bounds.size.width
		self.leftAnimation.duration = self.duration
		self.leftAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
		self.leftAnimation.repeatCount = Float.infinity
		self.leftAnimation.isRemovedOnCompletion = false
		self.leftGradientLayer.add(self.leftAnimation, forKey: "leftAnimation")

		self.rightGradientLayer.colors = [clear.cgColor, color.cgColor]
		self.rightGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
		self.rightGradientLayer.endPoint = CGPoint(x: 0, y: 0)
		self.rightGradientLayer.anchorPoint = CGPoint(x: 0, y: 0)
		self.rightGradientLayer.frame = CGRect(x: bounds.size.width, y: 0, width: bounds.size.width, height: bounds.size.height)
		self.rightGradientLayer.cornerRadius = self.hasNotch ? (bounds.size.height * 0.5) : 0
		self.rightGradientLayer.masksToBounds = true

		self.rightAnimation.fromValue = self.bounds.size.width
		self.rightAnimation.toValue = -self.bounds.size.width
		self.rightAnimation.duration = self.duration
		self.rightAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
		self.rightAnimation.timeOffset = 0.5 * self.duration
		self.rightAnimation.repeatCount = Float.infinity
		self.rightAnimation.isRemovedOnCompletion = false
		self.rightGradientLayer.add(self.rightAnimation, forKey: "rightAnimation")

		self.setNeedsLayout()
		self.layoutIfNeeded()
	}

	public func stopAnimating() {
		self.animating = false
		self.leftGradientLayer.removeAllAnimations()
		self.rightGradientLayer.removeAllAnimations()
		self.setNeedsLayout()
		self.layoutIfNeeded()
	}
}
