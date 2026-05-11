import Combine
import CoreLocation
import Foundation

@MainActor
final class WeatherViewModel: NSObject, ObservableObject {
    @Published var snapshot: WeatherSnapshot = .fallback
    @Published var isLoading = false
    @Published var lastError: String?

    private let service: WeatherProviding
    private let locationManager = CLLocationManager()

    init(service: WeatherProviding = OpenMeteoWeatherService()) {
        self.service = service
        super.init()
        locationManager.delegate = self
    }

    func requestWeather() {
        isLoading = true
        lastError = nil

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            isLoading = false
            lastError = "Location permission denied. Using fallback weather."
            snapshot = .fallback
        @unknown default:
            isLoading = false
            snapshot = .fallback
        }
    }

    private func loadWeather(latitude: Double, longitude: Double) {
        Task {
            do {
                let newSnapshot = try await service.fetchTodayWeather(latitude: latitude, longitude: longitude)
                snapshot = newSnapshot
                isLoading = false
            } catch {
                snapshot = .fallback
                lastError = "Unable to fetch weather. Using fallback values."
                isLoading = false
            }
        }
    }
}

extension WeatherViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            manager.requestLocation()
        } else if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            snapshot = .fallback
            isLoading = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            snapshot = .fallback
            isLoading = false
            return
        }
        loadWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        snapshot = .fallback
        lastError = "Unable to access location. Using fallback weather."
        isLoading = false
    }
}
