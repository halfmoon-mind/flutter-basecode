import 'package:template/app/app.dart';
import 'package:template/bootstrap.dart';
import 'package:template/core/configs/env_config.dart';

void main() {
  EnvConfig.initialize(AppFlavor.staging);
  bootstrap(() => const App());
}
