//
//  MapView.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/20.
//

import UIKit
import MapKit

class MapView: MKMapView {
    func layoutView(from products: [Product]) {
        removeAnnotations(annotations)
        if !products.isEmpty {
            for product in products {
                let mark = MKPointAnnotation()
                mark.coordinate = CLLocationCoordinate2D(latitude: product.address.latitude,
                                                         longitude: product.address.longitude)
                mark.title = product.title
                addAnnotation(mark)
            }
        }
    }
}
