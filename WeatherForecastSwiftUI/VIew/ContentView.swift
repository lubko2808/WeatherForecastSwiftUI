//
//  ContentView.swift
//  WeatherForecastSwiftUI
//
//  Created by Любомир  Чорняк on 28.07.2023.
//

import SwiftUI

struct MainView: View {
    
    @StateObject private var viewModel: MainViewModel
    
    @State private var path = NavigationPath()
    
    init(dataService: DataService) {
        _viewModel = StateObject(wrappedValue: MainViewModel(dataService: dataService))
    }
    
    var body: some View {
        
        NavigationStack(path: $path) {
            ZStack {
                
                BackgroundView()
                
                VStack(spacing: 60) {

                    HStack(alignment: .firstTextBaseline) {
                        currentTemp
                        dayAndNightTemp
                    }
                    .animation(.linear(duration: 0.5), value: viewModel.isDataReady)
                        
                    VStack(spacing: 15) {
                        ForEach(0..<viewModel.dayAndNightTemp.count, id: \.self) { index in
                            
                            WeatherForDay(weatherType: viewModel.weatherTypes[index], day: viewModel.days[index], dayAndNightTemp: viewModel.dayAndNightTemp[index], sequenceNumber: index)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.large)
                .navigationTitle(viewModel.currentCity)
                .toolbar(viewModel.currentCity.isEmpty ? .hidden : .visible)
                .animation(.linear(duration: 0.5), value: viewModel.currentCity)
                .navigationAppearance(fontSize: 50)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            
                        } label: {
                            NavigationLink(value: "CitiesListView") {
                                Text("city")
                                    .foregroundColor(.black)
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)
                                    .background(.white)
                                    .cornerRadius(25)
                            }
                        }
                    }
                }
                .alert("Error", isPresented: $viewModel.isError) {
                    Button("OK", action: {})
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }
                .navigationDestination(for: String.self) { _ in
                    CitiesListView(path: $path) { city in
                        viewModel.isDataReady = false
                        viewModel.fetchWeatherForCity(cityName: city)
                        viewModel.currentCity = city
                    }
                }
            }
        }
    }
    
    var currentTemp: some View {
        Text(viewModel.currentTemp)
            .font(.system(size: 100, weight: .medium))
            .fontDesign(.rounded)
            .opacity(viewModel.isDataReady ? 1 : 0)
            .foregroundColor(.white)
            .scaleEffect(viewModel.isDataReady ? 1 : 2)
    }
    
    var dayAndNightTemp: some View {
        Text(viewModel.dayAndNightTemp.isEmpty ? "" : viewModel.dayAndNightTemp[0])
            .font(.system(size: 25, weight: .medium))
            .fontDesign(.rounded)
            .opacity(viewModel.isDataReady ? 1 : 0)
            .foregroundColor(.white)
            .scaleEffect(viewModel.isDataReady ? 1 : 2)
    }
}


struct WeatherForDay: View {
    
    var weatherType: String
    var day: String
    var dayAndNightTemp: String
    
    var sequenceNumber: Int
    
    @State private var startAnimation = false
    
    @State private var offset: CGFloat = -500
    
    var body: some View {
        HStack {
            Image(systemName:  weatherType)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
            
            Text(day)
                .font(.system(.title))
                .foregroundColor(.white)
                .padding(.leading, 7)
            
            Spacer()
            
            Text(dayAndNightTemp)
                .font(.system(.body))
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.5))
        .cornerRadius(20)
        .padding(.horizontal)
        .offset(x: offset)
        .animation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0).delay(Double(sequenceNumber) * 0.05), value: offset)
        .onAppear {
            offset = 0
            print("WeatherForDay has appeared")
        }
        .onDisappear {
            offset = -500
            print("WeatherForDay has disappeared")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(dataService: DataService())
    }
}

struct NavigationBarAppearanceModifier: ViewModifier {
    
    init(fontSize: CGFloat) {
        let appearance = UINavigationBarAppearance()
        let textColor = UIColor.white
        
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
            .foregroundColor: textColor,
        ]
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
            .foregroundColor: textColor,
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func navigationAppearance(fontSize: CGFloat) -> some View {
        self.modifier(NavigationBarAppearanceModifier(fontSize: fontSize))
    }
}

struct BackgroundView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.6), Color("whiteBlue")]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}
