//
//  ViewController.swift
//  SimpleTimer
//
//  Created by 王 巍 on 14-8-1.
//  Copyright (c) 2014年 OneV's Den. All rights reserved.
//

import UIKit
import SimpleTimerKit

let defaultTimeInterval: TimeInterval = 10
let taskDidFinishedInWidgetNotification: String = "com.onevcat.simpleTimer.TaskDidFinishedInWidgetNotification"

class ViewController: UIViewController {
                            
    @IBOutlet weak var lblTimer: UILabel!
    
    var timer: SimpleTimerKit.Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default
            .addObserver(self, selector: #selector(ViewController.applicationWillResignActive),name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(ViewController.taskFinishedInWidget), name: NSNotification.Name(rawValue: taskDidFinishedInWidgetNotification), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func updateLabel() {
        lblTimer.text = timer.leftTimeString
    }
    
    fileprivate func showFinishAlert(finished: Bool) {
        let ac = UIAlertController(title: nil , message: finished ? "Finished" : "Stopped", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {[weak ac] action in ac!.dismiss(animated: true, completion: nil)}))
            
        present(ac, animated: true, completion: nil)
    }
    
    dynamic fileprivate func applicationWillResignActive() {
        if timer == nil {
            clearDefaults()
        } else {
            if timer.running {
                saveDefaults()
            } else {
                clearDefaults()
            }
        }
    }
    
    dynamic fileprivate func taskFinishedInWidget() {
        if let realTimer = timer {
            let (stopped, error) = realTimer.stop(false)
            if !stopped {
                if let realError = error {
                    print("error: \(realError.code)")
                }
            }
        }
    }
    
    fileprivate func saveDefaults() {
        if let userDefault = UserDefaults(suiteName: "group.simpleTimerSharedDefaults") {
            userDefault.set(Int(timer.leftTime), forKey: keyLeftTime)
            userDefault.set(Int(Date().timeIntervalSince1970), forKey: keyQuitDate)
            
            userDefault.synchronize()
        }
    }
    
    fileprivate func clearDefaults() {
        if let userDefault = UserDefaults(suiteName: "group.simpleTimerSharedDefaults") {
            userDefault.removeObject(forKey: keyLeftTime)
            userDefault.removeObject(forKey: keyQuitDate)
            
            userDefault.synchronize()
        }
    }

    @IBAction func btnStartPressed(_ sender: AnyObject) {
        if timer == nil {
            timer = SimpleTimerKit.Timer(timeInteral: defaultTimeInterval)
        }
        
        let (started, error) = timer.start({
                [weak self] leftTick in self!.updateLabel()
            }, stopHandler: {
                [weak self] finished in
                self!.showFinishAlert(finished: finished)
                self!.timer = nil
            })
        
        if started {
            updateLabel()
        } else {
            if let realError = error {
                print("error: \(realError.code)")
            }
        }
    }
    
    @IBAction func btnStopPressed(_ sender: AnyObject) {
        if let realTimer = timer {
            let (stopped, error) = realTimer.stop(true)
            if !stopped {
                if let realError = error {
                    print("error: \(realError.code)")
                }
            }
        }
    }

}

