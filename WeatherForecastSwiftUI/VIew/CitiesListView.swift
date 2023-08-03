//
//  CitiesListView.swift
//  WeatherForecastSwiftUI
//
//  Created by Любомир  Чорняк on 30.07.2023.
//

import SwiftUI

struct CitiesListView: View {
    
    @StateObject var viewModel = CitiesListViewModel()
    
    @State private var showNewCityView = false
    @State private var cityToAdd: String? = nil

    @Binding var path: NavigationPath
    
    var onDismiss: ((_ city: String) -> Void)?
    
    @State private var isRowPressed = false
    @State private var selectedRow: Int = -1
    
    var body: some View {

        ZStack {
            
            backgroundView
            
            if !viewModel.cities.isEmpty {
                
                List {
                    ForEach(0..<viewModel.cities.count, id: \.self) { index in
                        CitiesListRowView(cityName: viewModel.cities[index])
                            .listRowBackground(Color(uiColor: .clear))
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    viewModel.deleteCity(at: viewModel.cities.count - index - 1)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                            }
                            .scaleEffect(selectedRow == index ? 1.3 : 1)
                            .onTapGesture {
                                withAnimation(.easeIn(duration: 0.2)) {
                                    selectedRow = index
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.easeIn(duration: 0.2)) {
                                        selectedRow = -1
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    self.onDismiss?(viewModel.cities[index])
                                    path.removeLast()
                                }
                            }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.inset)
            
            } else {
                Color.clear
            }
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always) ,prompt: "Search cities...")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    path.removeLast()
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showNewCityView.toggle()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
                
            }
        }
        .alert("Error", isPresented: $viewModel.isError) {
            Button("OK", action: {})
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showNewCityView, onDismiss: {
            if let cityToAdd {
                viewModel.addNewCity(name: cityToAdd)
            }
        }, content: {
            NewCityView(dataService: DataService(), chosenCity: $cityToAdd)
        })
    }
        
    private var backgroundView: some View {
        Image("background")
            .resizable()
            .ignoresSafeArea()
            .blur(radius: 10)
    }
}

struct CitiesListRowView: View {
    
    let cityName: String
    
    var body: some View {
        
        Rectangle()
            .foregroundColor(Color.gray.opacity(0.5))
            .cornerRadius(20)
            .overlay {
                Text(cityName)
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .frame(height: 60)
    }
}


struct CitiesListView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationStack {
            //CitiesListView()
        }
    }
}
