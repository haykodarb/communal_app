// Feature switches for parts of the app that exist but aren't offered yet.
class Features {
  /// Communities are being replaced by the friends-of-friends network. The
  /// pages stay in the code base, but every /communities URL redirects to My
  /// Books and nothing links to them (the drawer item is hidden too).
  static const bool communitiesEnabled = false;
}
