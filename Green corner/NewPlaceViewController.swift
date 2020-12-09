//
//  NewPlaceViewController.swift
//  Green corner
//
//  Created by Aleksey Antokhin on 09.12.2020.
//  Copyright © 2020 Aleksey Antokhin. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    @IBOutlet var imageOfPlace: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
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
}

// MARK: Text field delegete
    extension NewPlaceViewController: UITextFieldDelegate {
        // скрываем клавиатуру по нажанию на Done
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
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
        imageOfPlace.image = info[.editedImage] as? UIImage // берем и присваиваем в imageOfPlace.image, значение по конкретному ключу info. Св-ва данной ст-ры определяют тип контента.
        imageOfPlace.contentMode = .scaleAspectFit // масштабируем изображение по содержимому UIImage
        imageOfPlace.clipsToBounds = true // обрезка по границе
        dismiss(animated: true) // закрываем imagePickerController
    }
    
}
    

