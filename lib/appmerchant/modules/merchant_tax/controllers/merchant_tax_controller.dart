import 'package:get/get.dart';

class TaxRate {
  final String id;
  final String name;
  final double rate;
  final bool isActive;

  TaxRate({
    required this.id,
    required this.name,
    required this.rate,
    this.isActive = true,
  });
}

class MerchantTaxController extends GetxController {
  final taxRates = <TaxRate>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    taxRates.assignAll([
      TaxRate(id: '1', name: 'VAT', rate: 15.0),
      TaxRate(id: '2', name: 'Service Charge', rate: 5.0),
      TaxRate(id: '3', name: 'Luxury Tax', rate: 10.0),
    ]);
  }

  void addTaxRate(String name, double rate) {
    taxRates.add(TaxRate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      rate: rate,
    ));
  }

  void toggleTaxStatus(int index) {
    var old = taxRates[index];
    taxRates[index] = TaxRate(
      id: old.id,
      name: old.name,
      rate: old.rate,
      isActive: !old.isActive,
    );
  }
}
