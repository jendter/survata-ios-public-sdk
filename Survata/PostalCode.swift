//
//  PostalCode.swift
//  Survata
//
//  Created by Rex Sheng on 2/15/16.
//  Copyright © 2016 Survata. All rights reserved.
//

import CoreLocation

enum Geocode {
	class GeocodeContainer: NSObject, CLLocationManagerDelegate {
		var locationManager: CLLocationManager!

		var callback: (CLLocation? -> Void)?

		func current(callback: CLLocation? -> Void) {
			locationManager?.stopUpdatingLocation()
			self.callback = callback
			if locationManager == nil {
				locationManager = CLLocationManager()
				locationManager.delegate = self
				locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
				locationManager.requestWhenInUseAuthorization()
			}
			locationManager.startUpdatingLocation()
		}

		func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
			callback?(locations.last)
			callback = nil
			manager.stopUpdatingLocation()
		}

		func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
			callback?(manager.location)
			callback = nil
			print(error.localizedDescription)
			manager.stopUpdatingLocation()
		}

		deinit {
			print("deinit GeocodeContainer")
		}
	}
	private static var geoContainer = GeocodeContainer()
	case Location(CLLocation)
	case Current

	func get(closure: (String?) -> ()) {
		switch self {
		case .Location(let location):
			CLGeocoder().reverseGeocodeLocation(location) { (addresses, error) in
				if let addresses = addresses {
					for address in addresses where address.ISOcountryCode == "US" {
						if let postalCode = address.postalCode {
							Cache(file: "geocode")?.saveJSON(["postalCode": postalCode])
							closure(postalCode)
							return
						}
					}
				}
				closure(nil)
			}
		case .Current:
			if let cached = Cache(file: "geocode")?.loadJSON(expireAfter: 86400) as? [String: AnyObject] {
				if let postalCode = cached["postalCode"] as? String {
					closure(postalCode)
					return
				}
			}
			switch CLLocationManager.authorizationStatus() {
			case .AuthorizedAlways, .AuthorizedWhenInUse:
				Geocode.geoContainer.current { (location) in
					if let location = location {
						Geocode.Location(location).get(closure)
					} else {
						closure(nil)
					}
				}
			default:
				closure(nil)
			}
		}
	}
}

struct Cache {
	let filePath: String
	init?(file: String) {
		let home = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first
		if let folder = home?.stringByAppendingString("/survata") {
			if !NSFileManager.defaultManager().fileExistsAtPath(folder) {
				do {
					try NSFileManager.defaultManager().createDirectoryAtPath(folder, withIntermediateDirectories: true, attributes: nil)
				} catch {
					return nil
				}
			}
			filePath = "\(folder)/\(file)"
		} else {
			return nil
		}
	}

	func loadJSON(expireAfter time: NSTimeInterval) -> AnyObject? {
		if let attr = try? NSFileManager.defaultManager().attributesOfItemAtPath(filePath),
			lastModified = attr[NSFileModificationDate] as? NSDate {
				let time = lastModified.timeIntervalSinceNow + time
				if time < 0 {
					return nil
				}
		}
		if let data = NSData(contentsOfFile: filePath),
			object = try? NSJSONSerialization.JSONObjectWithData(data, options: []) {
				return object
		}
		return nil
	}

	func saveJSON(json: AnyObject) {
		if let data = try? NSJSONSerialization.dataWithJSONObject(json, options: []) {
			data.writeToFile(filePath, atomically: false)
		}
	}
}