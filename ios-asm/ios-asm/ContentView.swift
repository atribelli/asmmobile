//
//  ContentView.swift
//  ios-asm
//

import SwiftUI

let asmWrapper = AsmWrapper()
let hexString  = asmWrapper.getHexString(0x0123456789abcdef) ?? "{error}"

struct ContentView: View {
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text("The hex value is " + hexString)
         }
        .padding()
    }
}

#Preview {
    ContentView()
}
