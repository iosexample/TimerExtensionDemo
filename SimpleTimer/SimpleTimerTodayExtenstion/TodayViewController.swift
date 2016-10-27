//
//  TodayViewController.swift
//  SimpleTimerTodayExtenstion
//
//  Created by 王 巍 on 14-8-2.
//  Copyright (c) 2014年 OneV's Den. All rights reserved.
//

import UIKit
import NotificationCenter
import SimpleTimerKit

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var lblTimer: UILabel!
    
    var timer: SimpleTimerKit.Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.

        if let userDefaults = UserDefaults(suiteName: "group.simpleTimerSharedDefaults") {
            let leftTimeWhenQuit = userDefaults.integer(forKey: keyLeftTime)
            let quitDate = userDefaults.integer(forKey: keyQuitDate)
            
            let passedTimeFromQuit = Date().timeIntervalSince(Date(timeIntervalSince1970: TimeInterval(quitDate)))
            
            let leftTime = leftTimeWhenQuit - Int(passedTimeFromQuit)
            
            if (leftTime > 0) {
                timer = SimpleTimerKit.Timer(timeInteral: TimeInterval(leftTime))
                timer.start({
                    [weak self] leftTick in self!.updateLabel()
                    }, stopHandler: {
                        [weak self] finished in self!.showOpenAppButton()
                    })
            } else {
                showOpenAppButton()
            }
        }
    }
    
    fileprivate func updateLabel() {
        lblTimer.text = timer.leftTimeString
    }
    
    fileprivate func showOpenAppButton() {
        lblTimer.text = "Finished"
        preferredContentSize = CGSize(width: 0, height: 100)
        
        let button = UIButton(frame: CGRect(x: 0, y: 50, width: 50, height: 63))
        button.setTitle("Open", for: UIControlState())
        button.addTarget(self, action: #selector(TodayViewController.buttonPressed(_:)), for: UIControlEvents.touchUpInside)

        view.addSubview(button)
        
    }
    
    dynamic fileprivate func buttonPressed(_ sender: AnyObject!) {
        extensionContext?.open(URL(string: "simpleTimer://finished")!, completionHandler: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encoutered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
