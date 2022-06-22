//
//  MapViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/17.
//

import UIKit
import MapKit
import CoreLocation
import Kingfisher

class MapViewController: UIViewController {

    var products = [Product]()
    var filterProducts = [Product]()
    var myLocationManager = CLLocationManager()
    var isFilter = false {
        didSet {
            switch isFilter {
            case false:
                filterProducts = products
            case true:
                return
            }
        }
    }
    var buttonForDoingFilter = UIButton()
    var buttonForStopFilter = UIButton()
    var backgroundView = UIView()
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MapView!
    
    @IBAction func tapDatePicker(_ sender: Any) {
        dateButton.isHidden = true
        layoutChooseDateUI()
        buttonForDoingFilter.isHidden = false
    }
    @IBAction func tapPositionButton(_ sender: UIButton) {
        goToUesrLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productCollectionView.register(UINib(nibName: "MapCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MapCollectionViewCell")
        productCollectionView.collectionViewLayout = createCompositionalLayout()
        productCollectionView.backgroundColor = .clear
        productCollectionView.dataSource = self
        
        myLocationManager.delegate = self
        myLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        myLocationManager.requestWhenInUseAuthorization()
        myLocationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        ProductManager.shared.retrievePostedProduct { [weak self] postedProducts in
            self?.products = postedProducts
            self?.filterProducts = postedProducts
            self?.mapView.layoutView(from: self!.filterProducts)
            self?.productCollectionView.reloadData()
        }
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: - collection view dataSource
extension MapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filterProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: "MapCollectionViewCell", for: indexPath) as? MapCollectionViewCell else { fatalError() }
        item.routeDelegae = self
        guard let urlString = filterProducts[indexPath.row].photoUrl.first,
              let url = URL(string: urlString) else { return item }
        item.photoImageView.kf.setImage(with: url)
        item.titleLabel.text = filterProducts[indexPath.row].title
        return item
    }
}

// MARK: - my core location delegate
extension MapViewController: CLLocationManagerDelegate {
    
}

// MARK: - mapView delegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.removeOverlays(mapView.overlays)
        for (index, item) in filterProducts.enumerated() {
            print(index)
            if item.address.longitude == view.annotation?.coordinate.longitude || item.address.latitude == view.annotation?.coordinate.latitude {
                print(index)
                guard let coordinate = view.annotation?.coordinate else { return }
                mapView.setRegion(
                    MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500),
                    animated: true)
                productCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.brown
        renderer.lineWidth = 5.0
        return renderer
    }
}

// MARK: - map related function
extension MapViewController {
    func goToUesrLocation() {
        guard let myLocation = myLocationManager.location?.coordinate else { return }
        mapView.setRegion(MKCoordinateRegion(center: myLocation, latitudinalMeters: 500, longitudinalMeters: 500), animated: true)
    }
}

// MARK: - search bar delegate
extension MapViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            switch isFilter {
            case false:
                ProductManager.shared.retrievePostedProduct { [weak self] postedProducts in
                    self?.products = postedProducts
                    self?.filterProducts = postedProducts
                    print(self?.products)
                    self?.mapView.layoutView(from: self!.filterProducts)
                    self?.productCollectionView.reloadData()
                }
            case true:
                ProductManager.shared.retrievePostedProduct { [weak self] postedProducts in
                    self?.products = postedProducts
                    self?.filterProducts = postedProducts
                    self?.tapFilterConfirmButton()
                    print(self?.products)
                    self?.mapView.layoutView(from: self!.filterProducts)
                    self?.productCollectionView.reloadData()
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        switch isFilter {
        case false:
            guard let keyWord = searchBar.text else { return }
            ProductManager.shared.searchPostedProduct(keyWord: keyWord) { [weak self] postedProducts in
                self?.products = postedProducts
                self?.filterProducts = postedProducts
                print(self?.products)
                self?.mapView.layoutView(from: self!.filterProducts)
                self?.productCollectionView.reloadData()
            }
        case true:
            guard let keyWord = searchBar.text else { return }
            ProductManager.shared.searchPostedProduct(keyWord: keyWord) { [weak self] postedProducts in
                self?.products = postedProducts
                self?.filterProducts = postedProducts
                self?.tapFilterConfirmButton()
                print(self?.products)
                self?.mapView.layoutView(from: self!.filterProducts)
                self?.productCollectionView.reloadData()
            }
        }
        searchBar.resignFirstResponder()
    }
    
// MARK: - date picker function
    func layoutChooseDateUI() {
        startDatePicker.datePickerMode = .date
        startDatePicker.preferredDatePickerStyle = .compact
        
        endDatePicker.datePickerMode = .date
        endDatePicker.preferredDatePickerStyle = .compact
        
        backgroundView.backgroundColor = .white
        mapView.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        buttonForDoingFilter.addTarget(self, action: #selector(tapFilterConfirmButton), for: .touchUpInside)
        backgroundView.addSubview(buttonForDoingFilter)
        buttonForDoingFilter.translatesAutoresizingMaskIntoConstraints = false
        buttonForDoingFilter.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        buttonForDoingFilter.widthAnchor.constraint(equalToConstant: 40).isActive = true
        buttonForDoingFilter.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        buttonForDoingFilter.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        
        buttonForStopFilter.addTarget(self, action: #selector(tapFilterStopButton), for: .touchUpInside)
        backgroundView.addSubview(buttonForStopFilter)
        buttonForStopFilter.translatesAutoresizingMaskIntoConstraints = false
        buttonForStopFilter.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        buttonForStopFilter.widthAnchor.constraint(equalToConstant: 40).isActive = true
        buttonForStopFilter.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        buttonForStopFilter.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true

        
        var hStack = UIStackView()
        var subViews = [startDatePicker, endDatePicker]
        for subView in subViews {
            hStack.addArrangedSubview(subView)
        }
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        backgroundView.addSubview(hStack)
        
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        hStack.leadingAnchor.constraint(equalTo: buttonForStopFilter.trailingAnchor).isActive = true
        hStack.trailingAnchor.constraint(equalTo: buttonForDoingFilter.leadingAnchor).isActive = true
        hStack.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
    }
    
    @objc func tapFilterConfirmButton() {
        filterProducts = []
        dateButton.isHidden = false
        buttonForDoingFilter.isHidden = true
        backgroundView.removeFromSuperview()
        for subview in backgroundView.subviews {
            subview.removeFromSuperview()
        }
        
        for product in products {
            let availableSet = Set(product.availableDate)
            let filterSet = Set(daysBetweenTwoDate(startDate: startDatePicker.date, endDate: endDatePicker.date))
            print(availableSet)
            print(filterSet)
            if filterSet.isSubset(of: availableSet) {
                filterProducts.append(product)
            }
        }
        isFilter = true
        mapView.layoutView(from: filterProducts)
        productCollectionView.reloadData()
    }
    
    @objc func tapFilterStopButton() {
        dateButton.isHidden = false
        backgroundView.removeFromSuperview()
        for subview in backgroundView.subviews {
            subview.removeFromSuperview()
        }
        isFilter = false
        mapView.layoutView(from: filterProducts)
        productCollectionView.reloadData()
    }
}

// MARK: - func to get every days between two date
extension MapViewController {
    func daysBetweenTwoDate(startDate: Date, endDate: Date) -> [Date] {
        var dayInterval = [Date]()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        guard startDate <= endDate else { return dayInterval }
        guard let standardStartDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: startDate),
              let standardEndDate = calendar.date(
                bySettingHour: 0,
                minute: 0,
                second: 0,
                of: endDate) else { return dayInterval }
        let component = calendar.dateComponents([.day], from: standardStartDate, to: standardEndDate)
        guard let days = component.day else { return dayInterval }
        for round in 0...days {
            guard let dateBeAdded = calendar.date(
                byAdding: .day,
                value: round,
                to: standardStartDate) else { return dayInterval }
            dayInterval.append(dateBeAdded)
        }
        return dayInterval
    }
}

// MARK: - route function delegate
extension MapViewController: MapRouteDelegate {
    func showRoute(sender: UIButton) {
        mapView.removeOverlays(mapView.overlays)
        let buttonPosition = sender.convert(sender.bounds.origin, to: productCollectionView)
        guard let indexPath = productCollectionView.indexPathForItem(at: buttonPosition) else { return }
        
        guard let sourceLocation = myLocationManager.location?.coordinate else { return }
        let destinationLocation = CLLocationCoordinate2D(
            latitude: filterProducts[indexPath.row].address.latitude,
            longitude: filterProducts[indexPath.row].address.longitude)
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { response, error in
            if error == nil {
                guard let directionResponse = response else { return }
                
                let route = directionResponse.routes[0]
                print("estimate: \(route.expectedTravelTime)")
                self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                let rect = route.polyline.boundingMapRect
                self.mapView.setRegion(MKCoordinateRegion(rect.insetBy(dx: -800, dy: -2200)), animated: true)
            } else {
                guard let error = error else { return }
                print("get error: \(error)")
            }
        }
    }
}
