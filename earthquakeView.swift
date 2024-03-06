import SwiftUI
struct APIResponse: Codable {
    var responseId: String
    var responseTime: String
    var status: String
    var items: [APIItem]
}

struct APIItem: Codable, Identifiable {
    var id: Int
    var eventId: String
    var serial: Int
    var dateTime: String
    var isLastInfo: Bool
    var isCanceled: Bool
    var isWarning: Bool
    var text: String
    var earthquake: Earthquake?
    var intensity: Intensity?
}

struct Earthquake: Codable {
    var arrivalTime: String
    var hypocenter: Hypocenter
    var magnitude: Magnitude?
}

struct Hypocenter: Codable {
    var code: String
    var name: String
    var coordinate: Coordinate
    var depth: Depth
    var reduce: Reduce
    var accuracy: Accuracy
}

struct Coordinate: Codable {
    var latitude: ValueText
    var longitude: ValueText
    var height: Height
}

struct ValueText: Codable {
    var value: String
    var text: String
}

struct Height: Codable {
    var type: String
    var unit: String
    var value: String
}

struct Depth: Codable {
    var type: String
    var unit: String
    var value: String
}

struct Reduce: Codable {
    var code: String
    var name: String
}

struct Accuracy: Codable {
    var epicenters: [String]
    var depth: String
    var magnitudeCalculation: String
    var numberOfMagnitudeCalculation: String
}

struct Magnitude: Codable {
    var type: String
    var unit: String
    var value: String?
    var condition: String?
}

struct Intensity: Codable {
    var forecastMaxInt: MaxIntensity
}

struct MaxIntensity: Codable {
    var from: String
    var to: String
}
struct EarthquakeView: View {
    @State private var apiItems: [APIItem] = []
    
    
    var body: some View {
        VStack {
            Text("APIレスポンス")
            List(apiItems) { item in
                VStack(alignment: .leading) {
                    Text("イベントID: \(item.eventId)")
                    Text("発生時刻: \(item.dateTime)")
                    Text("最終情報: \(item.isLastInfo ? "はい" : "いいえ")")
                    Text("取り消し: \(item.isCanceled ? "はい" : "いいえ")")
                    Text("テキスト: \(item.text)")
                    
                    if let earthquake = item.earthquake {
                        Text("地震情報:")
                        VStack(alignment: .leading) {
                            Text("到達時刻: \(earthquake.arrivalTime)")
                            Text("震源地: \(earthquake.hypocenter.name)")
                            Text("深さ: \(earthquake.hypocenter.depth.value) \(earthquake.hypocenter.depth.unit)")
                            if let magnitude = earthquake.magnitude {
                                Text("マグニチュード: \(magnitude.value ?? "不明")")
                            }
                        }
                    }
                }
            }
            
            Button("地震情報取得") {
                fetchAPIData()
            }
        }
    }
    
    
    func fetchAPIData() {
        // JSON データのURL
        let apiKey = ""
        
        let urlString =
        "https://api.dmdata.jp/v2/gd/eew/?key=\(apiKey)&formatMode=json&xmlReport=true"
        // URL を作成
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        // URL リクエストを作成
        let request = URLRequest(url: url)
        // URLSession でデータタスクを作成
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            // エラーハンドリング
            if let error = error {
                print("Request error: \(error.localizedDescription)")
                return
            }
            
            if let jsonData = data {
                // JSONデータをコンソールに出力
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("ここまでうごいてる")
                    print("Received JSON string:\n\(jsonString)")
                }
                
                
                
                if let decodedResponse = try? JSONDecoder().decode(APIResponse.self, from: jsonData) {
                    DispatchQueue.main.async {
                        self.apiItems = decodedResponse.items
                       
                    }
                } else {
                    print("JSON解析に失敗しました")
                    print(apiItems)
                    //[]
                    
                }
            }
            
        }
        
        task.resume()
    }
}


