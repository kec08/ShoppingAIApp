import SwiftUI

struct MainView: View {
    @State private var products: [Product] = [] // 상품 데이터를 저장할 배열
    @State private var isShowingAddProduct = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("갤러리")
                        .font(.title)
                        .fontWeight(.bold)
                        .font(.system(size: 22))
                        .foregroundColor(.customBlack)
                    
                    Spacer()
                    
                    Button(action: {
                        // 편집 동작 (미구현)
                    }) {
                        Text("편집")
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 24)
                            .font(.system(size: 18))
                    }
                    
                    Button(action: {
                        isShowingAddProduct = true
                    }) {
                        Text("추가")
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .background(Color.white) // 상단 바 배경색
                
                if products.isEmpty {
                    // 상품이 없을 때 표시
                    Spacer()
                        .frame(height: 200)
                    
                    HStack {
                        VStack {
                            Image("Main_cart")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .padding(.bottom, 10)
                            
                            Text("아직 상품이 없습니다\n상품을 추가 해보세요!")
                                .font(.system(size: 20))
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                } else {
                    // 상품이 있을 때 갤러리 형태로 표시
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(products, id: \.id) { product in
                                VStack {
                                    if let image = product.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 150)
                                            .cornerRadius(10)
                                    } else {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 50)
                                            .foregroundColor(.gray)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.gray, lineWidth: 1)
                                            )
                                    }
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(product.name)
                                            .font(.system(size: 16))
                                            .fontWeight(.medium)
                                            .lineLimit(1)
                                        Text("카테고리: \(product.category)") // 카테고리 추가
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        Text("₩\(product.price)")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        Text("욕구: \(product.purchaseDesire)/10")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white) // 각 아이템 배경색
                                .cornerRadius(10)
                                .shadow(radius: 2)
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color.white) // 전체 배경색
            .sheet(isPresented: $isShowingAddProduct) {
                AddProductView(addProduct: { newProduct in
                    products.append(newProduct)
                }, onDismiss: {
                    isShowingAddProduct = false
                })
            }
        }
    }
}

// 상품 모델 (카테고리 필드 추가)
struct Product: Identifiable {
    let id = UUID()
    var image: UIImage?
    var name: String
    var price: String
    var url: String
    var purchaseDesire: Int
    var usageContext: String
    var features: String
    var category: String // 새로운 카테고리 필드
}

#Preview {
    MainView()
}
