import SwiftUI

struct AIanswerView: View {
    let products: [Product]
    @State private var aiResponse: String = "로딩 중입니다..."
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("AI 추천 결과")
                    .font(.title2)
                    .bold()
                
                Text(aiResponse)
                    .font(.body)
                    .foregroundColor(.black)
            }
            .padding()
        }
        .background(Color.white.ignoresSafeArea()) 
        .onAppear {
            requestAIRecommendation()
        }
        .navigationTitle("AI 추천")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func requestAIRecommendation() {
        let prompt = generatePrompt(from: products)
        let apiKey = Bundle.main.openAIKey

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "당신은 소비자가 어떤 제품을 먼저 구매하면 좋을지 도와주는 AI입니다."],
                ["role": "user", "content": prompt]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                DispatchQueue.main.async {
                    self.aiResponse = content.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }.resume()
    }

    private func generatePrompt(from products: [Product]) -> String {
        var result = "다음 3개의 상품 중 어떤 것을 먼저 사는 것이 가장 좋은지 추천해줘.\n\n"
        for (index, product) in products.prefix(3).enumerated() {
            result += """
            \(index + 1)번 상품
            - 이름: \(product.name)
            - 가격: \(product.price)
            - 욕구: \(product.purchaseDesire)/10
            - 사용 용도: \(product.usageContext)
            - 특징: \(product.features)

            """
        }
        result += "\n각 제품을 비교한 뒤, 가장 먼저 살 제품을 추천해줘. 추천 이유도 설명해줘."
        return result
    }
}

