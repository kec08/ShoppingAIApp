import SwiftUI

struct MainView: View {
    @State private var products: [Product] = []
    @State private var isShowingAddProduct = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("갤러리")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    Spacer()

                    Button(action: {
                        // 편집 기능 (필요시 구현)
                    }) {
                        Text("편집")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 15)
                    }

                    Button(action: {
                        isShowingAddProduct = true
                    }) {
                        Text("추가")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)

                if products.isEmpty {
                    Spacer()
                        .frame(height: 200)

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
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(products) { product in
                                NavigationLink(destination: ProductDetailView(product: product)) {
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
                        }
                        .padding()
                    }
                }
            }
            .background(Color.white)
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
