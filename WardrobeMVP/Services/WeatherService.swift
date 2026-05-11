import Foundation

protocol WeatherProviding {
    func fetchTodayWeather(latitude: Double, longitude: Double) async throws -> WeatherSnapshot
}

struct OpenMeteoWeatherService: WeatherProviding {
    func fetchTodayWeather(latitude: Double, longitude: Double) async throws -> WeatherSnapshot {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&daily=weather_code,temperature_2m_max,temperature_2m_min&forecast_days=1&timezone=auto"
        guard let url = URL(string: urlString) else {
            return .fallback
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)

        guard
            let min = decoded.daily.temperature2mMin.first,
            let max = decoded.daily.temperature2mMax.first,
            let code = decoded.daily.weatherCode.first
        else {
            return .fallback
        }

        return WeatherSnapshot(
            minTempC: Int(min.rounded()),
            maxTempC: Int(max.rounded()),
            condition: mapCondition(code: code)
        )
    }

    private func mapCondition(code: Int) -> WeatherCondition {
        switch code {
        case 71...79: return .snow
        case 51...69, 80...99: return .rain
        case 1...48: return .cloudy
        default: return .clear
        }
    }
}

private struct OpenMeteoResponse: Decodable {
    let daily: Daily

    struct Daily: Decodable {
        let weatherCode: [Int]
        let temperature2mMax: [Double]
        let temperature2mMin: [Double]

        enum CodingKeys: String, CodingKey {
            case weatherCode = "weather_code"
            case temperature2mMax = "temperature_2m_max"
            case temperature2mMin = "temperature_2m_min"
        }
    }
}
