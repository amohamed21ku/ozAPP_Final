import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gsheets/gsheets.dart';

class GsheetAPI {
  final String SelectedItems;
  GsheetAPI({required this.SelectedItems});

  static const _credentials = r'''
{
  "type": "service_account",
  "project_id": "gsheetoz",
  "private_key_id": "454cf1b2ccc44327ee153d6d0a6bab20469230dc",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDPy/TUkp6Vbw7w\n1C497e+MH3g2v5dsZPmt5j5trVAEg/vRHZ/OsDcMixWGgpOsEwnxAYocU235cKaE\n+ZR3NSX4pWerIjJqFPfns6bHX1d5IUa46NpRyLvDpH0++L9LnIijroRuwjZW/SJz\n7hlpo6EWV0Cb8I2Iwcy8RtZTCw3/xToz8B/rZKyhdhnoR7V4xJzIqvbRLQZ8bN0O\nOSgnpUy809LozUD4XjwEAJTlhkpM5fPB0xYo3ludYDFWV6Rge+AHYPF41B5OFANZ\n5YsHuXYUTpW6eBw/DbR3LM9IXiAeF2WPet4w8nWziZMuHJsjQuZWtYI/vLTmxS78\njCUX5IgXAgMBAAECggEABR+bQzktXAk1v9/u+p16sgD997HUiEw3SY3SUOXAEBqp\nbguFuRTL3cmkHsjOF4ibwHnTzAwb5irqjmM8FqsGQIqpukFBtaD/ZD11Zgm4UhVC\ng7MXaoLPiCW1yUuVev8BnFwA30DpEk7lfnYKxUDPB6bDwg1uqpuNjtyifU5Z6pFB\nuVA/A8JyuXNA8Mb0OKC4eF2h0n7Yrzj4oYTOpz0VhwffqUqLoS1xDMRB5Zmdibkv\nKKbVEzAroyqgMwavr8Zxvz8QWOcdE19CH+onE3wC7cpAt7bkZPVnWi4RVQRJZdS8\naX85c3dqXD4zxmyYFzvfY41x80NXjeeaLXfe+GzgAQKBgQD2adw52B6Dpz26T6Nz\nFndMrET5SaXlaQofDKbOgP0AGX+HxnxTSmbX2pzrA7XyL+omLB4tpa3Uq3Hm9oy9\nHdN8fE0oAy1t7Kl3C3HzFhlQwv+zBpsgGasytaT0RZ74X75Xt1O4VhQbls+CT0In\nrBa82JN/ixJkg9FyBV1zZT2wAQKBgQDX4X6S1Ha4bCru6i1+CUsCT0o8YxJgGd2H\nTnZjFDUE9UcoXBLs+++uKrIw4l3MIi9vAy5S9FH3F85RgXe0VRE8xxkh2XCUs77F\nHnmG9jA/pdyUVuAwZc72WoWgd6xXqGS0NVSJXFeKaoNjYcvP0gJ3tKzxCxo1ttKz\nsfo4eNm4FwKBgQCv2t67PVyRkmJAO6Ond8oOIwdabVACyBLcE9hbmbx1PL1B9co2\nWuvIcpD4O/62Z7GQKn4jD5FeLDiunxfTw5xxw/gAbTwXrgVHGxjoZcYNWAzKBBXj\nM8508yNU3PbVxOZ/jSsna+8PvXI8SjopO+xCO8IQDP1EVLq9x8xolUEQAQKBgCIG\n/wZxyszC7/l8m/MTz+jrSo4+J3VSXmKncW2oj7raVn78FFeaVmsje7bM13AHq2Za\nIAEfVZQXAoRCXfXkurTTxRhax64IrvcvGIS3ZV+C60POdcPrKDYYipuCgX3Hoyfs\niAimr3230EHn9lIpjg4EQoYz88unp4p/cStZkSe9AoGBAJKQ9NmdO/FoOBFEHoAr\n7oCqYEt+kztnyXaC/1RR4qrVNEd5lZndDiGjgI5aNvODgJVG7sL0lm4YugRuNr/Y\n1fplQEdpNCuUJemYNaCqpT28l3IBEmzu4yWMxqYbcdKThU4tmBw1yazEmJ26W0U3\na4qSjv46tO/Mukv7dvbdcOPL\n-----END PRIVATE KEY-----\n",
  "client_email": "gsheetoz@gsheetoz.iam.gserviceaccount.com",
  "client_id": "110937739275803744550",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheetoz%40gsheetoz.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
  ''';

  static final _spreadsheetId = '1sSOWqyP0VTg_Qn-Bo_dUeG20lTmrUcSXaVniPZ56sIU';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? worksheet;

  Future<void> init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    worksheet = ss.worksheetByTitle(SelectedItems) ??
        await ss.addWorksheet(SelectedItems);
  }

  // Future<void> print_SHEET() async {
  //   final sheetData = await fetchSheetData();
  //   print(sheetData);
  // }
  //
  // Future<void> print_SHEET2() async {
  //   final sheetData = await fetchFirestoreData();
  //   print(sheetData);
  // }

  Future<List<Map<String, dynamic>>> fetchSheetData() async {
    await init();

    final rows = await worksheet!.values.allRows();
    List<Map<String, dynamic>> items = [];

    if (rows.isEmpty || rows[0].isEmpty) {
      return items;
    }

    final headers = rows[0];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];

      if (row.isEmpty || row[0].isEmpty) {
        continue;
      }

      Map<String, dynamic> item = {};
      for (int j = 0; j < headers.length; j++) {
        if (headers[j] == 'S/Item No.') {
          headers[j] = 'Item No';
        }
        if (headers[j] == 'S/Item Name') {
          headers[j] = 'Item Name';
        }
        item[headers[j]] = row.length > j ? row[j] : '';
      }
      item.remove('price');
      item.remove('C/F');
      item.remove('date');

      // Constructing Previous_Prices as an array of maps
      List<Map<String, dynamic>> previousPrices = [];
      for (int j = 11; j < row.length; j += 3) {
        if (row[j].isNotEmpty || row.length > j + 2) {
          Map<String, dynamic> priceMap = {
            'price': row.length > j ? row[j] : '',
            'date': row.length > j + 1 ? row[j + 2] : '',
            'C/F': row.length > j + 2 ? row[j + 1] : ''
          };
          previousPrices.add(priceMap);
        }
      }

      item['Previous_Prices'] = previousPrices;
      items.add(item);
    }

    return items;
  }

// NEED THIS ...
  Future<void> uploadDataToFirestore() async {
    final firestore = FirebaseFirestore.instance;
    final sheetData = await fetchSheetData();
    final firestoreData = await fetchFirestoreData();

    // Helper function to convert serial number to Date
    DateTime convertSerialToDate(double serial) {
      return DateTime(1899, 12, 30).add(Duration(days: serial.toInt()));
    }

    final sheetDataMap = {
      for (var item in sheetData)
        if (item['Kodu'] != null && item['Kodu'].toString().isNotEmpty)
          item['Kodu']: {
            ...item,
            // Check if there's a date and if it is a number, convert it to proper date format
            if (item['Date'] != null && item['Date'] is double)
              'Date': convertSerialToDate(item['Date']).toIso8601String(),
          }
    };

    // Start a batch for Firestore writes
    final batch = firestore.batch();

    // Delete documents in Firestore that are not present in the sheet data
    firestoreData.forEach((docId, _) {
      if (!sheetDataMap.containsKey(docId)) {
        final docRef = firestore.collection(SelectedItems).doc(docId);
        batch.delete(docRef);
      }
    });

    // Add or update documents in Firestore based on the sheet data
    sheetDataMap.forEach((docId, item) {
      final docRef = firestore.collection(SelectedItems).doc(docId);
      // Filter out any fields that are null or empty
      final cleanedItem = Map<String, dynamic>.from(item)
        ..removeWhere(
            (key, value) => key == null || key.isEmpty || value == null);

      batch.set(docRef, cleanedItem);
    });

    // Commit the batch
    await batch.commit();
  }

  // NEED THIS ...
  Future<Map<String, dynamic>> fetchFirestoreData() async {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore.collection(SelectedItems).get();
    final items = <String, dynamic>{};

    for (var doc in querySnapshot.docs) {
      items[doc.id] = doc.data();
    }

    return items;
  }

  Future<void> uploadDataToGoogleSheet() async {
    if (SelectedItems == 'Polyester') {
      uploadPolyesterDataToGoogleSheet();
    } else {
      uploadNaylonDataToGoogleSheet();
    }
  }

  Future<void> uploadPolyesterDataToGoogleSheet() async {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore.collection('Polyester').get();

    // Define headers for Polyester
    List<String> headers = [
      'Kodu',
      'Kalite',
      'Eni',
      'Gramaj',
      'NOT', // First 'NOT' for Polyester
      'Supplier',
      'S/Item No.',
      'S/Item Name',
      'Price',
      'Date',
      ''
    ];

    // Keep track of the maximum number of previous prices encountered
    int maxPreviousPricesCount = 0;

    // List to store all data rows (starting with headers)
    List<List<dynamic>> sheetData = [headers]; // Start with static headers

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      List<dynamic> row = [
        data['Kodu'],
        data['Kalite'],
        data['Eni'],
        data['Gramaj'],
        data['NOT'], // Use 'NOT' for Polyester
        data['Supplier'],
        data['Item No'],
        data['Item Name'],
        data['Price'],
        data['Date']
      ];

      // Fetch Previous_Prices array
      List previousPrices = data['Previous_Prices'] ?? [];
      int previousPricesCount = previousPrices.length;

      // Update the max previous prices count if the current one is higher
      if (previousPricesCount > maxPreviousPricesCount) {
        maxPreviousPricesCount = previousPricesCount;
      }

      // Add empty columns if necessary to align Previous_Prices values to start from column 11
      while (row.length < 11) {
        row.add(''); // Add empty cells until reaching column 11
      }

      // Add values for each map in Previous_Prices
      for (int i = 0; i < previousPricesCount; i++) {
        row.add(previousPrices[i]['price'] ?? ''); // Price value
        row.add(previousPrices[i]['C/F'] ?? ''); // C/F value
        row.add(previousPrices[i]['date'] ?? ''); // Date value
      }

      sheetData.add(row); // Add the row to the sheet data
    }

    // Add headers for Previous_Prices based on max count encountered
    for (int i = 0; i < maxPreviousPricesCount; i++) {
      headers.add('price'); // Add 'price' header for each map
      headers.add('C/F'); // Add 'C/F' header for each map
      headers.add('date'); // Add 'date' header for each map
    }

    await init();

    await worksheet!.clear();
    await worksheet!.values.insertRows(1, sheetData);
  }

  Future<void> uploadNaylonDataToGoogleSheet() async {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore.collection('Naylon').get();

    // Define headers for Naylon
    List<String> headers = [
      'Kodu',
      'Kalite',
      'Eni',
      'Gramaj',
      'Composition', // Composition for Naylon
      'NOT', // NOT for Naylon
      'Supplier',
      'S/Item No.',
      'S/Item Name',
      'Price',
      'Date'
    ];

    // Keep track of the maximum number of previous prices encountered
    int maxPreviousPricesCount = 0;

    // List to store all data rows (starting with headers)
    List<List<dynamic>> sheetData = [headers]; // Start with static headers

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      List<dynamic> row = [
        data['Kodu'],
        data['Kalite'],
        data['Eni'],
        data['Gramaj'],
        data['Composition'], // Composition for Naylon
        data['NOT'], // Use 'NOT' for Naylon
        data['Supplier'],
        data['Item No'],
        data['Item Name'],
        data['Price'],
        data['Date']
      ];

      // Fetch Previous_Prices array
      List previousPrices = data['Previous_Prices'] ?? [];
      int previousPricesCount = previousPrices.length;

      // Update the max previous prices count if the current one is higher
      if (previousPricesCount > maxPreviousPricesCount) {
        maxPreviousPricesCount = previousPricesCount;
      }

      // Add empty columns if necessary to align Previous_Prices values to start from column 11
      while (row.length < 11) {
        row.add(''); // Add empty cells until reaching column 11
      }

      // Add values for each map in Previous_Prices
      for (int i = 0; i < previousPricesCount; i++) {
        row.add(previousPrices[i]['price'] ?? ''); // Price value
        row.add(previousPrices[i]['C/F'] ?? ''); // C/F value
        row.add(previousPrices[i]['date'] ?? ''); // Date value
      }

      sheetData.add(row); // Add the row to the sheet data
    }

    // Add headers for Previous_Prices based on max count encountered
    for (int i = 0; i < maxPreviousPricesCount; i++) {
      headers.add('price'); // Add 'price' header for each map
      headers.add('C/F'); // Add 'C/F' header for each map
      headers.add('date'); // Add 'date' header for each map
    }

    await init();

    await worksheet!.clear();
    await worksheet!.values.insertRows(1, sheetData);
  }
}
