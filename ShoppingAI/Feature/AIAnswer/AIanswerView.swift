import SwiftUI

struct AIanswerView: View {
    let products: [Product]
    @State private var aiResponse: String = "로딩 중입니다..."
    @Environment(\.presentationMode) var presentationMode
    @State private var showInvalidURLAlert = false

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if aiResponse == "로딩 중입니다..." {
                        loadingView
                    } else {
                        answerView
                    }
                }
                .padding()
            }

            actionButtons
                .padding()
                .alert("유효하지 않은 URL입니다", isPresented: $showInvalidURLAlert) {
                    Button("확인", role: .cancel) {}
                }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            requestAIRecommendation()
        }
    }

    // MARK: - 로딩 뷰

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .customRed))
                .scaleEffect(1.5)
            Text("AI가 상품을 분석 중입니다...")
                .font(.body)
                .foregroundColor(.gray)
            Text("잠시만 기다려 주세요")
                .font(.callout)
                .foregroundColor(.gray.opacity(0.7))
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding(.top, 80)
    }

    // MARK: - 답변 뷰

    private var answerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI 답변")
                .font(.title3)
                .bold()
                .padding(.top, 18)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.customBlack)

            ForEach(aiResponse.components(separatedBy: "\n"), id: \.self) { line in
                let trimmed = line
                    .replacingOccurrences(of: "*", with: "")
                    .trimmingCharacters(in: .whitespaces)

                if trimmed == "살까말까?" {
                    Text(trimmed)
                        .font(.headline)
                        .bold()
                } else if trimmed.contains("추천–") {
                    Text(trimmed)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.customRed)
                } else if trimmed.range(of: #"^\d+\."#, options: .regularExpression) != nil {
                    Text(trimmed)
                        .font(.body)
                        .foregroundColor(.black)
                } else if trimmed.hasPrefix("2번 상품") || trimmed.hasPrefix("3번 상품") {
                    Text(trimmed)
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                } else {
                    Text(trimmed)
                        .font(.body)
                        .foregroundColor(.black)
                }
            }
        }
    }

    // MARK: - 하단 버튼

    private var actionButtons: some View {
        HStack(spacing: 20) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("뒤로가기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.gray)
                    .cornerRadius(10)
                    .fontWeight(.bold)
            }

            Button(action: {
                guard let recommendedName = extractRecommendedProductName(from: aiResponse),
                      let product = products.first(where: { $0.name.trimmingCharacters(in: .whitespacesAndNewlines) == recommendedName }) else {
                    showInvalidURLAlert = true
                    return
                }

                guard let url = makeValidURL(from: product.url) else {
                    showInvalidURLAlert = true
                    return
                }

                UIApplication.shared.open(url, options: [:]) { success in
                    if !success {
                        showInvalidURLAlert = true
                    }
                }
            }) {
                Text("구매하기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.customRed)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .fontWeight(.bold)
            }
        }
    }

    // MARK: - AI 요청

    private func requestAIRecommendation() {
        let prompt = generatePrompt(from: products)
        let apiKey = Bundle.main.openAIKey

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content":
                """
                당신은 소비자가 어떤 제품을 먼저 구매하면 좋을지 도와주는 AI입니다.
                - 각 상품에 대해 가격, 구매 욕구 수치, 사용 용도, 특징 등 다양한 요소를 모두 종합적으로 고려해 주세요.
                - 단순히 욕구 수치가 높다고 추천하지 말고, 실제 사용 가능성, 활용도, 실용성, 상황 적합성 등을 기준으로 합리적으로 판단해야 합니다.
                - 추천 문장은 다음 형식을 반드시 따르세요: '추천– [제품명]을 구매하는 것을 추천합니다.'
                - 분석 시작 전에는 '살까말까?'라는 질문 문장을 반드시 포함하세요.
                - 추천하는 상품의 이유는 3가지 이상 구체적으로 작성하세요.
                - 선택되지 않은 나머지 상품들도 번호로 표기하고, 각각 왜 추천되지 않았는지 설명해 주세요.
                """
                ],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else { return }

            DispatchQueue.main.async {
                self.aiResponse = content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }.resume()
    }

    // MARK: - 유틸

    private func generatePrompt(from products: [Product]) -> String {
        var result = "다음 \(products.count)개의 상품 중 어떤 것을 먼저 사는 것이 가장 좋은지 추천해줘.\n\n"
        for (index, product) in products.enumerated() {
            result += """
            \(index + 1)번 상품
            - 이름: \(product.name)
            - 가격: \(product.price)
            - 욕구: \(product.purchaseDesire)/10
            - 사용 용도: \(product.usageContext)
            - 특징: \(product.features)
            - URL: \(product.url)

            """
        }

        result += """
        살까말까? 라는 질문에 답해주세요.
        가장 먼저 구매해야 할 제품을 하나만 추천해줘.
        이유도 조목조목 설명해줘.
        형식은 아래처럼 해줘:

        추천– [제품명]을 구매하는 것을 추천합니다.
        이유
        1. ...
        2. ...
        3. ...

        그리고 선택되지 않은 나머지 상품(\(products.count - 1)개)이 왜 우선순위에서 밀리는지도 설명해줘.
        """
        return result
    }

    private func extractRecommendedProductName(from response: String) -> String? {
        let lines = response.components(separatedBy: "\n")
        for line in lines {
            if line.contains("추천–") {
                let cleaned = line
                    .replacingOccurrences(of: "*", with: "")
                    .trimmingCharacters(in: .whitespaces)

                if let range = cleaned.range(of: "추천–") {
                    let after = cleaned[range.upperBound...].trimmingCharacters(in: .whitespaces)

                    if let nameEnd = after.range(of: "을 구매")?.lowerBound ?? after.range(of: "를 구매")?.lowerBound {
                        var productName = String(after[..<nameEnd]).trimmingCharacters(in: .whitespaces)

                        if productName.hasPrefix("[") && productName.hasSuffix("]") {
                            productName = String(productName.dropFirst().dropLast())
                        }

                        return productName
                    }
                }
            }
        }
        return nil
    }

    private func makeValidURL(from raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // URL 형식 처리
        if let directURL = URL(string: trimmed), directURL.scheme != nil {
            return directURL
        }

        // 쿼리 처리
        if trimmed.contains("?"),
           let base = trimmed.components(separatedBy: "?").first {
            var components = URLComponents(string: base)
            let queryString = trimmed.components(separatedBy: "?").last ?? ""

            let queryItems = queryString
                .components(separatedBy: "&")
                .compactMap { item -> URLQueryItem? in
                    let pair = item.components(separatedBy: "=")
                    if pair.count == 2 {
                        return URLQueryItem(name: pair[0], value: pair[1])
                    }
                    return nil
                }

            components?.queryItems = queryItems
            return components?.url
        }

        // url 인코딩
        let httpsAdded = "https://" + trimmed
        return URL(string: httpsAdded.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? httpsAdded)
    }
}

