//
//  Timer.swift
//  SimpleTimer
//
//  Created by 王 巍 on 14-8-1.
//  Copyright (c) 2014年 OneV's Den. All rights reserved.
//

import UIKit

public let keyLeftTime = "com.onevcat.simpleTimer.lefttime"
public let keyQuitDate = "com.onevcat.simpleTimer.quitdate"

let timerErrorDomain = "SimpleTimerError"

public enum SimperTimerError: Int {
    case alreadyRunning = 1001
    case negativeLeftTime = 1002
    case notRunning = 1003
}

extension TimeInterval {
    func toString() -> String {
        let totalSecond = Int(self)
        let minute = totalSecond / 60
        let second = totalSecond % 60
        
        switch (minute, second) {
        case (0...9, 0...9):
            return "0\(minute):0\(second)"
        case (0...9, _):
            return "0\(minute):\(second)"
        case (_, 0...9):
            return "\(minute):0\(second)"
        default:
            return "\(minute):\(second)"
        }
    }
}

open class Timer: NSObject {
    
    open var running: Bool = false
    
    open var leftTime: TimeInterval {
    didSet {
        if leftTime < 0 {
            leftTime = 0
        }
    }
    }
    
    open var leftTimeString: String {
    get {
        return leftTime.toString()
    }
    }
    
    fileprivate var timerTickHandler: ((TimeInterval) -> ())? = nil
    fileprivate var timerStopHandler: ((Bool) ->())? = nil
    fileprivate var timer: Foundation.Timer!
    
    public init(timeInteral: TimeInterval) {
        leftTime = timeInteral
    }
    
    open func start(_ updateTick: ((TimeInterval) -> Void)?, stopHandler: ((Bool) -> Void)?) -> (start: Bool, error: NSError?) {
        if running {
            return (false, NSError(domain: timerErrorDomain, code: SimperTimerError.alreadyRunning.rawValue, userInfo:nil))
        }
        
        if leftTime < 0 {
            return (false, NSError(domain: timerErrorDomain, code: SimperTimerError.negativeLeftTime.rawValue, userInfo:nil))
        }
        
        timerTickHandler = updateTick
        timerStopHandler = stopHandler
        
        running = true
        
        timer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(Timer.countTick), userInfo: nil, repeats: true)
        
        return (true, nil)
    }
    
    open func stop(_ interrupt: Bool) -> (stopped: Bool, error: NSError?) {
        if !running {
            return (false, NSError(domain: timerErrorDomain, code: SimperTimerError.notRunning.rawValue, userInfo:nil))
        }
        
        running = false
        timer.invalidate()
        timer = nil
        
        if let stopHandler = timerStopHandler {
            stopHandler(!interrupt)
        }
        
        timerStopHandler = nil
        timerTickHandler = nil
        
        return (true, nil)
    }
    
    dynamic fileprivate func countTick() {
        leftTime = leftTime - 1
        if let tickHandler = timerTickHandler {
            tickHandler(leftTime)
        }
        if leftTime <= 0 {
            stop(false)
        }

    }
}
