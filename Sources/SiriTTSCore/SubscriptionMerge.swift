import Foundation

/// `DaemonSession.subscribe(voices:)` replaces the caller's whole subscription
/// set. Sending only the newly requested voice silently unsubscribes every
/// voice this client installed earlier, and the daemon then stops reporting
/// those voices as usable. Installs therefore send the existing set plus the
/// new voice.
enum SubscriptionMerge {
    /// Apple normalizes subscription rows (`th-TH:neural:undefined:th-TH-A:undefined:0`),
    /// so gender, footprint and version cannot be compared. Language and name
    /// are the stable part of the identity.
    static func identity(ofAssetKey assetKey: String) -> String {
        let parts = assetKey.split(separator: ":", omittingEmptySubsequences: false)
        guard parts.count >= 4 else { return assetKey.lowercased() }
        return "\(parts[0])|\(parts[3])".lowercased()
    }

    /// Returns `existing` with `new` appended, dropping any existing entry for
    /// the same voice so the request carries the freshly built identity.
    static func merged<Voice>(
        adding new: Voice,
        to existing: [Voice],
        assetKey: (Voice) -> String
    ) -> [Voice] {
        let target = identity(ofAssetKey: assetKey(new))
        var seen = Set<String>([target])
        var result: [Voice] = []
        for voice in existing {
            let key = identity(ofAssetKey: assetKey(voice))
            if seen.insert(key).inserted { result.append(voice) }
        }
        result.append(new)
        return result
    }
}
