//
//  SearchViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/16.
//

import UIKit
import FirebaseFirestore
import Kingfisher

class SearchViewController: UIViewController {
    var products = [Product]()
    var afterFiltedProducts = [Product]()
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
    var startDatePicker = UIDatePicker()
    var endDatePicker = UIDatePicker()
    var headerView = UICollectionView(
        frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200),
        collectionViewLayout: UICollectionViewLayout())
    var pageController = UIPageControl()
    
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var mainGalleryView: UICollectionView!
    @IBAction func tapDatePicker(_ sender: UIButton) {
        dateButton.isHidden = true
        layoutChooseDateUI()
        buttonForDoingFilter.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutPageController()
        
        searchTableView.layer.cornerRadius = 15
        layOutHeaderView()
        
        searchTableView.dataSource = self
        searchTableView.delegate = self
        searchTableView.sectionHeaderTopPadding = 0
        
        searchBar.delegate = self
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        mainGalleryView.delegate = self
        mainGalleryView.dataSource = self
        mainGalleryView.collectionViewLayout = createGalleryCompositionalLayout()
        
        tabBarController?.tabBar.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ProductManager.shared.retrievePostedProduct { productsFromFireStore in
            self.products = productsFromFireStore
            self.afterFiltedProducts = productsFromFireStore
            self.searchTableView.reloadData()
        }
        navigationController?.navigationBar.isHidden = true
    }
    
// MARK: - page control related
    func layoutPageController() {
        
        pageController.addTarget(self, action: #selector(controlGallery(pageControl:)), for: .valueChanged)
        pageController.numberOfPages = 3
        pageController.currentPage = 0
        pageController.backgroundStyle = .automatic
        view.addSubview(pageController)
        pageController.translatesAutoresizingMaskIntoConstraints = false
        pageController.centerXAnchor.constraint(equalTo: mainGalleryView.centerXAnchor).isActive = true
        pageController.bottomAnchor.constraint(equalTo: searchTableView.topAnchor, constant: 0).isActive = true
    }
    
    @objc func controlGallery(pageControl: UIPageControl) {
        let page = pageControl.currentPage
        mainGalleryView.scrollToItem(at: IndexPath(item: page, section: 0), at: .centeredHorizontally, animated: true)
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
        view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        backgroundView.addSubview(buttonForDoingFilter)
        buttonForDoingFilter.addTarget(self, action: #selector(tapFilterConfirmButton), for: .touchUpInside)
        buttonForDoingFilter.backgroundColor = .green
        buttonForDoingFilter.translatesAutoresizingMaskIntoConstraints = false
        buttonForDoingFilter.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        buttonForDoingFilter.widthAnchor.constraint(equalToConstant: 40).isActive = true
        buttonForDoingFilter.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        buttonForDoingFilter.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        
        backgroundView.addSubview(buttonForStopFilter)
        buttonForStopFilter.addTarget(self, action: #selector(tapFilterStopButton), for: .touchUpInside)
        buttonForStopFilter.backgroundColor = .black
        buttonForStopFilter.translatesAutoresizingMaskIntoConstraints = false
        buttonForStopFilter.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        buttonForStopFilter.widthAnchor.constraint(equalToConstant: 40).isActive = true
        buttonForStopFilter.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        buttonForStopFilter.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
     
        let hStack = UIStackView()
        let subViews = [startDatePicker, endDatePicker]
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
        afterFiltedProducts = []
        dateButton.isHidden = false
        buttonForDoingFilter.isHidden = true
        backgroundView.removeFromSuperview()
        for subview in backgroundView.subviews {
            subview.removeFromSuperview()
        }
        
        for product in products {
            let offsetStartDate = startDatePicker.date.addingTimeInterval(28800)
            let offsetEndDate = endDatePicker.date.addingTimeInterval(28800)
            let availableSet = Set(product.availableDate)
            let filterSet = Set(daysBetweenTwoDate(startDate: offsetStartDate, endDate: offsetEndDate))
            print(availableSet)
            print(filterSet)
            if filterSet.isSubset(of: availableSet) {
                afterFiltedProducts.append(product)
            }
        }
        isFilter = true
        searchTableView.reloadData()
    }
    
    @objc func tapFilterStopButton() {
        dateButton.isHidden = false
        backgroundView.removeFromSuperview()
        for subview in backgroundView.subviews {
            subview.removeFromSuperview()
        }
        isFilter = false
        searchTableView.reloadData()
    }
}

// MARK: - table view dataSource
extension SearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        afterFiltedProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SearchTableViewCell",
            for: indexPath) as? SearchTableViewCell else { fatalError() }
        print(afterFiltedProducts.count)
        guard let urlString = afterFiltedProducts[indexPath.row].photoUrl.first else { return cell }
        cell.photoImage.kf.setImage(with: URL(string: urlString))
        cell.titleLabel.text = afterFiltedProducts[indexPath.row].title
        return cell
    }
}

// MARK: - table view delegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        80
    }
}

extension SearchViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let searchTableViewCell = sender as? SearchTableViewCell,
              let detailViewController = segue.destination as? DetailViewController,
              let indexPath = searchTableView.indexPath(for: searchTableViewCell)
        else { return }
        detailViewController.chooseProduct = products[indexPath.row]
    }
}

// MARK: - search bar delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            switch isFilter {
            case false:
                ProductManager.shared.retrievePostedProduct { [weak self] postedProducts in
                    self?.products = postedProducts
                    self?.afterFiltedProducts = postedProducts
                    self?.searchTableView.reloadData()
                }
            case true:
                ProductManager.shared.retrievePostedProduct { [weak self] postedProducts in
                    self?.products = postedProducts
                    self?.tapFilterConfirmButton()
                    self?.searchTableView.reloadData()
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyWord = searchBar.text else { return }
        switch isFilter {
        case false:
            ProductManager.shared.searchPostedProduct(keyWord: keyWord) { [weak self] postedProducts in
                self?.products = postedProducts
                self?.afterFiltedProducts = postedProducts
                self?.searchTableView.reloadData()
            }
        case true:
            ProductManager.shared.searchPostedProduct(keyWord: keyWord) { [weak self] postedProducts in
                self?.products = postedProducts
                self?.tapFilterConfirmButton()
                self?.searchTableView.reloadData()
            }
        }
    }
}

// MARK: - collection view dataSource
extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == headerView {
            return 7
        } else {
            return AdvertisingWall.shared.differentPicture.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == headerView {
            guard let item = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HeaderCollectionViewCell",
                for: indexPath) as? HeaderCollectionViewCell else { fatalError() }
            item.layOutItem(by: indexPath)
            return item
        } else {
            guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: "MainGalleryViewCell", for: indexPath) as? MainGalleryViewCell else { fatalError() }
            item.photoView.image = UIImage(named: AdvertisingWall.shared.differentPicture[indexPath.row])
            return item
        }
    }
}

// MARK: - collection view delegate
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView != mainGalleryView {
            searchBar.text = ""
            let keyWord = Classification.shared.differentOutdoorType[indexPath.row]
            switch isFilter {
            case false:
                ProductManager.shared.classifyPostedProduct(keyWord: keyWord) { [weak self ] classifyProducts in
                    self?.products = classifyProducts
                    self?.afterFiltedProducts = classifyProducts
                    self?.searchTableView.reloadData()
                }
            case true:
                ProductManager.shared.classifyPostedProduct(keyWord: keyWord) { [weak self ] classifyProducts in
                    self?.products = classifyProducts
                    self?.tapFilterConfirmButton()
                    self?.searchTableView.reloadData()
                }
            }
        }
    }
    // page control move when gallery scroll
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        print(indexPath)
        pageController.currentPage = indexPath.row

    }
}

// MARK: - classcification collection view in table view header
extension SearchViewController {
    func layOutHeaderView() {
        headerView.collectionViewLayout = createCompositionalLayout()
        headerView.dataSource = self
        headerView.delegate = self
        headerView.register(UINib(nibName: "HeaderCollectionViewCell", bundle: nil),
                            forCellWithReuseIdentifier: HeaderCollectionViewCell.reuseIdentifier)
        headerView.showsHorizontalScrollIndicator = false
        headerView.layer.cornerRadius = 15
        headerView.backgroundColor = UIColor(red: 239 / 250, green: 234 / 250, blue: 216 / 250, alpha: 1)
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(100),
            heightDimension: .absolute(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 30, trailing: 20)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(100),
            heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: - func to get every days between two date
extension SearchViewController {
    func daysBetweenTwoDate(startDate: Date, endDate: Date) -> [Date] {
        var dayInterval = [Date]()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
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

// MARk: gallery collection view layout
extension SearchViewController {
    private func createGalleryCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        section.orthogonalScrollingBehavior = .groupPaging
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}
