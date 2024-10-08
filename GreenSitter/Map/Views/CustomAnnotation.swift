//
//  CustomAnnotation.swift
//  GreenSitter
//
//  Created by Yungui Lee on 8/11/24.
//

import Foundation
import MapKit

class CustomAnnotationView: MKAnnotationView {
    
    static let identifier = "CustomAnnotationView"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?){
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 40, height: 50)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
    }
    
}


class CustomAnnotation: NSObject, MKAnnotation {
    let postType: PostType?
    let coordinate: CLLocationCoordinate2D
    
    init(postType: PostType?, coordinate: CLLocationCoordinate2D) {
        self.postType = postType
        self.coordinate = coordinate
        
        super.init()
    }
}
