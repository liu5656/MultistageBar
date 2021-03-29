//
//  widget.swift
//  widget
//
//  Created by x on 2021/3/25.
//  Copyright © 2021 x. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Poetry {
    let content: String
    let origin: String
    let author: String
}

struct PoetryEntry: TimelineEntry {
    var date: Date
    let poetry: Poetry
}


struct PoetryRequest {
    static func request(completion: @escaping (Result<Poetry, Error>) -> Void) {
        let url = URL(string: "https://v1.alapi.cn/api/shici?type=shuqing")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            let poetry = poetryFromJson(fromData: data!)
            completion(.success(poetry))
        }
        task.resume()
    }
    
    static func poetryFromJson(fromData data: Data) -> Poetry {
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        //因为免费接口请求频率问题，如果太频繁了，请求可能失败，这里做下处理，放置crash
        guard let data = json["data"] as? [String: Any] else {
            return Poetry(content: "诗词加载失败，请稍微再试！", origin: "无", author: "无")
        }
        let content = data["content"] as! String
        let origin = data["origin"] as! String
        let author = data["author"] as! String
        return Poetry(content: content, origin: origin, author: author)
    }
}

struct PoetryWidgetView: View {
    let entry: PoetryEntry
    
    let colors: [Color] = [.init(red: 144 / 255.0, green: 252 / 255.0, blue: 231 / 255.0), .init(red: 50 / 204, green: 188 / 255.0, blue: 231 / 255.0)]
    
    var body: some View{
        Link.init(destination: URL.init(string: "https://www.multistagebar.com")!) {
            VStack(alignment: .center, spacing: 4) {
                Text(entry.poetry.origin).font(.system(size: 20)).fontWeight(Font.Weight.bold)
                Text(entry.poetry.author).font(.system(size: 16)).fontWeight(Font.Weight.medium)
                Text(entry.poetry.content).font(.system(size: 18)).fontWeight(Font.Weight.regular)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}

struct PoetryProvider: TimelineProvider {
    func placeholder(in context: Context) -> PoetryEntry {
        let poetry = Poetry.init(content: "床前明月光,疑似地上霜", origin: "唐", author: "李白")
        return PoetryEntry.init(date: Date(), poetry: poetry)
    }
    func getSnapshot(in context: Context, completion: @escaping (PoetryEntry) -> Void) {
        let poetry = Poetry.init(content: "床前明月光,疑似地上霜", origin: "唐", author: "李白")
        let entry = PoetryEntry.init(date: Date(), poetry: poetry)
        completion(entry)
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<PoetryEntry>) -> Void) {
        let currentDate = Date()
        let updateDate   = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)
        PoetryRequest.request { (result) in
            let poetry: Poetry
            if case .success(let response) = result {
                poetry = response
            }else{
                poetry = Poetry.init(content: "诗词加载失败,请稍后再试", origin: "无", author: "无")
            }
            let entry = PoetryEntry.init(date: currentDate, poetry: poetry)
            let timeline = Timeline.init(entries: [entry], policy: .after(updateDate!))
            completion(timeline)
        }
    }
}

@main
struct PoetryWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration.init(kind: "PoetryWidget", provider: PoetryProvider()) { entry in
            PoetryWidgetView(entry: entry)
        }
        .configurationDisplayName("诗歌")
        .description("默诵全文")
    }
}


