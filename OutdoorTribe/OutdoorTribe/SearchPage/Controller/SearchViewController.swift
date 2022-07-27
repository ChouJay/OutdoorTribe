//
//  SearchViewController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/16.
//

import UIKit
import FirebaseFirestore
import Kingfisher
import FirebaseAuth
import IQKeyboardManagerSwift

class SearchViewController: UIViewController {
    
    let maskView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: UIScreen.main.bounds.width,
                                        height: UIScreen.main.bounds.height))
    var childVC: CalendarFilterViewController?
    var products = [Product]()
    var afterFiltedProducts = [Product]()
    var afterFiltedAndBlockProducts = [Product]()
    var allUserInfo = [Account]()
    var blockUsers = [Account]()
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
    var headerView = UICollectionView(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: UIScreen.main.bounds.width,
                                                    height: 200),
                                      collectionViewLayout: UICollectionViewLayout())
    var pageController = UIPageControl()
    var startDate = Date()
    var endDate = Date()
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd")
        return dateFormatter
    }()
    
    @IBOutlet weak var searchBarBackgroundView: UIView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var mainGalleryView: UICollectionView!
    @IBAction func tapDatePicker(_ sender: UIButton) {
        dateButton.isEnabled = false
        childVC = CalendarFilterViewController(todayDate: Date())
        guard let childVC = childVC else { return }
        childVC.filterDelegate = self
        maskView.backgroundColor = .black.withAlphaComponent(0)
        view.addSubview(maskView)
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.view.frame = CGRect(x: dateButton.frame.maxX, y: dateButton.frame.maxY + 10, width: 0, height: 0)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            childVC.view.frame = CGRect(x: self.dateButton.frame.maxX,
                                        y: self.dateButton.frame.maxY + 10,
                                        width: -315,
                                        height: 415)
            self.maskView.backgroundColor = .black.withAlphaComponent(0.5)
            self.view.layoutIfNeeded()
        }, completion: nil)
        childVC.didMove(toParent: self)
    }
    
    @objc func removeChildView() {
        guard let childVc = childVC else { return }
        print("remove subview")
        UIView.animate(withDuration: 0.2) {
            childVc.view.frame = CGRect(x: self.dateButton.frame.maxX,
                                        y: self.dateButton.frame.maxY + 10,
                                        width: 0,
                                        height: 0)
            self.maskView.backgroundColor = .black.withAlphaComponent(0)
            self.view.layoutIfNeeded()
        } completion: { _ in
            childVc.removeFromParent()
            childVc.view.removeFromSuperview()
            self.maskView.removeFromSuperview()
            childVc.didMove(toParent: nil)
            self.childVC = nil
            self.dateButton.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AccountManager.shared.getAllUserInfo { [weak self] userInfosFromServer in
            self?.allUserInfo = userInfosFromServer
        }
        
        layoutPageController()
        layOutHeaderView()
        
        dateButton.layer.cornerRadius = 20
        
        searchTableView.layer.cornerRadius = 15
        searchTableView.dataSource = self
        searchTableView.delegate = self
        searchTableView.sectionHeaderTopPadding = 0
        
        searchBar.delegate = self
        searchBar.searchTextField.layer.cornerRadius = 18
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.clipsToBounds = true
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
        searchTableView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: UIScreen.main.bounds.height * 1 / 3).isActive = true
        
        navigationController?.navigationBar.isHidden = true
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        AccountManager.shared.loadUserBlockList(byUserID: currentUserID) { [weak self] accounts in
            self?.blockUsers = accounts
            self?.searchTableView.reloadData()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view != childVC?.view {
            removeChildView()
            tapFilterStopButton()
        }
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
    @objc func tapFilterConfirmButton() {
        afterFiltedProducts = []
        let offsetStartDate = startDate.addingTimeInterval(28800)
        let offsetEndDate = endDate.addingTimeInterval(28800)
        let filterSet = Set(daysBetweenTwoDate(startDate: offsetStartDate, endDate: offsetEndDate))
        for product in products {
            var availableDateStrings = [String]()
            for date in product.availableDate {
                let dateString = dateFormatter.string(from: date)
                availableDateStrings.append(dateString)
            }
            let availableSet = Set(availableDateStrings)
            if filterSet.isSubset(of: availableSet) {
                afterFiltedProducts.append(product)
            }
        }
        isFilter = true
        searchTableView.reloadData()
    }
    
    @objc func tapFilterStopButton() {
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
        afterFiltedAndBlockProducts = []
        if blockUsers.count == 0 {
            afterFiltedAndBlockProducts = afterFiltedProducts
        } else {
            for product in afterFiltedProducts {
                for blockUser in blockUsers where product.renterUid != blockUser.userID {
                    afterFiltedAndBlockProducts.append(product)
                }
            }
        }
        return afterFiltedAndBlockProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SearchTableViewCell",
            for: indexPath) as? SearchTableViewCell else { fatalError() }
        guard let urlString = afterFiltedAndBlockProducts[indexPath.row].photoUrl.first else { return cell }
        cell.photoImage.kf.setImage(with: URL(string: urlString))
        cell.titleLabel.text = afterFiltedAndBlockProducts[indexPath.row].title
        cell.renterNameLabel.text = afterFiltedAndBlockProducts[indexPath.row].renter
        cell.addressLabel.text = afterFiltedAndBlockProducts[indexPath.row].addressString
        for userInfo in allUserInfo where afterFiltedAndBlockProducts[indexPath.row].renter == userInfo.name {
            let totalScore = userInfo.totalScore
            let ratingCount = userInfo.ratingCount
            if ratingCount != 0 {
                let score = totalScore / ratingCount
                cell.scoreLabel.text = String(format: "%.1f", score) + "(\(String(Int(ratingCount))))"
            } else {
                cell.scoreLabel.text = "no rating"
            }
        }
        return cell
    }
}

// MARK: - table view delegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        85
    }
}

extension SearchViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let searchTableViewCell = sender as? SearchTableViewCell,
              let detailViewController = segue.destination as? DetailViewController,
              let indexPath = searchTableView.indexPath(for: searchTableViewCell) else { return }
        detailViewController.chooseProduct = afterFiltedProducts[indexPath.row]
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
                self?.searchBar.endEditing(true)
            }
        case true:
            ProductManager.shared.searchPostedProduct(keyWord: keyWord) { [weak self] postedProducts in
                self?.products = postedProducts
                self?.tapFilterConfirmButton()
                self?.searchBar.endEditing(true)
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
            guard let item = collectionView.dequeueReusableCell(
                withReuseIdentifier: "MainGalleryViewCell",
                for: indexPath) as? MainGalleryViewCell else { fatalError() }
            item.photoView.image = UIImage(named: AdvertisingWall.shared.differentPicture[indexPath.row])
            return item
        }
    }
}

// MARK: - collection view delegate
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView != mainGalleryView {
            guard let cell = headerView.cellForItem(at: indexPath) as? HeaderCollectionViewCell else { return }
            cell.selectedState = !cell.selectedState
            if cell.selectedState {
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
                    }
                }
            } else {
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
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = headerView.cellForItem(at: indexPath) as? HeaderCollectionViewCell else { return }
        print(indexPath)
        cell.selectedState = false
    }
    
    // page control move when gallery scroll
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if collectionView != headerView {
            pageController.currentPage = indexPath.row
        }
    }
}

// MARK: - classcification collection view in table view header
extension SearchViewController {
    func layOutHeaderView() {
        let decorateView = UIView()
        
        view.addSubview(decorateView)
        decorateView.translatesAutoresizingMaskIntoConstraints = false
        decorateView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        decorateView.topAnchor.constraint(equalTo: searchTableView.topAnchor, constant: 85).isActive = true
        decorateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        decorateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        decorateView.backgroundColor = UIColor.OutdoorTribeColor.mainColor
        decorateView.layer.cornerRadius = 5
        decorateView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                
        headerView.collectionViewLayout = createCompositionalLayout()
        headerView.dataSource = self
        headerView.delegate = self
        headerView.register(UINib(nibName: "HeaderCollectionViewCell", bundle: nil),
                            forCellWithReuseIdentifier: HeaderCollectionViewCell.reuseIdentifier)
        headerView.showsHorizontalScrollIndicator = false
        headerView.layer.cornerRadius = 15
        headerView.backgroundColor = .white
        headerView.bounces = false
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(85),
            heightDimension: .absolute(85))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: - func to get every days between two date
extension SearchViewController {
    func daysBetweenTwoDate(startDate: Date, endDate: Date) -> [String] {
        var dateStringArray = [String]()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        guard startDate <= endDate else { return dateStringArray }
        guard let standardStartDate = calendar.date(
                bySettingHour: 0,
                minute: 0,
                second: 0,
                of: startDate),
              let standardEndDate = calendar.date(
                bySettingHour: 0,
                minute: 0,
                second: 0,
                of: endDate) else { return dateStringArray }
        let component = calendar.dateComponents([.day], from: standardStartDate, to: standardEndDate)
        guard let days = component.day else { return dateStringArray }
        for round in 0...days {
            guard let dateBeAdded = calendar.date(
                byAdding: .day,
                value: round,
                to: standardStartDate) else { return dateStringArray }
            let dateString = dateFormatter.string(from: dateBeAdded)
            dateStringArray.append(dateString)
        }
        return dateStringArray
    }
}

// MARK: - gallery collection view layout
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

// MARK: - date filter delegate
extension SearchViewController: AskVcToFilterByDateDelegate {
    func askVcToStartFilter(dateRange: [Date]) {
        removeChildView()
        guard let startDateOfRange = dateRange.first,
              let endDateOfRnage = dateRange.last else { return }
        startDate = startDateOfRange
        endDate = endDateOfRnage
        tapFilterConfirmButton()
    }
}
