//
//  MapViewController.swift
//  Green corner
//
//  Created by Aleksey Antokhin on 28.12.2020.
//  Copyright © 2020 Aleksey Antokhin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    // инициализируем значением по умолчанию (default пустой инициализатор)
    var place = Place()
    
    let annotationIdentifire = "annotationIdentifire"
    
    // отвечает за настройку и управление службами геолокации
    let locationManager = CLLocationManager()
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // назначаем делегатом сам класс
        mapView.delegate = self
        // показываем точки на карте
        setupPlaceMark()
        
        checkLocationServices()

    }
    
    @IBAction func closeVC() {
        // закрываем VC и выгружаем из памяти
        dismiss(animated: true)
    }
    
    private func setupPlaceMark() {
        
        guard let location = place.location else { return }
        
        // преобразуем координаы долготы и широты в пользовательский формат: город, улица, дом и т.д.
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error)  in
        
            if let error = error {
                print("error: \(error)")
                return
            }
            
            guard let placemarks = placemarks else { return }
            // получакем метку на карте
            let placemark = placemarks.first
            // описываем точку на карте
            let annotation =  MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placeMarkLocation = placemark?.location else { return }
            // привязываем аннотацию к точке на карте
            annotation.coordinate = placeMarkLocation.coordinate
            // показываем массив анотаций на карте
            self.mapView.showAnnotations([annotation], animated: true)
            // выделяем анотацию
            self.mapView.selectAnnotation(annotation, animated: true)
        }
        
    }
    
    // проверяем включены ли службы геолокации
    private func checkLocationServices() {
       
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAutorization()
        } else {
            // alertController
        }
        
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Проверка статуса на разрешение использования геолокации
    private func checkLocationAutorization() {
        
        switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                mapView.showsUserLocation = true
                break
            case .denied:
                // Show alert Controller
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                break
            case .authorizedAlways:
                break
            
            @unknown default:
            print("New case is available")
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    // отображение аннотации
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifire) as? MKPinAnnotationView
        
        if annotationView == nil {
            
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifire)
            // Отображаем аннотацию в виде банера
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        
        return annotationView
    }
     
}

extension MapViewController: CLLocationManagerDelegate {
    
    // вызываеться при каждом изменении статуса авторизации приложения для использовния служб геолокации
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAutorization()
    }
}
