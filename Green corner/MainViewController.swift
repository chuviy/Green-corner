//
//  MainViewController.swift
//  Green corner
//
//  Created by Aleksey Antokhin on 08.12.2020.
//  Copyright © 2020 Aleksey Antokhin. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    var places = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

      // MARK: - Table view data source

      override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return places.count
            }
      
      override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = places[indexPath.row]
        
        cell.nameLabel?.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
       
       
        if place.image == nil {
             cell.imageOfPlace?.image = UIImage(named: place.stringPlacesImage!)
        } else {
            cell.imageOfPlace.image = place.image
        }
        
        cell.imageOfPlace?.layer.cornerRadius = cell.imageOfPlace.frame.height / 2  // 85/2 делаем круг из imageView. т.к. высота изображения =                                                                  // высоте строки, угол радиуса изображения = половине высоты                                                                  //  изображения (квадрата)
        cell.imageOfPlace?.clipsToBounds = true // обрезаем изображение по границам imageView.
        
        
          
          return cell
      }
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.saveNewPlace() // сохраняем вводимые данные перед нажатием кнопки
        places.append(newPlaceVC.newPlace!) // добовляем новые данные в массив
        tableView.reloadData() // обновляем таблицу с местами
    }

}
