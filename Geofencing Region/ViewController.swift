//
//  ViewController.swift
//  Geofencing Region
//
//  Created by Kyle Lee on 6/4/17.
//  Copyright © 2017 Kyle Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in }
        mapView.delegate = self
        locationManager.delegate = self
        mapView.userTrackingMode = .followWithHeading // light on user location o<
        mapView.showsUserLocation = true
        
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            makeZoom()
        }
        
        //Reconocer gesto
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(longpress))
        uilpgr.minimumPressDuration = 2 //tiempo para que se reconozca el gesto
        mapView.addGestureRecognizer(uilpgr) //agrega el gesto al mapa
    }
    
    func makeZoom(){
        guard let userCoordinates = locationManager.location?.coordinate else { return }
        let latDelta : CLLocationDegrees = 0.025
        let longDelta : CLLocationDegrees = 0.025
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)//nivel de Zoom en Ancho y alto de la region
        let region = MKCoordinateRegion(center: userCoordinates, span: span)
        mapView.setRegion(region, animated: true)
    }

    
    @objc func longpress(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: self.mapView)//guarda las coordenadas de donde se hizo el gesto
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let region = CLCircularRegion(center: coordinate, radius: 200, identifier: "geofence")
        //mapView.removeOverlays(mapView.overlays)
        locationManager.startMonitoring(for: region)
        let circle = MKCircle(center: coordinate, radius: region.radius)
        mapView.add(circle)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.badge = 1
        content.sound = .default()
        let request = UNNotificationRequest(identifier: "notif", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let title = "Entraste a la region"
        let message = "Revisa nuestros descuentos"
        showAlert(title: title, message: message)
        showNotification(title: title, message: message)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let title = "Dejaste la region"
        let message = "Vuelve pronto, hay descuentos"
        showAlert(title: title, message: message)
        showNotification(title: title, message: message)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = .blue
        circleRenderer.fillColor = .red
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
}








