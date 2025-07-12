//
//  MainView.swift
//  ShoppingAI
//
//  Created by 김은찬 on 7/12/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack(){
            HStack{
                Text("갤러리")
                    .font(.title)
                    .fontWeight(.bold)
                    .font(.system(size: 22))
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text("편집")
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 24)
                        .font(.system(size: 18))
                }
                
                Button(action: {
                    
                }) {
                    Text("추가")
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                }
                
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            
            Spacer()
                .frame(height: 200)
            
            HStack{
                VStack{
                    Image("Main_cart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding(.bottom, 10)
                    
                    Text("아직 상품이 없습니다\n상풍을 추가 해보세요!")
                        .font(.system(size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            
        }
            
    }
}

#Preview {
    MainView()
}
