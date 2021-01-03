//
//  NewPlaceViewController.swift
//  Green corner
//
//  Created by Aleksey Antokhin on 09.12.2020.
//  Copyright © 2020 Aleksey Antokhin. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    var currentPlace: Place!
    var imageIsChanged = false

    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeType: UITextField!
    @IBOutlet var ratingControl: RatingControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        DispatchQueue.main.async {     // загрузка в фоновом режиме временных данных в БД
//            self.newPlace.savePlaces()
//        }
        
        // Убираем границу под рейтинговыми звездами
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1))
        saveButton.isEnabled = false // изначально отключаем кнопку
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen() // внутри метода проверка: если currentPlace не пустой то редактируем.
    }
    
    // MARK: Table view delegate
    // скрываем клавиатуру (если tup в влюбом месте кроме textField) вызываем метод chooseImagePicker
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
           
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            let actionSheet = UIAlertController(title: nil,
                                               message: nil,
                                               preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true) // вызываем контроллер actionSheet
            
        } else {
            view.endEditing(true)
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        /* Если получилось извлечь идентификатор segue и создать экземпляр класса MapVC */
        guard
            let identifier = segue.identifier,
            let mapVC = segue.destination as? MapViewController
            else { return }
        
        /* Если получилось извлечь идентификатор segue и создать экземпляр класса MapVC,
        то педедаем текщий segue identifier в созданный mapVC	 */
        mapVC.incomeSegueIdentifier = identifier
      
        /* Назначаем за выполение методов протокола MapViewControllerDelegete сам класс NewPlaceViewController
        т.е. Объявляем текущий класс делегатом. Необходимо подписать класс под протокол MapViewControllerDelegete */
        mapVC.mapViewControllerDelegete = self
        
        if identifier == "showPlace" {
            mapVC.place.name = placeName.text!
            mapVC.place.location = placeLocation.text
            mapVC.place.type = placeType.text
            mapVC.place.imageData = placeImage.image?.pngData()
           // print(mapVC.place.location)
        }
        
    }
    
    func savePlace() { // сохраняем данные о местах в БД
                
        var image: UIImage?
        
        if imageIsChanged {
            image = placeImage.image
        } else {
            image = #imageLiteral(resourceName: "LaunchScreen")
        }

        let imageData = image?.pngData() // конвертируем UIImage to Data
        
        // для сохранения новой записи в БД
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData,
                             rating: Double(ratingControl.rating))
        /* если режим редактирования то записываем данные из currentPlace, иначе записываем из Outlets*/
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
              } else {
                StorageManager.saveObject(newPlace)
            }
        
    }
    
    private func setupEditScreen() {
        
        if currentPlace != nil {
            setupNavigationBar() // убираем кнопку Cancel, меняем title, включаем кнопку save
            imageIsChanged = true
            /* Раскрываем опционал. Если в объекте есть картинка в Data, то преобразуем её в UIImage*/
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            /* подставляем в Outlets значения из объекта currentPlace для редактирования*/
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill // масштабируем по размеру
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            ratingControl.rating = Int(currentPlace.rating)
        }
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

// MARK: Text field delegete
    extension NewPlaceViewController: UITextFieldDelegate {
        // скрываем клавиатуру по нажанию на Done
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        @objc private func textFieldChanged() {
            
            if placeName.text?.isEmpty == false {
                saveButton.isEnabled = true
            } else {
                saveButton.isEnabled = false
            }
        }
    }
     
// MARK: Work with image

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImagePicker(source: UIImagePickerController.SourceType) { // выбираем источник изображения
        if UIImagePickerController.isSourceTypeAvailable(source) {
           let imagePicker = UIImagePickerController() // создаем экземпляр класса UIImagePickerController
            imagePicker.delegate = self // делигируем экземпляру класса NewPlaceViewController управление imagePicker
            imagePicker.allowsEditing = true // позволит редактировать выбанное изображение
            imagePicker.sourceType = source // определяем источник изображения // imagePicker - это контроллер
            present(imagePicker, animated: true) // показываем(вызов в ) imagePicker контроллер
            
        }
        
    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage // берем и присваиваем в imageOfPlace.image, значение по конкретному ключу info. Св-ва данной ст-ры определяют тип контента.
        placeImage.contentMode = .scaleAspectFit // масштабируем изображение по содержимому UIImage
        placeImage.clipsToBounds = true // обрезка по границе
        
        imageIsChanged = true
        
        dismiss(animated: true) // закрываем imagePickerController
    }
    
}
    
/* Объявляя текущий класс делегатом в "func prepare(for segue:", необходимо подписать класс под протокол MapViewControllerDelegete */
extension NewPlaceViewController: MapViewControllerDelegete {
   
    // Передаем значене address в поле location
    func getAddres(_ addres: String?) {
        placeLocation.text = addres
    }
    
}

