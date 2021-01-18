//
//  MapManager.swift
//  Green corner
//
//  Created by Aleksey Antokhin on 18.01.2021.
//  Copyright © 2021 Aleksey Antokhin. All rights reserved.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    private let regionInMeters = 1000.00
    private var directionsArray: [MKDirections] = []
    private var placeCoordinate: CLLocationCoordinate2D? // координаты местоназначения точки
    
    func setupPlaceMark(place: Place, mapView: MKMapView) {
              
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
                  annotation.title = place.name
                  annotation.subtitle = place.type
                  
                  guard let placeMarkLocation = placemark?.location else { return }
                 
                  // привязываем аннотацию к точке на карте
                  annotation.coordinate = placeMarkLocation.coordinate
      
                  // передаем координаты зеленой точки в переменную для построения маршрута
                  self.placeCoordinate = placeMarkLocation.coordinate
                  // показываем массив анотаций на карте
                  mapView.showAnnotations([annotation], animated: true)
                 
                  // выделяем анотацию
                  mapView.selectAnnotation(annotation, animated: true)
              }
              
          }
    
    // проверяем включены ли службы геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: ()->() ) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAutorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showAlert(
                        title: "Location Services are Disabled",
                        message: "To enable it go: Settings -> Privacy -> Location Services and turn On"
                    )
                }
            }
        
    }
    
    // Проверка статуса на разрешение использования геолокации
    func checkLocationAutorization(mapView: MKMapView, segueIdentifier: String ) {
        
        switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                mapView.showsUserLocation = true
                if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
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
    
    // Фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView) {
        
        if let location = locationManager.location?.coordinate {
                   let region = MKCoordinateRegion(center: location,
                                                   latitudinalMeters: regionInMeters,
                                                   longitudinalMeters: regionInMeters)
                   mapView.setRegion(region, animated: true)
               }
    }
    
    /* Строим маршрут от местоположения пользователя до зеленой точки.
       В замыкание previosLocation мы передаем текущие координаты пользователя */
    func getDirections(for mapView: MKMapView, previosLocation: (CLLocation) -> ()) {
      // координаты местоположения пользователя - широта и долгота
      guard let location = locationManager.location?.coordinate else {
          showAlert(title: "Error", message: "Current location is not found")
          return
      }
               /* Елси текущее местоположение определено, включаем отслежевание текущего местоположение пользователя */
               locationManager.stopUpdatingLocation()
               
               /* Передаем текущие координаты в previosLocation */
               previosLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
               
               guard let request = createDirectionsRequest(from: location) else {
                   showAlert(title: "Error", message: "Destanation is not found")
                   return
               }
               
               /* если createDirectionsRequest отработал успешно, то создаем маршрут на основе сведений которые передаются в запросе */
               let diretcions = MKDirections(request: request)
               
               // избавляемся от текущих маршрутов при построении новых
                 resetMapView(withNew: diretcions, mapView: mapView)
              
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
                       mapView.addOverlay(route.polyline)
                       mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)

                       let distance = String(format: "%.1f ", route.distance / 1000)
                       let timeInterval = route.expectedTravelTime

                       print("Растояние до места \(distance) км.")
                       print("Время в пути составит \(timeInterval) сек.")
                   }
               }
           }
    // Настройка запроса для расчета маршрута
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
               
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
     // Меняем отображаемую зону области карты в соответствии с перемещением пользователя
     func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation)->()) {
        
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        
        closure(center)
        
//        /* Позиционируем карту в соответствии с текущем положением пользователя с задержкой в 3 сек*/
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            self.showUserLocation()
//        }
    }
    
    /* Сброс всех ранее построенных маршрутов перед построением ногово */
     func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
              // удаляем с карты маршруты (наложения)
              mapView.removeOverlays(mapView.overlays)
              // добавляем в массив текущие маршруты
              directionsArray.append(directions)
              // отменяем все действующие маршруты из массива
              let _ = directionsArray.map { $0.cancel() }
              // удаляем все элементы из массива
              directionsArray.removeAll()
              
          }
    
    /* возвращает текущие координаты точки находящейся по центру экрана */
         func getCenterLocation(for mapView: MKMapView) -> CLLocation {
            
            let latitude = mapView.centerCoordinate.latitude
            let longitude = mapView.centerCoordinate.longitude
            
            return CLLocation(latitude: latitude, longitude: longitude)
        }
        
    private func showAlert(title: String, message: String) {
           
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let okAction = UIAlertAction(title: "OK", style: .default)
           
           alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds) // создаем окно по границам экрана
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1 // позиционирование, отображаем поверх окон
        alertWindow.makeKeyAndVisible() // делаем окно ключевым и видимым
        alertWindow.rootViewController?.present(alert, animated: true)
                   
       }
    
   
}


