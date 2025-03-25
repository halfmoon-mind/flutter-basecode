import 'package:template/bootstrap.dart';
import 'package:template/core/configs/env_config.dart';

void main() {
  EnvConfig.initialize(AppFlavor.production);
  bootstrap();
}
