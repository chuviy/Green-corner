//
//  MainViewController.swift
//  Green corner
//
//  Created by Aleksey Antokhin on 08.12.2020.
//  Copyright © 2020 Aleksey Antokhin. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    let plases = [
         "Бор", "река Ока", "река Угра", "Заповедник", "Калужские засеки", "Национальный парк Угра"
         ]
         
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

      // MARK: - Table view data source

      override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return plases.count
            }

      
      override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = plases[indexPath.row]
        cell.imageView?.image = UIImage(named: plases[indexPath.row])
        cell.imageView?.layer.cornerRadius = cell.frame.height / 2  // 85/2 // делаем круг из imageView. т.к. высота изображения = высоте строки, угол радиуса изображения = половине высоты изображения (квадрата)
        cell.imageView?.clipsToBounds = true // обрезаем изображение по границам imageView.
        
        
          
          return cell
      }
    
    // MARK: - Table view delegete
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
