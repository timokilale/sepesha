import 'package:ipf_flutter_starter_pack/bases.dart';
import 'package:ipf_flutter_starter_pack/services.dart';

void main() {
  List<BaseModelGenerator> generator = [];
  CodeGenerator.of('sepesha_app', generator).generate();
}
