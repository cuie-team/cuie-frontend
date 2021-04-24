//
//  Media.swift
//  Messenger
//
//  Created by alongkot on 24/4/2564 BE.
//

import Foundation
import MessageKit

struct Media: MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
}
