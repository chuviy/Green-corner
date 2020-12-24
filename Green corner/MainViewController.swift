//
//  MainViewController.swift
//  Green corner
//
//  Created by Aleksey Antokhin on 08.12.2020.
//  Copyright © 2020 Aleksey Antokhin. All rights reserved.
//

import UIKit
import RealmSwift


class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
   private let searchController = UISearchController(searchResultsController: nil) // searchResultsController: nil - используем для результата тот же view
   private var places:Results<Place>! /* type:Results - автообновляемый тип контейнера, который возвращает запрашиваемые объекты. Результаты отображают текущее состояние хранилища в текущем потоке в том числе и во время записи транзакции. Объект типа Results позволяет работать с данными в реальном времени. Results - аналог массива. */
   private var filteredPlaces: Results<Place>! // коллекция для помещения отфильтрованных записей
   private var ascendingSorting = true // для сортировки по возрастанию
   private var searchBarIsEmpty: Bool { // если строка поиска пустая возвращается true
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var isFiltring: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
   // @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var revercedSortingButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self) // запрашиваем данные из БД. Инициализируем объект places. (Place.self) - self указывает имеенно на тип данных Place 
        
        // Setup the search controller
        searchController.searchResultsUpdater = self // получателем информации об изменении текста в поисковой строке будет класс MainViewController
        searchController.obscuresBackgroundDuringPresentation = false // VC с результатами поиска не позволяет взаимодействовать с отображаемым контентом
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController // интегрируем в searchController в navigationBar
        definesPresentationContext = true // отпускаем строку поиска при переходе на другой экран
    }

      // MARK: - Table view data source

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if isFiltring {
                return filteredPlaces.count
            }
            return places.isEmpty ? 0 : places.count
            }
      
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        var place = Place()
        
        if isFiltring {
            place = filteredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }
        
        cell.nameLabel?.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)

        cell.imageOfPlace?.layer.cornerRadius = cell.imageOfPlace.frame.height / 2  // 85/2 делаем круг из imageView. т.к. высота изображения =                                                                  // высоте строки, угол радиуса изображения = половине высоты                                                                  //  изображения (квадрата)
        cell.imageOfPlace?.clipsToBounds = true // обрезаем изображение по границам imageView.

          return cell
      }
    // MARK: Table View Delegete
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       
        if editingStyle == .delete {
            let place = places[indexPath.row]
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
//    /* Позволяет настраиваеть пользовательские действия swaip по ячейке справо-налево. [UIContextualAction] - массив с контекстными действиями */
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        let place = places[indexPath.row] // создаем текущий объект из массива по индексу строки, который собираемся удалить
//        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
//            StorageManager.deleteObject(place) // удаляем объект из БД
//            tableView.deleteRows(at: [indexPath], with: .automatic) // удаляем строку из таблицы
//        }
//
//        return UISwipeActionsConfiguration(actions: [deleteAction])
//    }
    
   
    
   //  MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
           // достаем из БД объект по текущему(выделенному) индексу.
            let place: Place
            if isFiltring {
                place = filteredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place // передаем объект из выбранной ячейки в NewPlaceViewController
        }
        
    }
    
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.savePlace() // сохраняем вводимые данные перед нажатием кнопки
        tableView.reloadData() // обновляем таблицу с местами
    }

//    @IBAction func sortSelection(_ sender: UISegmentedControl) {
//
//        sorting()
//    }
    
    @IBAction func reversedSorting(_ sender: Any) {
        
        ascendingSorting.toggle() // toggle() меняет значение на противоположное
        
        if ascendingSorting {
            revercedSortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            revercedSortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        sorting()
    }
    
    private func sorting() {

        if ascendingSorting {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentSearchText(searchController.searchBar.text!)
    }

    private func filterContentSearchText(_ searchText: String) {

        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText , searchText)

        tableView.reloadData()
    }
 }
