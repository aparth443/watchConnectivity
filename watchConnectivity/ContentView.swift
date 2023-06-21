//
//  ContentView.swift
//  watchConnectivity
//
//  Created by cumulations on 20/06/23.
//

import SwiftUI
import WatchConnectivity

class SessionDelegate: NSObject, ObservableObject, WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    

    @Published var messageFromWatch = ""
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            // Session is activated and ready for communication
            print("WatchOS session activated")
        case .inactive:
            // Session is inactive, possibly due to being in the background
            print("WatchOS session inactive")
        case .notActivated:
            // Session failed to activate
            print("WatchOS session not activated")
        @unknown default:
            print("WatchOS session unknown activation state")
        }
        
        if let error = error {
            // Handle any errors that occurred during activation
            print("WatchOS session activation error: \(error.localizedDescription)")
        }
    }


    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let text = message["text"] as? String {
                self.messageFromWatch = text
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var sessionDelegate = SessionDelegate()
    @State private var messageToWatch = ""

    var body: some View {
        VStack {
            TextField("Message to Watch", text: $messageToWatch)
                .padding()
            Text("Message from Watch: \(sessionDelegate.messageFromWatch)")
                .padding()
            Button("Send Message to Watch") {
                sendMessageToWatch()
            }
        }
        .onAppear {
            if WCSession.isSupported() {
                let session = WCSession.default
                session.delegate = sessionDelegate
                session.activate()
            }
        }
    }

    private func sendMessageToWatch() {
        let session = WCSession.default
        if session.isReachable {
            let message = ["text": messageToWatch]
            session.sendMessage(message, replyHandler: nil, errorHandler: nil)
            messageToWatch = ""
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
