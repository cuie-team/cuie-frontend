//
//  PhotoViewerController.swift
//  Messenger
//
//  Created by alongkot on 24/4/2564 BE.
//

import UIKit

class PhotoViewerController: UIViewController {
    
    private let image = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        image.image = UIImage(named: "avatar")
        navigationItem.largeTitleDisplayMode = .never
        view.addSubview(image)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        image.frame = view.bounds
    }
}
