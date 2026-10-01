import ConfigCore

final class Config: ConfigCore {
  required init() {
    Self.options.cacheAll = true
  }

  @UserDefault("fingers")
  var minimumFingers = 3

  @UserDefault var allowMoreFingers = false

  @UserDefault var maxDistanceDelta: Float = 0.05

  /// In milliseconds
  @UserDefault(transformGet: { $0 / 1000 })
  var maxTimeDelta = 300.0

  @UserDefault var tapToClick = SystemPermissions.getIsSystemTapToClickEnabled

  /// When false, physical clicks are left alone (e.g. two-finger click stays a right click)
  /// and only taps produce a middle click.
  @UserDefault var emulateOnClick = true

  @UserDefault var ignoredAppBundles = Set<String>()
}
