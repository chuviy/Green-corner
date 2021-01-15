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

    var mapViewControllerDelegate: MapViewControllerDelegate?
    
    // инициализируем значением по умолчанию (default пустой инициализатор)
    var place = Place()
    
    let annotationIdentifire = "annotationIdentifire"
    // отвечает за настройку и управление службами геолокации
    let locationManager = CLLocationManager()
    let regionInMeters = 1000.00
    var incomeSegueIdentifier = ""
    // координаты местоназначения точки
    var placeCoordinate: CLLocationCoordinate2D?
    
    var directionsArray: [MKDirections] = []
    
    // предыдущее местоположение пользователя, инициализируется при построении маршрута
    var previusLocation: CLLocation? {
        didSet {
            startTrackingUserLocation()
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
        mapViewControllerDelegate?.getAddress(addressLabel.text!)
       
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed() {
        getDirections()
    }
    
    
    private func setupMapView() {
        
        goButton.isHidden = true
        
        if incomeSegueIdentifier == "showPlace" {
            setupPlaceMark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
            
        }
    }
    /* Перед построением нового маршрута удаляем текущий. */
    private func resetMapView(withNew directions: MKDirections) {
        
        // удаляем с карты маршруты (наложения)
        mapView.removeOverlays(mapView.overlays)
        // добавляем в массив текущие маршруты
        directionsArray.append(directions)
        // отменяем все действующие маршруты из массива
        let _ = directionsArray.map { $0.cancel() }
        // удаляем все элементы из массива
        directionsArray.removeAll()
        
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
            
            // передаем координаты зеленой точки в переменную для построения маршрута
            self.placeCoordinate = placeMarkLocation.coordinate
            
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
                if incomeSegueIdentifier == "getAddress" { showUserLocation() }
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
    
    private func startTrackingUserLocation() {
        
        guard let previusLocation = previusLocation else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: previusLocation) > 50 else { return }
        self.previusLocation = center
        
        /* Позиционируем карту в соответствии с текущем положением пользователя с задержкой в 3 сек*/
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserLocation()
        }
    }
   
    private func getDirections() {
      
        // координаты местоположения пользователя - широта и долгота
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        /* Елси текущее местоположение определено, включаем отслежевание текущего местоположение пользователя */
        locationManager.stopUpdatingLocation()
        
        /* Передаем текущие координаты в св-во previosLocation */
        previusLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destanation is not found")
            return
        }
        
        //  если createDirectionsRequest отработал успешно, то создаем маршрут на основе сведений которые передаются в запросе
        let diretcions = MKDirections(request: request)
        
        // избавляемся от текущих маршрутов при построении новых
        resetMapView(withNew: diretcions)
        
        // расчет маршрута
        diretcions.calculate { (response, error) in
            
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.showAlert(title: "Error", message: "Direction is not available")
                return
            }
            // если ошибки нет, то перебираем список маршрутов
            for route in response.routes {
                print(route.name)
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)

                let distance = String(format: "%.1f ", route.distance / 1000)
                let timeInterval = route.expectedTravelTime

                print("Растояние до места \(distance) км.")
                print("Время в пути составит \(timeInterval) сек.")
            }
        }
    }
    
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        // раскрываем координаты местоназначения
        guard let destinationCoordinate = placeCoordinate else {
            print("return nil")
            return nil }
         
            let startingLocation = MKPlacemark(coordinate: coordinate)
            let destination = MKPlacemark(coordinate: destinationCoordinate)
        
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: startingLocation)
            request.destination = MKMapItem(placemark: destination)
            request.transportType = .automobile
            request.requestsAlternateRoutes = true
        
        return request
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
    // вызывается каждый раз при смене отображаемого на экране региона (и др изменений)
    // с момощью этого метода будем отображать текущий адрес в центре экрана
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // текущие координаты по центру отображаемой области
        let center = getCenterLocation(for: mapView)
        // объект для преобразования географических координат и названий
        let geoсoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previusLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showUserLocation()
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
        checkLocationAutorization()
    }
}
