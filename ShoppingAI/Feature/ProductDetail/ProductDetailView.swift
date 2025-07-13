import SwiftUI

struct ProductDetailView: View {
    let product: Product
    var onAdd: (() -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                if let image = product.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                        )
                        .cornerRadius(12)
                }
                
                Group {
                    DetailSection(title: "카테고리", content: product.category)
                    DetailSection(title: "상품 이름", content: product.name)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("₩ \(formattedPrice(product.price))")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.customBlack)
                    }
                    
                    DetailSection(title: "구매 욕구", content: "\(product.purchaseDesire) / 10")
                    
                    if !product.url.isEmpty, let url = URL(string: product.url) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("상품 링크")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Link(destination: url) {
                                Text(product.url)
                                    .font(.system(size: 18))
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                        }
                    }

                    DetailSection(title: "사용 용도 및 상황", content: product.usageContext)
                    DetailSection(title: "상품 특징", content: product.features)
                }

                Spacer(minLength: 30)

                Button(action: {
                    onAdd?()
                }) {
                    Text("추가하기")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.customRed)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("상품 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .background(Color.white.edgesIgnoringSafeArea(.bottom))
    }

    private func formattedPrice(_ price: String) -> String {
        if let number = Int(price) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter.string(from: NSNumber(value: number)) ?? price
        } else {
            return price
        }
    }
}

struct DetailSection: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)

            Text(content.isEmpty ? "정보 없음" : content)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

