import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// The web implementation of the zuraffa_intents plugin.
///
/// Receiving shares on web is an app-level concern: the PWA's
/// `share_target` manifest entry routes the OS share sheet to a launch URL,
/// and the app parses it on boot. The source plugin this package replaces
/// shipped the same shape (a registration stub); this class keeps the
/// plugin declaration honest on web rather than pretending the native
/// receive path exists there.
class ZuraffaIntentsWeb {
  /// Registers the web plugin with the Flutter web plugin registrar.
  static void registerWith(Registrar registrar) {
    // Intentionally no channel wiring: web receive is documented as an
    // app-level share_target flow (see README — Platform support).
  }
}
