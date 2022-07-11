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
    @IBOutlet weak var searchBarBackgroundView: UIView!
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
        dateButton.isEnabled = false
        layoutChooseDateUI()
        buttonForDoingFilter.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AccountManager.shared.getAllUserInfo { [weak self] userInfosFromServer in
            self?.allUserInfo = userInfosFromServer
        }
        
        layoutPageController()
        
        searchTableView.layer.cornerRadius = 15
        layOutHeaderView()
        
        dateButton.layer.cornerRadius = 20
        
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
        hStack.distribution = .fillProportionally
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
        dateButton.isEnabled = true
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
        print(afterFiltedAndBlockProducts.count)
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
                self?.searchBar.endEditing(true)
            }
        case true:
            ProductManager.shared.searchPostedProduct(keyWord: keyWord) { [weak self] postedProducts in
                self?.products = postedProducts
                self?.tapFilterConfirmButton()
                self?.searchTableView.reloadData()
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
        if collectionView != headerView {
            print(indexPath)
            pageController.currentPage = indexPath.row
        }
    }
}

// MARK: - classcification collection view in table view header
extension SearchViewController {
    func layOutHeaderView() {
        let decorateView = UIView()
        let secondDecorateView = UIView()
        
        view.addSubview(decorateView)
        decorateView.translatesAutoresizingMaskIntoConstraints = false
        decorateView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        decorateView.topAnchor.constraint(equalTo: searchTableView.topAnchor, constant: 80).isActive = true
        decorateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        decorateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        decorateView.backgroundColor = .black
        decorateView.layer.cornerRadius = 5
        
        decorateView.addSubview(secondDecorateView)
        secondDecorateView.translatesAutoresizingMaskIntoConstraints = false
        secondDecorateView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        secondDecorateView.topAnchor.constraint(equalTo: decorateView.topAnchor, constant: 0).isActive = true
        secondDecorateView.leadingAnchor.constraint(equalTo: decorateView.leadingAnchor, constant: 0).isActive = true
        secondDecorateView.trailingAnchor.constraint(equalTo: decorateView.trailingAnchor, constant: 0).isActive = true
        secondDecorateView.backgroundColor = .white
        
        headerView.collectionViewLayout = createCompositionalLayout()
        headerView.dataSource = self
        headerView.delegate = self
        headerView.register(UINib(nibName: "HeaderCollectionViewCell", bundle: nil),
                            forCellWithReuseIdentifier: HeaderCollectionViewCell.reuseIdentifier)
        headerView.showsHorizontalScrollIndicator = false
        headerView.layer.cornerRadius = 15
        headerView.backgroundColor = .white
        headerView.bounces = false
//        headerView.backgroundColor = .lightGray
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(85))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(100),
            heightDimension: .absolute(85))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
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
