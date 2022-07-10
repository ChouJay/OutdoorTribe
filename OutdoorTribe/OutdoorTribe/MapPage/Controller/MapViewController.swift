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
import FirebaseAuth

class MapViewController: UIViewController {
    
    var allCell = [MapCollectionViewCell]()
    var allUserInfo = [Account]()
    var blockUsers = [Account]()
    var currentIndex: Int?
    var products = [Product]()
    var afterFiltedProducts = [Product]()
    var afterFiltedAndBlockProducts = [Product]()
    var myLocationManager = CLLocationManager()
    var isFilter = false {
        didSet {
            switch isFilter {
            case false:
                afterFiltedProducts = products
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
    
    @IBOutlet weak var positionButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MapView!
    
    @IBAction func tapDatePicker(_ sender: Any) {
        dateButton.isEnabled = false
        layoutChooseDateUI()
        buttonForDoingFilter.isHidden = false
    }
    @IBAction func tapPositionButton(_ sender: UIButton) {
        goToUesrLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AccountManager.shared.getAllUserInfo { [weak self] userInfosFromServer in
            self?.allUserInfo = userInfosFromServer
        }
        
        positionButton.layer.cornerRadius = 25
        
        productCollectionView.register(UINib(nibName: "MapCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "MapCollectionViewCell")
        productCollectionView.collectionViewLayout = createCompositionalLayout()
        productCollectionView.backgroundColor = .clear
        productCollectionView.dataSource = self
        productCollectionView.delegate = self
        
        myLocationManager.delegate = self
        myLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        myLocationManager.requestWhenInUseAuthorization()
        myLocationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        dateButton.layer.cornerRadius = 18
        
        searchBar.delegate = self
        searchBar.layer.cornerRadius = 10
        searchBar.clipsToBounds = true
        searchBar.searchTextField.layer.cornerRadius = 18
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.clipsToBounds = true
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.removeOverlays(mapView.overlays)
        navigationController?.navigationBar.isHidden = true
        ProductManager.shared.retrievePostedProduct { [weak self] postedProducts in
            self?.products = postedProducts
            self?.afterFiltedProducts = postedProducts
    
            self?.mapView.layoutView(from: self!.afterFiltedProducts)
            self?.productCollectionView.reloadData()
        }
        productCollectionView.isHidden = true
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        AccountManager.shared.loadUserBlockList(byUserID: currentUserID) { [weak self] accounts in
            self?.blockUsers = accounts
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        goToUesrLocation()
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
        
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, _, _ in
            self?.currentIndex = visibleItems.last?.indexPath.row
            guard let collectionViewIsHidden = self?.productCollectionView.isHidden else { return }
            if collectionViewIsHidden {
                return
            }
            print(self?.currentIndex)  //會跑很多次 看要不要改成flowlayout就可以用collectionView delegate method
            guard let currentIndex = self?.currentIndex else { return }
            let coordinate = CLLocationCoordinate2D(
                latitude: self?.afterFiltedProducts[currentIndex].address.latitude ?? 0,
                longitude: self?.afterFiltedProducts[currentIndex].address.longitude ?? 0)
            self?.mapView.setRegion(
                MKCoordinateRegion(center: coordinate, latitudinalMeters: 700, longitudinalMeters: 700),
                animated: true)
        }
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func layOutSearchBar() {
    }
}

// MARK: - collection view dataSource
extension MapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        afterFiltedAndBlockProducts = []
        if blockUsers.count == 0 {
            afterFiltedAndBlockProducts = afterFiltedProducts
            
        } else {
            for product in afterFiltedProducts {
                for blockUser in blockUsers {
                    if product.renterUid != blockUser.userID {
                        afterFiltedAndBlockProducts.append(product)
                    }
                }
            }
        }
        return afterFiltedAndBlockProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MapCollectionViewCell",
            for: indexPath) as? MapCollectionViewCell else { fatalError() }
        item.hideEstimateTimeLabel()
        item.routeDelegae = self
        guard let urlString = afterFiltedAndBlockProducts[indexPath.row].photoUrl.first,
              let url = URL(string: urlString) else { return item }
        item.photoImageView.kf.setImage(with: url)
        item.titleLabel.text = afterFiltedAndBlockProducts[indexPath.row].title
        item.renterNameLabel.text = afterFiltedAndBlockProducts[indexPath.row].renter
        for userInfo in allUserInfo where afterFiltedAndBlockProducts[indexPath.row].renter == userInfo.name {
            let totalScore = userInfo.totalScore
            let ratingCount = userInfo.ratingCount
            if ratingCount != 0 {
                let score = totalScore / ratingCount
                item.scoreLabel.text = String(score) + "(\(String(Int(ratingCount))))"
            } else {
                item.scoreLabel.text = "no rating"
            }
        }
        return item
    }
}

// MARK: - collection view delegate
extension MapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "mapToDetailSegue", sender: indexPath)
    }
 
}
// MARK: - my core location delegate
extension MapViewController: CLLocationManagerDelegate {
    
}

// MARK: - mapView delegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        productCollectionView.isHidden = false
        mapView.removeOverlays(mapView.overlays)
        for (index, item) in afterFiltedProducts.enumerated() {
            if item.address.longitude == view.annotation?.coordinate.longitude ||
                item.address.latitude == view.annotation?.coordinate.latitude {

                productCollectionView.selectItem(
                    at: IndexPath(item: index, section: 0),
                    animated: true,
                    scrollPosition: .centeredHorizontally)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 44 / 250, green: 54 / 250, blue: 57 / 250, alpha: 1)
        renderer.lineWidth = 5.0
        return renderer
    }
}

// MARK: - map related function
extension MapViewController {
    func goToUesrLocation() {
        guard let myLocation = myLocationManager.location?.coordinate else { return }
        mapView.setRegion(MKCoordinateRegion(center: myLocation,
                                             latitudinalMeters: 1000,
                                             longitudinalMeters: 1000), animated: true)
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
                    self?.afterFiltedProducts = postedProducts
                    self?.mapView.layoutView(from: self!.afterFiltedProducts)
                    self?.productCollectionView.reloadData()
                }
            case true:
                ProductManager.shared.retrievePostedProduct { [weak self] postedProducts in
                    self?.products = postedProducts
                    self?.afterFiltedProducts = postedProducts
                    self?.tapFilterConfirmButton()
                    self?.mapView.layoutView(from: self!.afterFiltedProducts)
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
                self?.afterFiltedProducts = postedProducts
                self?.mapView.layoutView(from: self!.afterFiltedProducts)
                self?.productCollectionView.reloadData()
            }
        case true:
            guard let keyWord = searchBar.text else { return }
            ProductManager.shared.searchPostedProduct(keyWord: keyWord) { [weak self] postedProducts in
                self?.products = postedProducts
                self?.afterFiltedProducts = postedProducts
                self?.tapFilterConfirmButton()
                self?.mapView.layoutView(from: self!.afterFiltedProducts)
                self?.productCollectionView.reloadData()
            }
        }
        searchBar.resignFirstResponder()
        productCollectionView.isHidden = false
    }
    
// MARK: - date picker function
    func layoutChooseDateUI() {
        
        startDatePicker.datePickerMode = .date
        startDatePicker.preferredDatePickerStyle = .compact
        startDatePicker.timeZone = .current

        endDatePicker.datePickerMode = .date
        endDatePicker.preferredDatePickerStyle = .compact
        endDatePicker.timeZone = .current
        
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = 10
        print(dateButton.frame)
        view.addSubview(backgroundView)
        backgroundView.frame = CGRect(
            x: dateButton.frame.origin.x + dateButton.frame.width,
            y: dateButton.frame.origin.y + dateButton.frame.height + 10,
            width: 0,
            height: 40)
        print(backgroundView.frame)
        backgroundView.alpha = 0
//        backgroundView.translatesAutoresizingMaskIntoConstraints = false
//        backgroundView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
//        backgroundView.widthAnchor.constraint(equalToConstant: 230).isActive = true
//        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
//        backgroundView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        backgroundView.addSubview(buttonForDoingFilter)
        buttonForDoingFilter.addTarget(self, action: #selector(tapFilterConfirmButton), for: .touchUpInside)
        buttonForDoingFilter.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        buttonForDoingFilter.tintColor = .darkGray
        buttonForDoingFilter.translatesAutoresizingMaskIntoConstraints = false
        buttonForDoingFilter.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        buttonForDoingFilter.widthAnchor.constraint(equalToConstant: 40).isActive = true
        buttonForDoingFilter.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        buttonForDoingFilter.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        
        backgroundView.addSubview(buttonForStopFilter)
        buttonForStopFilter.addTarget(self, action: #selector(tapFilterStopButton), for: .touchUpInside)
        buttonForStopFilter.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        buttonForStopFilter.tintColor = .darkGray
        buttonForStopFilter.translatesAutoresizingMaskIntoConstraints = false
        buttonForStopFilter.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        buttonForStopFilter.widthAnchor.constraint(equalToConstant: 40).isActive = true
        buttonForStopFilter.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        buttonForStopFilter.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        
        let dashLabel = UILabel()
        dashLabel.text = "-"
        dashLabel.textAlignment = .center
        
        let hStack = UIStackView()
        let subViews = [startDatePicker, dashLabel, endDatePicker]
        for subView in subViews {
            hStack.addArrangedSubview(subView)
        }
        hStack.axis = .horizontal
        hStack.distribution = .fill
        backgroundView.addSubview(hStack)
        
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        hStack.leadingAnchor.constraint(equalTo: buttonForStopFilter.trailingAnchor).isActive = true
        hStack.trailingAnchor.constraint(equalTo: buttonForDoingFilter.leadingAnchor).isActive = true
        hStack.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.backgroundView.frame = CGRect(
                x: self.dateButton.frame.origin.x + self.dateButton.frame.width - 230,
                y: self.dateButton.frame.origin.y + self.dateButton.frame.height + 10,
                width: 230,
                height: 40)
            self.backgroundView.alpha = 1
        }, completion: nil)
    }
    
    @objc func tapFilterConfirmButton() {
        afterFiltedProducts = []
        dateButton.isEnabled = true
        buttonForDoingFilter.isHidden = true
        backgroundView.removeFromSuperview()
        for subview in backgroundView.subviews {
            subview.removeFromSuperview()
        }
        
        for product in products {
            let availableSet = Set(product.availableDate)
            let filterSet = Set(daysBetweenTwoDate(startDate: startDatePicker.date, endDate: endDatePicker.date))
            if filterSet.isSubset(of: availableSet) {
                afterFiltedProducts.append(product)
            }
        }
        isFilter = true
        mapView.layoutView(from: afterFiltedProducts)
        productCollectionView.reloadData()
    }
    
    @objc func tapFilterStopButton() {
        dateButton.isEnabled = true
        backgroundView.removeFromSuperview()
        for subview in backgroundView.subviews {
            subview.removeFromSuperview()
        }
        isFilter = false
        mapView.layoutView(from: afterFiltedProducts)
        productCollectionView.reloadData()
    }
}

// MARK: - func to get every days between two date
extension MapViewController {
    func daysBetweenTwoDate(startDate: Date, endDate: Date) -> [Date] {
        var dayInterval = [Date]()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        print(startDate)
        print(endDate)
        guard startDate <= endDate else { return dayInterval }
        guard let standardStartDate = calendar.date(
                bySettingHour: 0,
                minute: 0,
                second: 0,
                of: startDate),
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
    func showRoute(sender: MapCollectionViewCell) {
        mapView.removeOverlays(mapView.overlays)
        let buttonPosition = sender.convert(sender.bounds.origin, to: productCollectionView)
        guard let indexPath = productCollectionView.indexPathForItem(at: buttonPosition) else { return }
        
        guard let sourceLocation = myLocationManager.location?.coordinate else { return }
        let destinationLocation = CLLocationCoordinate2D(
            latitude: afterFiltedProducts[indexPath.row].address.latitude,
            longitude: afterFiltedProducts[indexPath.row].address.longitude)
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }
            if error == nil {
                guard let directionResponse = response else { return }
                
                let route = directionResponse.routes[0]
                print("estimate: \(route.expectedTravelTime)")
                let estimateTime = route.expectedTravelTime
                let routeTime = Int(round(estimateTime / 60))
                
                sender.timeStackView.isHidden = false
                sender.estimatedTimeLabel.text = String(routeTime) + " min"
                
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

// MARK: prepare for segue
extension MapViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = sender as? IndexPath,
              let detailViewController = segue.destination as? DetailViewController else { return }
        
        detailViewController.chooseProduct = products[indexPath.row]
    }
}
