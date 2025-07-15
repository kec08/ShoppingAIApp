import SwiftUI

struct MainView: View {
    @State private var products: [Product] = []
    @State private var isShowingAddProduct = false
    @State private var selectedProduct: Product?
    // Product 모델을 기반으로 AI 질문용 제품만 필터링
    @State private var aiTargetProducts: [Product] = []
    // Q 버튼 클릭 시 AIanswerView로 이동
    @State private var isShowingAIAnswer = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    headerView

                    if products.isEmpty {
                        emptyStateView
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 15) {
                                ForEach(products) { product in
                                    Button {
                                        selectedProduct = product
                                    } label: {
                                        productCard(product)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }

                ZStack(alignment: .topTrailing) {
                    Button(action: {
                        isShowingAIAnswer = true
                    }) {
                        Image("Main_Q_Buttom")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .shadow(radius: 4)
                            .opacity(aiTargetProducts.count >= 2 ? 1.0 : 0.5)
                    }
                    .disabled(aiTargetProducts.count < 2)
                    .sheet(isPresented: $isShowingAIAnswer) {
                        AIanswerView(products: aiTargetProducts)
                    }
                    
                    if aiTargetProducts.count > 0 {
                        Text("\(aiTargetProducts.count)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black)
                            .clipShape(Circle())
                            .offset(x: 10, y: -10)
                    }
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24)
            }
            .background(Color.white.ignoresSafeArea())

            .sheet(isPresented: $isShowingAddProduct) {
                AddProductView(addProduct: { newProduct in
                    products.append(newProduct)
                }, onDismiss: {
                    isShowingAddProduct = false
                })
            }

            .sheet(item: $selectedProduct) { product in
                ProductDetailView(product: product) {
                    products.append(product)
                    aiTargetProducts.append(product)
                    selectedProduct = nil
                }
            }
        }
    }


    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text("갤러리")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)

            Spacer()

            Button("편집") {}
                .foregroundColor(.gray)
                .padding(.horizontal, 15)

            Button("추가") {
                isShowingAddProduct = true
            }
            .foregroundColor(.gray)
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
    }

    // MARK: - Empty View

    private var emptyStateView: some View {
        VStack {
            Spacer().frame(height: 200)

            VStack {
                Image(systemName: "cart")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
                    .padding(.bottom, 15)

                Text("아직 상품이 없습니다\n상품을 추가 해보세요!")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
    }

    // MARK: - 상품 카드뷰

    private func productCard(_ product: Product) -> some View {
        HStack(spacing: 15) {
            if let image = product.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(product.category)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)

                Text(product.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)

                Text("₩ \(product.price)")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .fontWeight(.bold)

                Text("욕구: \(product.purchaseDesire) / 10")
                    .font(.system(size: 14))
                    .foregroundColor(.customRed)
                    .fontWeight(.bold)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

