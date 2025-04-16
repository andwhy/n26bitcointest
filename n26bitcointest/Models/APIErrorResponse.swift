
/// Structure to decode API-level error from CoinGecko (e.g., 429 Too Many Requests)
struct APIErrorResponse: Codable {
    let status: Status

    struct Status: Codable {
        let error_code: Int
        let error_message: String
    }
}
