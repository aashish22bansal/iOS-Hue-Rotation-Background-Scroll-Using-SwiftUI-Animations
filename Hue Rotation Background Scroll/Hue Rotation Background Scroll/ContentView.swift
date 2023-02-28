//
//  ContentView.swift
//  Hue Rotation Background Scroll
//
//  Created by Aashish Bansal on 28/02/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var hueRotation = false
    
    // Obtaining the background images
    var backgrounds = ["img1", "img2", "img3", "img4", "img5", "img6", "img7", "img8", "img9", "img10", "img11", "img12", "img13"].shuffled()
    
    var body: some View {
        // GeometryReader is used to place all the background images outside the Screen area
        /// GeometryReader will allow us to set the width and height perfectly for any device
        GeometryReader{ geo in // Closure being used to loop over background images
            BackgroundScroll(imageCount: backgrounds.count){
                ForEach(0 ..< backgrounds.count){number in
                    Image(backgrounds[number])
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped() /// This will make sure that we get only the specific image on the screen and not any other image
                }
            }
            .hueRotation(.degrees(hueRotation ? 10:500))
            .animation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: true))
            .onAppear(){
                hueRotation.toggle()
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

struct BackgroundScroll<ViewContent: View>: View{
    private var imageCount: Int /// Keeps a count of the number of images
    private var contentContainer: ViewContent /// Acts like a container to store images as an HStack
    @State private var workingIndex: Int = 0 /// Keeps track of the current Index of the Image being displayed as a wallpaper on the screen
    private let timer = Timer.publish(every: 5, on: .main, in: .default).autoconnect() /// Triggered at regular intervals of time to change the background by publishing events
    
    init(imageCount: Int, @ViewBuilder content: () -> ViewContent){
        self.imageCount = imageCount
        self.contentContainer = content() /// This is a closure which returns the content() object.
    }
    
    var body: some View{
        GeometryReader{geo in
            ZStack(alignment: .bottom){ /// This will put the paging dots at the bottom of the screen
                HStack(spacing: 0){ /// Since spacing is 0, so the images will touch as they scroll
                    contentContainer /// This will display that particular image from the container
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
                .offset(x: CGFloat(self.workingIndex) * -geo.size.width, y: 0) /// Setting the position of the screen with respect to the previous image and screen size
                .animation(.easeInOut)
                .onReceive(timer){_ in
                    workingIndex = (workingIndex + 1) % (imageCount == 0 ? 1:imageCount) /// From the event published, this will trigger the change to let imageIndex update
                }
                
                // The pageing dots will be added in a separate HStack
                HStack(spacing: 7){
                    ForEach(0..<imageCount){index in
                        Circle()
                            .frame(width: index == workingIndex ? 13:9, height: index == workingIndex ? 13:9)
                            .foregroundColor(index == workingIndex ? .white:.gray)
                            .overlay(Circle().stroke(Color.black, lineWidth: 1))
                            .padding(.bottom, 20)
                            .animation(.easeInOut)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
