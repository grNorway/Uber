//
//  DriverTableViewController.swift
//  Uber
//
//  Created by Panagiotis Siapkaras on 7/23/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class DriverTableViewController: UITableViewController {

    
    var riderRequests : [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        Database.database().reference().child("RideRequests").observe(.childAdded, with: { (snapshot) in
            
            if let riderRequestDict = snapshot.value as? [String : Any]{
                if let driverLatitude = riderRequestDict["driverLatitude"] as? Double{
                    
                }else{
                    self.riderRequests.append(snapshot)
                    self.tableView.reloadData()
                }
            }
            
            
            
            
        })
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logOutTapped(_ sender: UIBarButtonItem) {
        
        do{
           try Auth.auth().signOut()
            navigationController?.dismiss(animated: true, completion: nil)
        }catch{
            
        }
    }
    
    
    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return riderRequests.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)

        let snapshot = riderRequests[indexPath.row]
        
        if let dict = snapshot.value as? [String: Any]{
            if let email = dict["email"] as? String{
                if let latitude = dict["latitude"] as? Double{
                    if let longitude = dict["longitude"] as? Double{
                     
                        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                        let riderCLLocation = CLLocation(latitude: latitude, longitude: longitude)
                        let distance = round(driverCLLocation.distance(from: riderCLLocation) / 1000)
                        
                        
                        cell.textLabel!.text = "\(email) - \(distance) away"
                    }
                }
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = riderRequests[indexPath.row]
        performSegue(withIdentifier: "AcceptRequest", sender: snapshot)
    }
    

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationController = segue.destination as! AcceptRequestViewController
        
        if segue.identifier == "AcceptRequest",let snapshot = sender as? DataSnapshot{
            if let dict = snapshot.value as? [String : Any]{
                if let email = dict["email"] as? String , let latitude = dict["latitude"] as? Double , let longitude = dict["longitude"] as? Double {
                    destinationController.requestEmail = email
                    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    destinationController.requestLocation = location
                    destinationController.driverLocation = driverLocation
                }
                
        }
        }
    }
    

}


extension DriverTableViewController : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let driverCoord = manager.location?.coordinate{
            driverLocation = driverCoord
        }
        
    }
    
    
    
}
