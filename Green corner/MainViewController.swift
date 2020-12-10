//
//  MainViewController.swift
//  Green corner
//
//  Created by Aleksey Antokhin on 08.12.2020.
//  Copyright © 2020 Aleksey Antokhin. All rights reserved.
//

import UIKit
import RealmSwift


class MainViewController: UITableViewController {
    
    var places:Results<Place>! /* type:Results - автообновляемый тип контейнера, который возвращает запрашиваемые объекты. Результаты отображают текущее состояние хранилища в текущем потоке в том числе и во время записи транзакции. Объект типа Results позволяет работать с данными в реальном времени. Results - аналог массива. */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self) // запрашиваем данные из БД. Инициализируем объект places. (Place.self) - self указывает имеенно на тип данных Place 

    }

      // MARK: - Table view data source

      override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
            }
      
      override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = places[indexPath.row]

        cell.nameLabel?.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)

       

        cell.imageOfPlace?.layer.cornerRadius = cell.imageOfPlace.frame.height / 2  // 85/2 делаем круг из imageView. т.к. высота изображения =                                                                  // высоте строки, угол радиуса изображения = половине высоты                                                                  //  изображения (квадрата)
        cell.imageOfPlace?.clipsToBounds = true // обрезаем изображение по границам imageView.



          return cell
      }
    // MARK: Table View Delegete
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       
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
            let place = places[indexPath.row] // достаем из БД объект по текущему(выделенному) индексу.
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place // передаем объект из выбранной ячейки в NewPlaceViewController
        }
        
    }
    
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.savePlace() // сохраняем вводимые данные перед нажатием кнопки
        tableView.reloadData() // обновляем таблицу с местами
    }

}
