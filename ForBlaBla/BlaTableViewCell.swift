//
//  BlaTableViewCell.swift
//  ForBlaBla
//
//  Created by Bing on 2019/10/26.
//  Copyright © 2019 Bing. All rights reserved.
//

import UIKit

class BlaTableViewCell: UITableViewCell {

    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var issueTitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
