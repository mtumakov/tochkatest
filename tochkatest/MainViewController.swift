//
//  MainViewController.swift
//  tochkatest
//
//  Created by Mihail Tumakov on 26/07/2019.
//  Copyright © 2019 Mihail Tumakov. All rights reserved.
//
import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView.init(frame: .zero, style: UITableView.Style.grouped)
    let activityView = UIActivityIndicatorView(style: .gray)
    var resultSearchController: UISearchController!
    let footerView = UIView(frame: CGRect.zero)
    let pageSize = 15
    var lastRow = 0
    var lastRowAtPage = 0
    var tableData = [Item]()
    var filteredData = [Item]()
//    var search: String? = "Lil"
//    var search = "Apple"
    var items = [NSManagedObject]()
//    var searching = true
    var pageNumber: Int = 0
    var lastPage: Int = -1
    var nextPage: Int = 0
    var totalResults: Int = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteFromStorage() // для удаление из памяти перед загрузкой
        setupUI()
        setupSearchController()
        title = "News"
        activityView.startAnimating()
        getNewItems()
    }
    
    private func setupSearchController() {
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self as? UISearchResultsUpdating
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        resultSearchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = resultSearchController.searchBar
    }
    
    private func setupUI() {
        view.addSubview(self.tableView)
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        updateLayout(with: self.view.frame.size)
    }
    
    private func updateLayout(with size: CGSize) {
        tableView.frame = CGRect.init(origin: .zero, size: size)
    }
    
    // Открываем ViewController с деталями новости
    private func showDetails(_ dbItem: NSManagedObject) {
        let url = dbItem.value(forKey: "imageLink") as? URL
        let stringUrl: String?
        if let url = url {
            stringUrl = url.relativePath
        } else {
            stringUrl = nil
        }
        let item = Item(title: dbItem.value(forKey: "title") as! String,
                        content: dbItem.value(forKey: "content") as! String,
                        imageLink: stringUrl)
        let detailView = DetailViewController(item: item)
        navigationController?.pushViewController(detailView, animated: true)
    }
    
    // асинхронное получение новостей и запись в базу
    private func fetchData() {
        let queue = DispatchQueue.global(qos: .utility)
//        queue.async {
            self.getNewItems()
            self.tableData = self.loadItems()
            print("return to async method")
            print("table data count \(self.tableData.count)")
//        }
        getCountInDb()
    }
    
    // номер следующей страницы
    private func getNextPage() -> Int {
        return Int(items.count / pageSize)
    }
    
    // запрос к апи и парсинг json
    func getNewItems() -> Void {
        nextPage = getNextPage()
        if totalResults <= items.count {
            return
        }
        let http: HTTPCommunication = HTTPCommunication(url: "https://newsapi.org/v2/", search: nil, language: "RU", pageSize: pageSize, page:  nextPage)
        print("pageSize - \(pageSize), page - \(nextPage)")
        let buildedUrl = http.buildURL()
        guard let url = URL(string: buildedUrl)    else { return }
        http.retrieveURL(url) {
            [unowned self] (data) -> Void in
            let json: String = String(data: data, encoding: String.Encoding.utf8)!
            print("JSON: ", json)
            do {
                let jsonObject: [String: Any] = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                var items = [Item]()
                self.totalResults = jsonObject["totalResults"] as! Int
                if let values = jsonObject["articles"] as? [[String: Any]] {
                    
                    for value in values {
                        guard let title = value["title"] as? String,
                            let content = value["description"] as? String,
                            let url = value["urlToImage"] as? String else {
                                break
                        }
                        let item = Item(title: title,
                                        content: content,
                                        imageLink: url)
                        items.append(item)
                    }
                    ///// старый код
//                    let itemArray = ItemArray()
//                    itemArray.addAll(array: self.loadItems())
//                    for item in items {
//                        itemArray.add(item)
//                    }
//                    self.saveItems(itemArray: itemArray.arr)
                    //// новый код

                    self.saveItems(itemArray: items)
                    
                }
                
            } catch {
                print("Can't serialize data.")
//                return false
            }
        }
        self.lastPage = self.nextPage
        self.tableView.reloadData()
    
    }
    
    // запись в базу
    func saveItems(itemArray: [Item]) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity =  NSEntityDescription.entity(forEntityName: "DbItem", in: managedContext)
        for item in itemArray {
            let dbItem = NSManagedObject(entity: entity!, insertInto: managedContext)
            dbItem.setValue(item.title, forKey: "title")
            dbItem.setValue(item.content, forKey: "content")
            if let link = item.imageLink {
                dbItem.setValue(URL(fileURLWithPath: link), forKey: "imageLink")
            }
            do {
                try managedContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
            dbItem.value(forKey: "imageLink")
            items.append(dbItem)
//            tableView.reloadData()
        }
    }
}

extension MainViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        showDetails(self.items[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.textLabel!.font = UIFont.systemFont(ofSize: 18)
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .detailButton
        print("index \(indexPath.row)")
        let item = tableData[indexPath.row]
        cell.textLabel?.text = item.title
//        let item = self.items[indexPath.row]
//        cell.textLabel?.text = item.value(forKey: "title") as? String
        lastRowAtPage = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRow = indexPath.row
        if lastRow == items.count - 1 {
            fetchData()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            footerView.addSubview(activityView)
            activityView.startAnimating()
//            if searching {
//                activityView.startAnimating()
//            } else {
//                activityView.stopAnimating()
//            }

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
