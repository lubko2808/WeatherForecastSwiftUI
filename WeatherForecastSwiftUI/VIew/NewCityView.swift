//
//  NewCityView.swift
//  WeatherForecastSwiftUI
//
//  Created by Любомир  Чорняк on 30.07.2023.
//

import SwiftUI

struct NewCityView: View {
    
    @Binding var chosenCity: String?
    
    @StateObject private var viewModel: NewCityViewModel
    
    init(dataService: DataService, chosenCity: Binding<String?>) {
        _chosenCity = chosenCity
        _viewModel = StateObject(wrappedValue: NewCityViewModel(dataService: dataService))
    }
    
    @Environment(\.dismiss) var dismissView
    
    enum Constants {
        static let invalidRow: Int = -1
    }
    
    @State private var selectedRow: Int = Constants.invalidRow
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                
                backgroundView
                
                VStack {
                    
                    TextField("enter the name of the city", text: $viewModel.textFieldText)
                        .foregroundColor(.white)
                        .font(.title)
                        .frame(height: 46)
                        .padding(.horizontal)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.white, lineWidth: 2)
                        }
                        .cornerRadius(20)
                        .padding()
                    
                    ScrollView {
                        LazyVStack {
                            ForEach(0..<viewModel.cities.count, id: \.self) { indexPath in
                                NewCityListRowView(city: viewModel.cities[indexPath], country: viewModel.countries[indexPath], sequenceNumber: indexPath)
                                    .scaleEffect(selectedRow == indexPath ? 1.3 : 1)
                                    .onTapGesture {
                                        withAnimation(.easeIn(duration: 0.2)) {
                                            selectedRow = indexPath
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            withAnimation(.easeIn(duration: 0.2)) {
                                                selectedRow = Constants.invalidRow
                                            }
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                            chosenCity = viewModel.cities[indexPath]
                                            dismissView()
                                        }
                                    }
                                    .padding(.vertical, 7)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Add city")
            .navigationBarTitleDisplayMode(.inline)
            .navigationAppearance(fontSize: 25)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        chosenCity = nil
                        dismissView()
                    } label: {
                        Text("cancel")
                            .foregroundColor(.white)
                            .font(.system(size: 22))
                    }

                    
                }
            }
            .alert("Error", isPresented: $viewModel.isError) {
                Button("OK", action: {})
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onDisappear {
                viewModel.cancelTasks()
            }
        }
    }
    
    private var backgroundView: some View {
        Image("background1")
            .resizable()
            .ignoresSafeArea()
            .blur(radius: 10)
            
    }
}

struct NewCityListRowView: View {
    
    let city: String
    let country: String
        
    @State private var startAnimation = false
    
    var sequenceNumber: Int
    
    var body: some View {
        
        Rectangle()
            .foregroundColor(Color.purple.opacity(0.5))
            .cornerRadius(20)
            .overlay(alignment: .leading) {
                
                VStack(alignment: .leading) {
                    
                    Text(city)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(country)
                        .font(.title2)
                        .foregroundColor(Color(uiColor: .lightText))
                    
                    
                }
                .padding(.horizontal)
                
            }
            .frame(height: 90)
            .offset(y: startAnimation ? 0 : 100)
            .opacity(startAnimation ? 1 : 0)
            .animation(.linear(duration: 0.5).delay(Double(sequenceNumber) * 0.05), value: startAnimation)
            .onAppear {
                startAnimation = true
                print("NewCityListRowView did appear")
            }
            .onDisappear {
                startAnimation = false
                print("NewCityListRowView did disappear")
            }

    }
}

struct NewCityView_Previews: PreviewProvider {
    static var previews: some View {
        NewCityView(dataService: DataService(), chosenCity: Binding.constant(nil))
    }
}

