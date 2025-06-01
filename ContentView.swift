import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            KalkulatorView()
                .tabItem {
                    Label("Kalkulator", systemImage: "function")
                }
            MaterialienView()
                .tabItem {
                    Label("Materialien", systemImage: "cube.box")
                }
            ParameterView()
                .tabItem {
                    Label("Parameter", systemImage: "gearshape")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
