import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NFCReaderScreen(),
    );
  }
}

class NFCReaderScreen extends StatefulWidget {
  const NFCReaderScreen({super.key});

  @override
  State<NFCReaderScreen> createState() => _NFCReaderScreenState();
}

class _NFCReaderScreenState extends State<NFCReaderScreen> {
  final List<String> _nfcIds = [];
  bool _isScanning = true;
  double _progressValue = 0.0;
  Color _statusColor = Colors.greenAccent;
  String _statusText = "Tekan tombol untuk memulai kembali pemindaian";

  @override
  void initState() {
    super.initState();
    _checkNFCavailability();
  }

  Future<void> _checkNFCavailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        _statusText = "NFC tidak tersedia di perangkat ini";
        _statusColor = Colors.redAccent;
      });
    }
  }

  void _startScanning() async {
    setState(() {
      _isScanning = true;
      _progressValue = 0.0;
      _statusText = "Dekatkan kartu NFC...";
      _statusColor = Colors.orangeAccent;
    });

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        final nfcId = tag.data.toString();

        setState(() {
          _nfcIds.add(nfcId);
          _progressValue = 1.0;
          _statusText = "NFC berhasil dibaca!";
          _statusColor = Colors.greenAccent;
        });

        await NfcManager.instance.stopSession();
        setState(() {
          _isScanning = false;
        });
      },
    );
  }

  void _stopScanning() async {
    await NfcManager.instance.stopSession();
    setState(() {
      _isScanning = false;
      _statusText = "Pemindaian dihentikan";
      _statusColor = Colors.redAccent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NFC Reader"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // status text
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: BorderRadius.circular(10)
              ),
            ),
            SizedBox(height:20,),

            // INDIKATOR SCANNING
            AnimatedContainer(
              duration: Duration(seconds: 1),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isScanning ? Colors.orangeAccent : Colors.grey,
              ),
              child: Icon(Icons.nfc, size: 50, color: Colors.white,),
            ),
             SizedBox(height: 20),

          // ================= PROGRESS BAR =================
          LinearProgressIndicator(
            value: _progressValue, // Nilai progress (0.0 - 1.0)
            minHeight: 8,          // Ketebalan bar
            backgroundColor: Colors.grey, // Warna background
            color: _statusColor,   // Warna progress mengikuti status
          ),

          SizedBox(height: 20),

          // ================= HISTORY LIST =================
          Expanded(
            // Mengisi sisa ruang layar
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Background list
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12, // Bayangan halus
                    blurRadius: 5,
                  )
                ],
              ),

              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: _nfcIds.length, // Jumlah history NFC
                itemBuilder: (context, index) {

                  String entry = _nfcIds[index]; // Data history
                  
                  // Memisahkan timestamp & NFC ID
                  List<String> parts = entry.split(' - NFC ID: ');
                  String timeStamp = parts[0];
                  String nfcId = parts.length > 1
                      ? parts[1]
                      : "Tidak dapat membaca ID NFC";

                  return Card(
                    elevation: 3, // Tinggi bayangan card
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Timestamp scan
                          Text(
                            timeStamp,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),

                          SizedBox(height: 5),

                          // NFC ID yang terbaca
                          Text(
                            nfcId,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),

                      // Alternatif tampilan sederhana:
                      // title: Text(_nfcIds[index])
                      // leading: Icon(Icons.history)
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 20),

          // ================= TOMBOL CONTROL =================
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Tombol mulai scan
              ElevatedButton(
                onPressed: _startNFCScan, // Fungsi start scanning
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Mulai Scan",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ),

              SizedBox(width: 20), // Spasi antar tombol

              // Tombol stop scan
              ElevatedButton(
                onPressed: _stopNFCScan, // Fungsi stop scanning
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15),
                  backgroundColor: Colors.redAccent, // Warna tombol stop
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Stop Scan",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
            

            LinearProgressIndicator(
              value: _isScanning ? null : _progressValue,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              color: _statusColor,
            ),
            const SizedBox(height: 20),
            Text(
              _statusText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _statusColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isScanning ? _stopScanning : _startScanning,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isScanning ? Colors.redAccent : Colors.teal,
              ),
              child: Text(
                _isScanning ? "Stop Scan" : "Mulai Scan",
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              "Riwayat NFC:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _nfcIds.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.nfc),
                    title: Text(_nfcIds[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}