/// Central switch for every form of monetization: ads, in-app purchases,
/// and anything else that brings in money.
///
/// Kept at `false` until Philip gives the go-ahead (business registration
/// of BENDER INTERACTIVE is postponed over open questions with the
/// Finanzamt). The app then runs as a free version with no ads and no
/// income. Code is gated, not deleted; how to turn it back on is in
/// `MONETIZATION_DISABLED.md` at the repo root. No store submission and
/// no production deploy without Philip's OK.
const bool monetizationEnabled = false;
