import SwiftUI
import MessageUI

public struct MessageComposeView: UIViewControllerRepresentable {
    public var recipient: String
    public var body: String
    public var onComplete: (MessageComposeResult) -> Void

    public init(
        recipient: String,
        body: String,
        onComplete: @escaping (MessageComposeResult) -> Void
    ) {
        self.recipient = recipient
        self.body = body
        self.onComplete = onComplete
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator
        controller.recipients = [recipient]
        controller.body = body
        return controller
    }

    public func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}

    public static func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }

    public class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: MessageComposeView

        init(_ parent: MessageComposeView) {
            self.parent = parent
        }

        public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true) {
                self.parent.onComplete(result)
            }
        }
    }
}
