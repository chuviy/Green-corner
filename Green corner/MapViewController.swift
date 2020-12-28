//
//  MapViewController.swift
//  Green corner
//
//  Created by Aleksey Antokhin on 28.12.2020.
//  Copyright © 2020 Aleksey Antokhin. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func closeVC() {
        // закрываем VC и выгружаем из памяти
        dismiss(animated: true)
    }
    
}
