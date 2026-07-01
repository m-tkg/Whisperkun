import Foundation
import OSLog
import whisperkunCore

private let log = Log.logger(category: "update")

/// 公開 GitHub API（api.github.com）へ URLSession でアクセスし、リリースの取得・ダウンロードを行う。
/// public リポジトリのため認証は不要。
struct UpdateService {
    static let repoFullName = "m-tkg/whisperkun"
    static let apiBase = "https://api.github.com"
    private static let userAgent = "whisperkun"

    /// 更新チェックは常に最新を取得したいので、キャッシュを使わない専用セッションを用いる。
    /// （GitHub API は `cache-control: max-age=60` を返すため、共有セッションだと古い結果が返る）
    private let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        return URLSession(configuration: config)
    }()

    enum ServiceError: LocalizedError {
        case requestFailed(Int)
        case decodeFailed
        case noZipAsset
        case downloadFailed(Int)

        var errorDescription: String? {
            switch self {
            case .requestFailed(let code):
                return String(localized: "リリース情報の取得に失敗しました（HTTP \(code)）。")
            case .decodeFailed:
                return String(localized: "リリース情報の解析に失敗しました。")
            case .noZipAsset:
                return String(localized: "リリースに zip アセットが見つかりませんでした。")
            case .downloadFailed(let code):
                return String(localized: "ダウンロードに失敗しました（HTTP \(code)）。")
            }
        }
    }

    /// 最新リリース情報を取得する。
    func fetchLatestRelease() async throws -> ReleaseInfo {
        let url = URL(string: "\(Self.apiBase)/repos/\(Self.repoFullName)/releases/latest")!
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw ServiceError.requestFailed(-1)
        }
        guard (200..<300).contains(http.statusCode) else {
            throw ServiceError.requestFailed(http.statusCode)
        }
        guard let release = try? JSONDecoder().decode(ReleaseInfo.self, from: data) else {
            throw ServiceError.decodeFailed
        }
        return release
    }

    /// リリースの zip アセットを `directory` にダウンロードし、保存先 URL を返す。
    func downloadReleaseZip(_ release: ReleaseInfo, into directory: URL) async throws -> URL {
        guard let assetURL = release.zipAssetURL else {
            throw ServiceError.noZipAsset
        }
        log.info("Downloading release \(release.tagName, privacy: .public) from \(assetURL.absoluteString, privacy: .public)")

        var request = URLRequest(url: assetURL)
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")

        let (tempURL, response) = try await session.download(for: request)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw ServiceError.downloadFailed(http.statusCode)
        }

        let destination = directory.appendingPathComponent("Whisperkun.zip")
        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.moveItem(at: tempURL, to: destination)
        return destination
    }
}
