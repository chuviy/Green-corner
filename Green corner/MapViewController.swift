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
    let regionInMeters = 10_000.00
    var incomeSegueIdentifier = ""
    
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var adressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        adressLabel.text = ""
        
        // назначаем делегатом сам класс
        mapView.delegate = self
        // показываем точки на карте с проверкой по segue
        setupMapView()
        checkLocationServices()

    }
    
    @IBAction func centerViewUserLocation() {
        
        showUserLocation()
    }
    
    
    @IBAction func closeVC() {
        // закрываем VC и выгружаем из памяти
        dismiss(animated: true)
    }
    
    @IBAction func doneButtonPressed() {
    }
    
    private func setupMapView() {
        
        if incomeSegueIdentifier == "showPlace" {
            setupPlaceMark()
            mapPinImage.isHidden = true
            adressLabel.isHidden = true
            doneButton.isHidden = true
            
        }
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
                if incomeSegueIdentifier == "getAdress" { showUserLocation() }
                break
            case .denied:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showAlert(
                        title: "Your Location is not Availeble",
                        message: "To give permission Go to: Setting -> Green corner -> Location"
                    )
                }
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
   
    
    private func showUserLocation() {
        
        if let location = locationManager.location?.coordinate {
                   let region = MKCoordinateRegion(center: location,
                                                   latitudinalMeters: regionInMeters,
                                                   longitudinalMeters: regionInMeters)
                   mapView.setRegion(region, animated: true)
               }
    }
    
    // возвращает текущие координаты точки находящейся по центру экрана
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
                
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
    // вызывается каждый раз при смене отображаемого на экране региона
    // с момощью этого метода будем отображать текущий адрес в центре экрана
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // текущие координаты по центру отображаемой области
        let center = getCenterLocation(for: mapView)
        // объект для преобразования географических координат и названий
        let geoCoder = CLGeocoder()
        
        // Преобразуем координаты в адрес. completionHandler возвращает массив меток, которые соответствуют переданным координатам
        geoCoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            // Если ошибок нет, извлекаем массив меток. В данном случае массив содержит одну метку.
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare // улица
            let buildNumber = placemark?.subThoroughfare // номер дома
            
            /* Обновлять интерфейс мы должны в основном потоке асинхронно */
            DispatchQueue.main.async {
                
                if streetName != nil && buildNumber != nil {
                     self.adressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.adressLabel.text = "\(streetName!)"
                } else {
                    self.adressLabel.text = ""
                }
                 
            }
            
            
        }
        
    }
     
}

extension MapViewController: CLLocationManagerDelegate {
    
    // вызываеться при каждом изменении статуса авторизации приложения для использовния служб геолокации
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAutorization()
    }
}
