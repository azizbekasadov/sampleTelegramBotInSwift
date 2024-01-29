import Cocoa
import Foundation
import TelegramBotSDK

let bot = TelegramBot(token: "BOT_TOKEN_HERE")

// Define the command for downloading TikTok images and videos
bot.onCommand("download") { context in
    let args = context.args
    if args.isEmpty {
        context.respondAsync("Please provide a TikTok post URL.")
        return
    }

    let urlString = args[0]

    // Fetch the TikTok post data using the provided URL
    let task = URLSession.shared.dataTask(with: URL(string: urlString)!) { data, response, error in
        guard let data = data, error == nil else {
            context.respondAsync("Failed to download TikTok post data.")
            return
        }

        // Parse the TikTok post data to extract the image/video URL
        let postData = try! JSONDecoder().decode(TikTokPostData.self, from: data)

        // Download the image/video
        let mediaTask = URLSession.shared.dataTask(with: URL(string: postData.mediaURL)!) { mediaData, mediaResponse, mediaError in
            guard let mediaData = mediaData, mediaError == nil else {
                context.respondAsync("Failed to download TikTok media.")
                return
            }

            // Save the downloaded media data to a file
            let fileName = postData.mediaURL.components(separatedBy: "/").last!
            let fileURL = URL(fileURLWithPath: fileName)
            try! mediaData.write(to: fileURL)

            // Send the saved media file to the user
            context.respondWithDocument(document: fileURL)
        }

        mediaTask.resume()
    }

    task.resume()
}

// Start the bot
bot.startPolling().wait()
