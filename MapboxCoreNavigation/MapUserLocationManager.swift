import MapboxNavigationNative
import CoreLocation

open class MapUserLocationManager: NavigationLocationManager, CLLocationManagerDelegate {
    private var proxyDelegate: ProxyDelegate
    public required init(navigator: Navigator? = nil) {
        proxyDelegate = ProxyDelegate(navigator: navigator ?? Navigator())
        super.init()

        super.delegate = proxyDelegate
    }

    func setCustomLocation(_ location: CLLocation?) {
        guard let location = location else { return }
        stopUpdatingLocation()
        stopUpdatingHeading()
        delegate?.locationManager?(self, didUpdateLocations: [location])
    }

// MARK: MGLLocationManager
    override public var delegate: CLLocationManagerDelegate? {
        get {
            proxyDelegate.delegate
        }
        set {
            proxyDelegate.delegate = newValue
        }
    }

    private class ProxyDelegate: NSObject, CLLocationManagerDelegate {
        private var navNative: Navigator!
        var delegate: CLLocationManagerDelegate?

        required init(navigator: Navigator? = nil) {
            self.navNative = navigator ?? Navigator()
            super.init()
        }

        deinit {
            self.navNative = nil
        }

        // MARK: CLLocationManagerDelegate

        public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let loc = locations.first {
                navNative?.updateLocation(for: FixLocation(loc))
                let projectedDate = Date().addingTimeInterval(1.0)
                let status = navNative.getStatusForTimestamp(projectedDate)
                delegate?.locationManager?(manager, didUpdateLocations: [CLLocation(status.location)])
            }
        }

        public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            delegate?.locationManager?(manager, didUpdateHeading: newHeading)
        }

        public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
            return delegate?.locationManagerShouldDisplayHeadingCalibration?(manager) ?? false
        }

        public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            delegate?.locationManager?(manager, didFailWithError: error)
        }
    }
}
