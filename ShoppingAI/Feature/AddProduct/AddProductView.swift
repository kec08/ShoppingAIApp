import SwiftUI

struct AddProductView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var productName = ""
    @State private var productPrice = ""
    @State private var productURL = ""
    @State private var purchaseDesire: Double = 5.0
    @State private var usageContext = ""
    @State private var productFeatures = ""
    @FocusState private var focusedField: Field?
    @State private var isImagePickerPresented = false

    enum Field: Hashable {
        case productName, productPrice, productURL, usageContext, productFeatures
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // 이미지 업로드 섹션
                ZStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                            .foregroundColor(.gray)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    Text("사진 추가")
                        .foregroundColor(.customRed)
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(image: $selectedImage)
                }
                
                // 입력 필드
                Group {
                    TextField("상품 이름", text: $productName)
                        .focused($focusedField, equals: .productName)
                        .modifier(UnderlineTextField(isFocused: focusedField == .productName, text: $productName, placeholder: "상품 이름"))
                    TextField("가격 (원)", text: $productPrice)
                        .focused($focusedField, equals: .productPrice)
                        .keyboardType(.numberPad)
                        .modifier(UnderlineTextField(isFocused: focusedField == .productPrice, text: $productPrice, placeholder: "가격 (원)"))
                    TextField("URL", text: $productURL)
                        .focused($focusedField, equals: .productURL)
                        .modifier(UnderlineTextField(isFocused: focusedField == .productURL, text: $productURL, placeholder: "URL"))
                    
                    VStack(spacing: 5) {
                        Text("구매 욕구: \(Int(purchaseDesire))")
                            .font(.caption)
                        Slider(value: $purchaseDesire, in: 0...10, step: 1)
                            .accentColor(.red)
                    }
                    .padding(.top, 15)
                    
                    TextField("사용 용도 및 상황", text: $usageContext)
                        .focused($focusedField, equals: .usageContext)
                        .modifier(UnderlineTextField(isFocused: focusedField == .usageContext, text: $usageContext, placeholder: "사용 용도 및 상황"))
                    TextField("상품 특징", text: $productFeatures)
                        .focused($focusedField, equals: .productFeatures)
                        .modifier(UnderlineTextField(isFocused: focusedField == .productFeatures, text: $productFeatures, placeholder: "상품 특징"))
                }
                .padding(.vertical, 15)
                
                // 버튼
                HStack(spacing: 10) {
                    Button("취소하기") {
                        // 취소 동작
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 45)
                    .frame(minWidth: 130)
                    .background(Color.customGray)
                    .foregroundColor(.gray)
                    .cornerRadius(10)
                    .font(.system(size: 16, weight: .bold))
                    
                    Button("추가하기") {
                        // 추가 동작
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 45)
                    .frame(minWidth: 130)
                    .background(Color.customRed)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .font(.system(size: 16, weight: .bold))
                }
                .padding(.top, 20)
            }
            .padding()
            .background(Color.white)
        }
        .background(Color.white)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationTitle("상품 추가")
    }
}

struct UnderlineTextField: ViewModifier {
    let isFocused: Bool
    @Binding var text: String
    let placeholder: String
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(text.isEmpty ? .gray : .customBlack) // 입력 전 .gray, 입력 후 .customBlack
            .placeholder(when: text.isEmpty) {
                Text(placeholder)
                    .foregroundColor(.gray) // 플레이스홀더 색상 명시적으로 .gray로 설정
            }
            .disabled(false)
            .padding(.vertical, 8)
            .overlay(
                Rectangle()
                    .frame(height: isFocused ? 2 : 1)
                    .foregroundColor(isFocused ? .red : .gray)
                    .padding(.top, 28)
            )
    }
}

// 플레이스홀더 확장
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow {
                placeholder()
            }
            self
        }
    }
}

// 이미지 피커
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}


struct AddProductView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddProductView()
        }
    }
}

#Preview {
    AddProductView()
}
