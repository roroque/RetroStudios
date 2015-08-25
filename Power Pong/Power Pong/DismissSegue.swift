//
//  DismissSegue.swift
//  Power Pong
//
//  Created by Igor Avila Amaral de Souza on 8/24/15.
//  Copyright (c) 2015 Retro Studios. All rights reserved.
//

import UIKit

@objc class DismissSegue: UIStoryboardSegue {
    
    override func perform() {
        let source = self.sourceViewController as! UIViewController
        source.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
