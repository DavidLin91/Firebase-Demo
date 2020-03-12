//
//  ItemDetailController.swift
//  Firebase-Demo
//
//  Created by David Lin on 3/12/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class ItemDetailController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextField: UITextField!
    
    private var item: Item
    
    init?(coder: NSCoder, item: Item) {
        self.item = item
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    
    @IBAction func SendButtonPressed(_ sender: UIButton) {
    
    }
 
    
    
}
