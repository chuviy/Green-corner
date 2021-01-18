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

/*
 Объявляем протокол вне класса, так как он должне быть доступен отовсюду.
 Для передачи данных из MapViewController в NewPlaceViewController.
 */
protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {

    var mapManager = MapManager() /* Для вызова методов работы с картами */
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let annotationIdentifire = "annotationIdentifire"
    var incomeSegueIdentifier = ""
    
/* Предыдущее местоположение пользователя, инициализируется при построении маршрута. Closure возвращает координаты и вызывается showUserLocation */
    var previusLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(for: mapView, and: previusLocation) { (currentLocation) in
                
                self.previusLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
                
            }
        }
    }
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        addressLabel.text = ""
        mapView.delegate = self // назначаем делегатом сам класс
        setupMapView() // показываем точки на карте с проверкой по segue
    }
    
    @IBAction func centerViewUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func closeVC() {
        // закрываем VC и выгружаем из памяти
        dismiss(animated: true)
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text!)
        dismiss(animated: true)
    }
    /* Closure в методет возвращает текущие координаты пользователя, которые передаются в previusLocation */
    @IBAction func goButtonPressed() {
        mapManager.getDirections(for: mapView) { (location) in
            self.previusLocation = location
        }
    }
    
    private func setupMapView() {
        
        goButton.isHidden = true
        
        /* Проверяем доступность сервисов геолокации */
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlaceMark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
            
        }
        
    }
   
//    private func setupLocationManager() {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    }
    
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
    // вызывается каждый раз при смене отображаемого на экране региона (и др изменений)
    // с момощью этого метода будем отображать текущий адрес в "центре" экрана
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // текущие координаты по центру отображаемой области
        let center = mapManager.getCenterLocation(for: mapView)
        // объект для преобразования географических координат и названий
        let geoсoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previusLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: mapView)
            }
        }
        /* для освобождения ресурсов связанных с геокодированием делаем отмену отложенного запроса */
        geoсoder.cancelGeocode()
        
        // Преобразуем координаты в адрес. completionHandler возвращает массив меток, которые соответствуют переданным координатам
        geoсoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
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
                     self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
                 
            }
            
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
     
}

extension MapViewController: CLLocationManagerDelegate {
    
    // вызываеться при каждом изменении статуса авторизации приложения для использовния служб геолокации
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkLocationAutorization(mapView: mapView, segueIdentifier: incomeSegueIdentifier)
    }
}
