//
//  MainViewController.swift
//  tochkatest
//
//  Created by Mihail Tumakov on 26/07/2019.
//  Copyright © 2019 Mihail Tumakov. All rights reserved.
//
import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    let tableView = UITableView.init(frame: .zero, style: UITableView.Style.grouped)
    let activityView = UIActivityIndicatorView(style: .gray)
    let dbOperations = DBOperations()
    let pageSize = 15
    var lastPage = 1
    var isSearching: Bool = false
    var lastRowAtPage = 0
    var tableData = [Item]()
    var searchingText: String? = nil
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var resultSearchController: UISearchController = UISearchController()
    var end = EndOfLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        dbOperations.deleteAllEntities() // Удаление записей из базы, чтобы проверить заполнение tableView из базы
        setupTableData()
        setupUI()
        setupFetchedResultsController()
        title = "News"
    }
    
    private func setupTableData() {
        reloaData()
        lastPage = Int(tableData.count / pageSize)
        fetchData()
    }
    
    private func setupFetchedResultsController() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"DbItem")
        fetchRequest.sortDescriptors = []
        fetchedResultsController =
            NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchRequest,
                                                             managedObjectContext: managedContext,
                                                             sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController!.performFetch()
            fetchedResultsController!.delegate = self
         } catch {
            print(error)
        }
    }
    
    private func setupUI() {
        view.addSubview(self.tableView)
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        updateLayout(with: self.view.frame.size)
        
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.searchBar.autocapitalizationType = .none
        resultSearchController.delegate = self
        resultSearchController.searchBar.delegate = self
        resultSearchController.dimsBackgroundDuringPresentation = false
        self.tableView.tableHeaderView = resultSearchController.searchBar
    }
    
    private func updateLayout(with size: CGSize) {
        tableView.frame = CGRect.init(origin: .zero, size: size)
    }
    
    /*:
     Обновляет массив результатов, если используется строка поиска
     @searchController - контроллер поисковой строки
     */
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            searchingText = searchController.searchBar.text
        } else {
            searchingText = nil
        }
        reloaData()
    }
    
    /*:
     Открываем ViewController с деталями новости
     @item - объект элемента ленты новостей
     */
    private func showDetails(_ item: Item) {
//        let item = Item(title: item.title,
//                        description: item.description,
//                        urlToImage: item.urlToImage,
//                        publishedAt: item.publishedAt)
        let detailView = DetailViewController(item: item)
        navigationController?.pushViewController(detailView, animated: true)
    }
    
    /*:
     Получение новостей с апи и запись их в базу
     Если параметр isOver = true - запрос не выполняется (случай, когда результаты закончились)
     */
    private func fetchData() {
        guard !end.isOver else {
            activityView.stopAnimating()
            return
        }
        sendRequest(pageSize: pageSize, page: getNextPage(), activityView: activityView)
    }
    
    /*:
     Отправляем запрос
     @pageSize - размер запрашиваемой страницы
     @page - номер запрашиваемой страницы
     */
    private func sendRequest(pageSize: Int, page: Int, activityView: UIActivityIndicatorView) {
        let apiComunication = ApiComunication(end: end)
        apiComunication.sendRequest(pageSize: pageSize, page: page, activityView: activityView)
    }
    
    // номер следующей страницы
    private func getNextPage() -> Int {
        lastPage += 1
        return lastPage
    }
}

extension MainViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        showDetails(self.tableData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.textLabel!.font = UIFont.systemFont(ofSize: 18)
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .detailButton

        let item = tableData[indexPath.row]
        cell.textLabel?.text = item.title
        lastRowAtPage = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRow = indexPath.row
        if lastRow == tableData.count - 1 {
            fetchData()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let footerView = UIView(frame: CGRect.zero)
            footerView.addSubview(activityView)
            activityView.startAnimating()
            activityView.hidesWhenStopped = true
            activityView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(
                item: activityView,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: footerView,
                attribute: .centerX,
                multiplier: 1.0,
                constant: 0.0
                ).isActive = true

            return footerView
        } else {
            return nil
        }
    }
}

extension MainViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch(type) {
        case .insert:
            reloaData()
        default:
            break
        }
    }
    
    func reloaData() {
        tableData = dbOperations.loadItems(searchText: searchingText)
        tableView.reloadData()
    }
}
