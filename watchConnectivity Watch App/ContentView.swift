//
//  ContentView.swift
//  watchConnectivity Watch App
//
//  Created by cumulations on 20/06/23.
//

import SwiftUI
import WatchConnectivity

class SessionDelegate: NSObject,ObservableObject, WCSessionDelegate {
    @Published var messageFromPhone = ""

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle session activation completion
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
                self.messageFromPhone = text
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var sessionDelegate = SessionDelegate()
    @State private var messageToPhone = ""

    var body: some View {
        VStack {
            TextField("Message to Phone", text: $messageToPhone)
                .padding()
            Text("Message from Phone: \(sessionDelegate.messageFromPhone)")
                .padding()
            Button("Send Message") {
                sendMessageToPhone()
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

    private func sendMessageToPhone() {
        let session = WCSession.default
        if session.isReachable {
            let message = ["text": messageToPhone]
            session.sendMessage(message, replyHandler: nil, errorHandler: nil)
            messageToPhone = ""
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
