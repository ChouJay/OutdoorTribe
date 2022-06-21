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
    var myLocationManager = CLLocationManager()
    
    @IBAction func tapPositionButton(_ sender: UIButton) {
        goToUesrLocation()
    }
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        productCollectionView.register(UINib(nibName: "MapCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MapCollectionViewCell")
        productCollectionView.collectionViewLayout = createCompositionalLayout()
        productCollectionView.backgroundColor = .clear
        productCollectionView.dataSource = self
        
        myLocationManager.delegate = self
        myLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        myLocationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        ProductManager.shared.retrievePostedProduct { [weak self] postedProducts in
            self?.products = postedProducts
            print(self?.products)
            self?.mapView.layoutView(from: self!.products)
            self?.productCollectionView.reloadData()
        }
        auth()
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        item.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
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
        products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: "MapCollectionViewCell", for: indexPath) as? MapCollectionViewCell else { fatalError() }
        guard let urlString = products[indexPath.row].photoUrl.first,
              let url = URL(string: urlString) else { return item }
        item.photoImageView.kf.setImage(with: url)
        item.titleLabel.text = products[indexPath.row].title
        return item
    }
}

// MARK: - my core location delegate
extension MapViewController: CLLocationManagerDelegate {
    
}

// MARL: - mapView delegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        for (index, item) in products.enumerated() {
            if item.address.longitude == view.annotation?.coordinate.longitude || item.address.latitude == view.annotation?.coordinate.latitude {
                print(index)
                guard let coordinate = view.annotation?.coordinate else { return }
                mapView.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500), animated: true)
                productCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
            }
        }
    }
}

// MARK: - map related function
extension MapViewController {
    func auth() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
                // 取得定位服務授權
            myLocationManager.requestWhenInUseAuthorization()
                // 開始定位自身位置
                myLocationManager.startUpdatingLocation()
            }
            // 使用者已經拒絕定位自身位置權限
            else if CLLocationManager.authorizationStatus()
                        == .denied {
                // 提示可至[設定]中開啟權限
                let alertController = UIAlertController(
                  title: "定位權限已關閉",
                  message:
                  "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
                  preferredStyle: .alert)
                let okAction = UIAlertAction(
                  title: "確認", style: .default, handler:nil)
                alertController.addAction(okAction)
                self.present(
                  alertController,
                  animated: true, completion: nil)
            }
            // 使用者已經同意定位自身位置權限
            else if CLLocationManager.authorizationStatus()
                        == .authorizedWhenInUse {
                // 開始定位自身位置
                myLocationManager.startUpdatingLocation()
            }
    }
    
    func goToUesrLocation() {
        guard let myLocation = myLocationManager.location?.coordinate else { return }
        mapView.setRegion(MKCoordinateRegion(center: myLocation, latitudinalMeters: 500, longitudinalMeters: 500), animated: true)
    }
}
