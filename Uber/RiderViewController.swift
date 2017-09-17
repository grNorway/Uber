//
//  RiderViewController.swift
//  Uber
//
//  Created by Panagiotis Siapkaras on 7/23/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit
import FirebaseAuth
import MapKit
import FirebaseDatabase

class RiderViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var callAnUberButton: UIButton!
    
    
    var locationManager = CLLocationManager()
    var userCoordinates = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    var driverOnTheWay = false
    var driverLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        if let email = Auth.auth().currentUser?.email{
            var handle: UInt = 1
            handle = Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                
                self.uberHasBeenCalled = true
                self.callAnUberButton.setTitle("Cancel Uber", for: .normal)
                
                Database.database().reference().child("RideRequests").removeObserver(withHandle: handle)
                
                if let riderRequestDict = snapshot.value as? [String:Any] {
                    if let driverLatitude = riderRequestDict["driverLatitude"] as? Double{
                        self.driverLocation.latitude = driverLatitude
                    }
                    if let driverLongitude = riderRequestDict["driverLongitude"] as? Double{
                        self.driverLocation.longitude = driverLongitude
                    }
                    self.driverOnTheWay = true
                    self.displayDriverRider()
                }
                
            })
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func displayDriverRider(){
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userCoordinates.latitude, longitude: userCoordinates.longitude)
        
        let distance = round(driverCLLocation.distance(from: riderCLLocation) / 1000)
        callAnUberButton.setTitle("your Driver is \(distance)km away", for: .normal)
        mapView.removeAnnotations(mapView.annotations)
        
        let latDelta = abs(driverLocation.latitude - userCoordinates.latitude) * 2 + 0.005
        let longDelta = abs(driverLocation.longitude - userCoordinates.longitude) * 2 + 0.005
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let region = MKCoordinateRegion(center: userCoordinates, span: span)
        mapView.setRegion(region, animated: true)
        
        let userAnnotation = MKPointAnnotation()
        userAnnotation.coordinate = userCoordinates
        userAnnotation.title = "Your Location"
        mapView.addAnnotation(userAnnotation)
        
        let driverAnnotation = MKPointAnnotation()
        driverAnnotation.coordinate = driverLocation
        driverAnnotation.title = "Your Driver"
        mapView.addAnnotation(driverAnnotation)
        
    }
    
    
    
    @IBAction func logOutButton(_ sender: UIBarButtonItem) {
        
        do{
            try Auth.auth().signOut()
            navigationController?.dismiss(animated: true, completion: nil)
        }catch{
            print("Error : \(error.localizedDescription)")
        }
    }

    @IBAction func callUberTapped(_ sender: UIButton) {
        
        if !driverOnTheWay{
            
        if let email = Auth.auth().currentUser?.email{
            if uberHasBeenCalled {
                
                var handle : UInt = 0
                handle = Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                    snapshot.ref.removeValue()
                    Database.database().reference().child("RideRequests").removeObserver(withHandle: handle)
                })
                uberHasBeenCalled = false
                callAnUberButton.setTitle("Call an Uber", for: .normal)
                
            }else{
                let rideRequest :[String:Any] = ["email":email , "latitude": userCoordinates.latitude, "longitude":userCoordinates.longitude]
                
                Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequest)
                uberHasBeenCalled = true
                callAnUberButton.setTitle("Cancel Request", for: .normal)
            }
        }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RiderViewController : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
                let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
                self.userCoordinates = coord
            
            
            if uberHasBeenCalled{
                displayDriverRider()
                if let email = Auth.auth().currentUser?.email{
                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged, with: { (snapshot) in
                    
                    if let riderDict = snapshot.value as? [String : Any] {
                        if let driverLat = riderDict["driverLatitude"] as? Double{
                            if let driverLong = riderDict["driverLongitude"] as? Double{
                                self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLong)
                                
                            }
                        }
                    }
                })
                }
            }else{
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                let region = MKCoordinateRegion(center: center, span: span)
                
                mapView.setRegion(region, animated: true)
                mapView.removeAnnotations(mapView.annotations)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coord
                annotation.title = "MY location"
                mapView.addAnnotation(annotation)
            }
        }
        
    }
    
    
    
}


