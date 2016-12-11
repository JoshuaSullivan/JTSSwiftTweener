//
//  JTSSwiftTweener.swift
//  JTSSwiftTweener
//
//  Created by Joshua Sullivan on 12/10/16.
//  Copyright © 2016 Josh Sullivan. All rights reserved.
//

import UIKit

public final class Tweener: Equatable {
    
    /// A closure invoked when the tween updates.
    /// The `Double` parameter is the current value of the tween. The `CFTimeInterval` parameter is the elapsed time of the tween.
    /// - Note: The `TweenProgress` closure is gauranteed to be called with the `from` value first and the `to` value of the tween immediately prior to the `TweenComplete` closure being called.
    public typealias TweenProgress = (Double, CFTimeInterval) -> Void
    
    /// A closure invoked when the tween completes or is canceled.
    /// - The `Bool` value will be `true` if the the tween completed and `false` if it was canceled.
    public typealias TweenComplete = (Bool) -> Void
    
    /// The currently active tweens.
    fileprivate static var tweens: [Tweener] = [] {
        didSet {
            if tweens.isEmpty {
                pause()
            } else {
                resume()
            }
        }
    }
    
    fileprivate static let displayLink: CADisplayLink = {
        let dl = CADisplayLink(target: Tweener.self, selector: #selector(tick(link:)))
        dl.add(to: .main, forMode: .commonModes)
        dl.isPaused = true
        return dl
    }()
    
    fileprivate static var idCounter: Int = 0
    
    fileprivate static var previousTimestamp: CFTimeInterval = 0.0
    
    /// Handle the display link tick.
    @objc fileprivate static func tick(link: CADisplayLink) {
        let dt = link.timestamp - previousTimestamp
        let tweensDidFinish = tweens.reduce(false, { return $0 || $1.tick(elapsedTime: dt) })
        if tweensDidFinish {
            tweens = tweens.filter({ !$0.isComplete })
        }
        previousTimestamp = link.timestamp
    }
    
    /// Start sending updates to the Tweener instances.
    fileprivate static func resume() {
        previousTimestamp = CACurrentMediaTime()
        displayLink.isPaused = false
    }
    
    /// Stop sending updates to Tweener instances.
    fileprivate static func pause() {
        displayLink.isPaused = true
    }
    
    
    /// Create a Tweener instance with the specified parameters.
    /// - Warning: If you keep a strong reference to the returned tweener object you could create
    ///            a retain cycle unless you're careful to only use `weak` or `unowned` self in the
    ///            progress and completion closures.
    ///
    /// - Parameters:
    ///   - duration: The duration of the tween, in seconds.
    ///   - from: The starting value of the tween.
    ///   - to: The ending value of the tween.
    ///   - progress: The closure to be invoked when the tween updates.
    ///   - completion: The optional closure to be invoked when the tween completes.
    /// - Returns: The tweener object which is useful for pausing or canceling the tween.
    @discardableResult public static func tween(duration: CFTimeInterval, from: Double = 0.0, to: Double = 1.0, easing: @escaping TweenerEasing.EasingTransform = TweenerEasing.Quadratic.easeInOut, progress: @escaping TweenProgress, completion: TweenComplete? = nil) -> Tweener {
        let tweener = Tweener(id: idCounter, duration: duration, from: from, to: to, easing: easing, progress: progress, completion: completion)
        tweens.append(tweener)
        idCounter += 1
        return tweener
    }
    
    // MARK: Instance Variables
    
    /// An internal means for uniquely identifying Tweener instance.
    fileprivate let id: Int
    
    /// The duration of the tween.
    fileprivate let duration: CFTimeInterval
    
    /// The starting value of the tween.
    fileprivate let fromValue: Double
    
    /// The ending value of the tween.
    fileprivate let toValue: Double
    
    /// The easing transform to use.
    fileprivate let easing: TweenerEasing.EasingTransform
    
    /// The progress closure for the tween.
    fileprivate let progress: TweenProgress
    
    /// The completion closure for the tween.
    fileprivate let completion: TweenComplete?
    
    /// The paused state of the tween. Setting this to true will prevent the progress closure from being called.
    /// When unpaused, the tween resumes where it left off, regardless of the elapsed time.
    public var isPaused: Bool = false
    
    fileprivate var isComplete: Bool = false
    
    /// The amount of time that has elapsed since the tween started. This value does not increase while the tween is paused.
    fileprivate(set) var elapsedTime: CFTimeInterval = 0.0
    
    // MARK: Lifecycle
    
    fileprivate init(id: Int, duration: CFTimeInterval, from: Double = 0.0, to: Double = 1.0, easing: @escaping TweenerEasing.EasingTransform, progress: @escaping TweenProgress, completion: TweenComplete? = nil) {
        self.id = id
        self.duration = duration
        self.fromValue = from
        self.toValue = to
        self.progress = progress
        self.easing = easing
        self.completion = completion
        self.progress(from, 0.0)
    }
    
    /// Cancel a tween. Calling this method will cause the completion closure to be invoked with a value of false.
    public func cancel() {
        isComplete = true
        completion?(false)
    }
    
    /// Invoked by the class to advance the tween.
    /// - Returns: `true` if the tween finished, otherwise `false`.
    fileprivate func tick(elapsedTime dt: CFTimeInterval) -> Bool {
        elapsedTime += dt
        guard elapsedTime < duration else {
            self.progress(toValue, duration)
            completion?(true)
            isComplete = true
            return true
        }
        let progress = elapsedTime / duration
        let eased = easing(progress)
        let value = (toValue - fromValue) * eased + fromValue
        self.progress(value, elapsedTime)
        return false
    }
}

public func == (t0: Tweener, t1: Tweener) -> Bool { return t0.id == t1.id }

public enum TweenerEasing {
    
    /// A closure which takes progress scalar (0.0 - 1.0) and transforms it to a different progress scalar.
    public typealias EasingTransform = (Double) -> Double
    
    public enum Linear {
        public static let easeNone: EasingTransform = {
            (progress: Double) -> Double in return progress
        }
    }
    
    public enum Quadratic {
        public static let easeIn: EasingTransform = {
            (progress: Double) -> Double in
            return progress * progress
        }
        
        public static let easeOut: EasingTransform = {
            (progress: Double) -> Double in
            return -(progress * (progress - 2.0))
        }
        
        public static let easeInOut: EasingTransform = {
            (progress: Double) -> Double in
            if (progress < 0.5) {
                return 2.0 * progress * progress;
            }
            else {
                return (-2.0 * progress * progress) + (4.0 * progress) - 1.0;
            }
        }
    }
}
