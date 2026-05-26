import 'package:flutter/material.dart';
import 'dart:math' as math;
// 1. TAMBAHKAN IMPORT INI
import 'package:flutter_native_splash/flutter_native_splash.dart'; 
import 'dart:async';
import 'dart:convert';//taruh do atas paketshared
import 'package:shared_preferences/shared_preferences.dart';


void main() {


  runApp(const MyApp());


}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Papan Performa Member',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),
      home: const MainNavigationHolder(),
    );
  }
}

const List<String> kDaftarKlasifikasiLatihan = [
  "STRENGTH", "ENDURANCE", "SPEED", "COORDINATION", "FLEXIBILITY", "BALANCE", "REACTION TIME", 
  "POWER", "AGILITY", "MOBILITY", "MUSCULAR ENDURANCE", "CORE STABILITY", "DYNAMIC FLEXIBILITY", 
  "SPEED ENDURANCE", "REACTIVE SPEED / QUICKNESS","ANTICIPATION&SPATIAL AWARENESS", "ANTICIPATION","SPATIAL AWARENESS", 
  "OPEN AGILITY", "EXPLOSIVE STRENGTH", "STRENGTH ENDURANCE", "RATE OF FORCE DEVELOPMENT", 
  "DECELERATION ABILITY", "CHANGE OF DIRECTION", "NEURAL DRIVE", "ISO-STRENGTH", 
  "ECCENTRIC STRENGTH", "FLEXIBILITY-STRENGTH BALANCE", "CORE ROTATIONAL POWER", 
  "LATERAL QUICKNESS", "VERTICAL JUMP CAPACITY", "RECOVERY RATE", "NEURAL FATIGUE LEVEL", 
  "JOINT STABILITY", "PELVIC FLOOR CONTROL", "POSTURAL ALIGNMENT", 
  "FLEXIBILITY-NEURAL INTEGRATION", "ANAEROBIC CAPACITY", "AEROBIC EFFICIENCY", 
  "BALANCE RECOVERY", "MENTAL TOUGHNESS"
];

const List<String> kKlasifksKmampuan = ["STRENGTH" , "ENDURANCE" , "SPEED" , "COORDINATION" , "FLEXIBILITY" , "BALANCE" , "REACTION TIME" , "MUSCULAR ENDURANCE" , "POWER" , "CORE STABILITY" , "DYNAMIC FLEXIBILITY" , "SPEED ENDURANCE" , "REACTIVE SPEED" , "AGILITY" , "ANTICIPATION&SPATIAL AWARENESS" , "MOBILITY" , "OPEN AGILITY" ];

class Murid {
  final String id;
  final String nama;
  final List<List<double>> boxData; 
  final List<double> radarData; 
  List<Map<String, dynamic>> riwayatLatihanKuantitatif;
  List<Map<String, dynamic>> riwayatLatihanDurasi;

  Murid({
    required this.id, required this.nama, required this.boxData, required this.radarData,
    List<Map<String, dynamic>>? riwayatLatihanKuantitatif,
    List<Map<String, dynamic>>? riwayatLatihanDurasi,
  })  : this.riwayatLatihanKuantitatif = riwayatLatihanKuantitatif ?? [],
        this.riwayatLatihanDurasi = riwayatLatihanDurasi ?? [];
}

class MainNavigationHolder extends StatefulWidget {
  const MainNavigationHolder({Key? key}) : super(key: key);
  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _currentIndex = 0; 
  bool _isPageLoading = false;
  String _selectedMuridId = "001"; 
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  late List<Murid> _daftarMurid;

// 1. FUNGSI MENYIMPAN DATA SECARA PERMANEN KE HP
  Future<void> _simpanKeStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Konversi seluruh daftar murid dan riwayatnya menjadi teks JSON
    List<Map<String, dynamic>> mapMurid = _daftarMurid.map((murid) {
      return {
        'id': murid.id,
        'nama': murid.nama,
        'radarData': murid.radarData,
        'boxData': murid.boxData,
        'riwayatLatihanKuantitatif': murid.riwayatLatihanKuantitatif.map((e) => {
          'tanggal': e['tanggal'].toIso8601String(),
          'jenis': e['jenis'],
          'klasifikasi': e['klasifikasi'],
          'skor': e['skor'],
          'isReps': e['isReps'],
          'tipePembagi': e['tipePembagi'],
        }).toList(),
        'riwayatLatihanDurasi': murid.riwayatLatihanDurasi.map((e) => {
          'tanggal': e['tanggal'].toIso8601String(),
          'jenis': e['jenis'],
          'klasifikasi': e['klasifikasi'],
          'skor': e['skor'],
          'isReps': e['isReps'],
          'tipePembagi': e['tipePembagi'],
        }).toList(),
      };
    }).toList();

    String jsonString = jsonEncode(mapMurid);
    await prefs.setString('data_atlet_coach', jsonString);
    print("Data berhasil dikunci ke memori HP!");
  }

  // 2. FUNGSI MEMANGGIL DATA SETIAP KALI APLIKASI BARU DIBUKA
  Future<void> _muatDataDariStorage() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('data_atlet_coach');

    if (jsonString != null) {
      List<dynamic> decodedData = jsonDecode(jsonString);
      setState(() {
        _daftarMurid = decodedData.map((item) {
          var murid = Murid(
            id: item['id'],
            nama: item['nama'],
            radarData: List<double>.from(item['radarData']),
            boxData: (item['boxData'] as List).map((e) => List<double>.from(e)).toList(),
          );
          
          if (item['riwayatLatihanKuantitatif'] != null) {
            murid.riwayatLatihanKuantitatif = List<Map<String, dynamic>>.from(
              item['riwayatLatihanKuantitatif'].map((e) => {
                'tanggal': DateTime.parse(e['tanggal']),
                'jenis': e['jenis'],
                'klasifikasi': e['klasifikasi'],
                'skor': e['skor'],
                'isReps': e['isReps'],
                'tipePembagi': e['tipePembagi'],
              })
            );
          }

          if (item['riwayatLatihanDurasi'] != null) {
            murid.riwayatLatihanDurasi = List<Map<String, dynamic>>.from(
              item['riwayatLatihanDurasi'].map((e) => {
                'tanggal': DateTime.parse(e['tanggal']),
                'jenis': e['jenis'],
                'klasifikasi': e['klasifikasi'],
                'skor': e['skor'],
                'isReps': e['isReps'],
                'tipePembagi': e['tipePembagi'],
              })
            );
          }
          return murid;
        }).toList();
      });
    }
  }


  // 3. FUNGSI EKSPOR: MENYALIN DATABASE KE CLIPBOARD HP
  Future<void> _eksporDataBackup(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('data_atlet_coach');
    
    if (jsonString != null) {
      await Clipboard.setData(ClipboardData(text: jsonString));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Kode Backup sukses disalin! Silakan simpan di Catatan/WA Coach.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Gagal, belum ada data atlet untuk dibackup.')),
      );
    }
  }

  // 4. FUNGSI IMPOR: MENERIMA TEMPELAN TEKS DAN MEMULIHKAN DATABASE
  Future<void> _imporDataBackup(BuildContext context, String teksBackup) async {
    try {
      if (teksBackup.trim().isEmpty) return;
      
      final prefs = await SharedPreferences.getInstance();
      List<dynamic> testValidasi = jsonDecode(teksBackup);
      
      if (testValidasi.isNotEmpty) {
        await prefs.setString('data_atlet_coach', teksBackup);
        await _muatDataDariStorage(); // Langsung segarkan data di layar dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Impor Sukses! Seluruh data zona beladiri berhasil dipulihkan.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Format kode backup salah atau rusak!')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _daftarMurid = [];
    _muatDataDariStorage(); // <--- Ini yang menarik data lama dari memori HP saat app dibuka

  }

  Murid get _currentMurid => _daftarMurid.firstWhere(
        (m) => m.id == _selectedMuridId, 
        orElse: () => _daftarMurid.isNotEmpty 
            ? _daftarMurid.first 
            : Murid(id: "000", nama: "BELUM ADA SISWA", boxData: List.generate(7, (_) => [0,0,0,0,0,0]), radarData: List.generate(10, (_) => 0.0)),
      );


  List<double> get _teamAverageBoxScores {
    List<double> averages = List.generate(7, (_) => 0.0);
    if (_daftarMurid.isEmpty) return averages;
    for (int i = 0; i < 7; i++) {
      double sum = 0;
      int count = 0;
      for (var murid in _daftarMurid) {
        if (i < murid.boxData.length && murid.boxData[i].length > 3) {
          if (murid.boxData[i][3] > 0) { 
            sum += murid.boxData[i][3];
            count++;
          }
        }
      }
      averages[i] = count > 0 ? sum / count : 0.0;
    }
    return averages;
  }

  List<double> get _teamAverageRadar {
    List<double> averages = List.generate(10, (_) => 0.0);
    if (_daftarMurid.isEmpty) return averages;
    for (int i = 0; i < 10; i++) {
      double sum = 0;
      int count = 0;
      for (var murid in _daftarMurid) {
        if (i < murid.radarData.length) {
          if (murid.radarData[i] > 0) {
            sum += murid.radarData[i];
            count++;
          }
        }
      }
      averages[i] = count > 0 ? sum / count : 0.0;
    }
    return averages;
  }

  int _dapatkanBoxIndex(String klasifikasi) {
    final String upper = klasifikasi.toUpperCase();
    if (upper == "STRENGTH" || upper == "POWER" || upper == "CORE STABILITY") return 0;
    if (upper == "ENDURANCE" || upper == "MUSCULAR ENDURANCE") return 1;
    if (upper == "SPEED" || upper == "SPEED ENDURANCE") return 2;
    if (upper == "COORDINATION" || upper == "ANTICIPATION & SPATIAL AWARENESS") return 3;
    if (upper == "FLEXIBILITY" || upper == "DYNAMIC FLEXIBILITY") return 4;
    if (upper == "BALANCE") return 5;
    if (upper == "REACTION TIME" || upper == "REACTIVE SPEED / QUICKNESS") return 6;
    return -1;
  }
  // --- TAMBAHKAN FUNGSI INI DI DALAM _MainNavigationHolderState ---
  int _dapatkanRadarIndex(String klasifikasi) {
    switch (klasifikasi.toUpperCase()) {
      case "MUSCULAR ENDURANCE": return 0;
      case "POWER": return 1;
      case "CORE STABILITY": return 2;
      case "DYNAMIC FLEXIBILITY": return 3;
      case "SPEED ENDURANCE": return 4;
      case "REACTIVE SPEED": return 5;
      case "AGILITY": return 6;
      case "ANTICIPATION&SPATIAL AWARENESS": return 7;
      case "MOBILITY": return 8;
      case "OPEN AGILITY": return 9;
      default: return -1;
    }
  }

    void _simpanDataKuantitatif(String id, String jenis, String klas, double reps, double sets, String tipePembagi, DateTime tgl) {
    setState(() {
      int idx = _daftarMurid.indexWhere((m) => m.id == id);
      if (idx != -1) {
        double pembagi = (tipePembagi == 'J') ? 15.0 : 25.0;
        double skorGrafik = (reps * sets) / pembagi; 
        double volumeHistory = reps * sets;

        _daftarMurid[idx].riwayatLatihanKuantitatif.add({
          'tanggal': tgl, 
          'jenis': jenis, 
          'klasifikasi': klas, 
          'skor': volumeHistory, 
          'isReps': true, 
          'tipePembagi': tipePembagi
        });

        // 1. RADAR KUANTITATIF (REPS)
        int rIdx = _dapatkanRadarIndex(klas);
        if (rIdx != -1 && rIdx < _daftarMurid[idx].radarData.length) {
          List<double> semuaSkorRadar = _daftarMurid[idx].riwayatLatihanKuantitatif
              .where((item) => item['klasifikasi'] == klas)
              .map((item) {
                double pembagiI = (item['tipePembagi'] == 'J') ? 15.0 : 25.0;
                double skorSederhana = ((item['skor'] ?? 0) as num).toDouble() / pembagiI;

                if (skorSederhana < 1.0) {
                  return math.pow(skorSederhana, 1.5).toDouble(); 
                } else {
                  return skorSederhana; 
                }
              }).toList();

          if (semuaSkorRadar.isNotEmpty) {
            double total = semuaSkorRadar.reduce((a, b) => a + b);
            double rataRata = total / semuaSkorRadar.length;
            _daftarMurid[idx].radarData[rIdx] = rataRata.clamp(0.0, 1.2);
          }
        }

        // 2. BOXPLOT KUANTITATIF
        int bIdx = _dapatkanBoxIndex(klas);
        if (bIdx != -1 && bIdx < _daftarMurid[idx].boxData.length) {
          List<double> dataLama = List<double>.from(_daftarMurid[idx].boxData[bIdx]);
          if (dataLama.every((v) => v == 0.0)) {
            dataLama.clear();
          }

          dataLama.add(skorGrafik);
          dataLama.sort();

          double min = dataLama.first;
          double max = dataLama.last;
          double median = dataLama[dataLama.length ~/ 2];
          double q1 = dataLama[(dataLama.length * 0.25).floor()];
          double q3 = dataLama[(dataLama.length * 0.75).floor().clamp(0, dataLama.length - 1)];
          double current = skorGrafik; 

          _daftarMurid[idx].boxData[bIdx] = [min, q1, median, current, q3, max];
        }

        _selectedMuridId = id;
      }
    });
     _simpanKeStorage();
  }

  void _simpanDataDurasi(String id, String jenis, String klas, double waktu, double sets, String tipePembagi, DateTime tgl) {
    setState(() {
      int idx = _daftarMurid.indexWhere((m) => m.id == id);
      if (idx != -1) {
        double pembagi = (tipePembagi == 'J') ? 60.0 : 90.0;
        double skorGrafik = (waktu * sets) / pembagi;
        double volumeHistory = waktu * sets;

        _daftarMurid[idx].riwayatLatihanDurasi.add({
          'tanggal': tgl, 
          'jenis': jenis, 
          'klasifikasi': klas, 
          'skor': volumeHistory, 
          'isReps': false, 
          'tipePembagi': tipePembagi
        });

        // 1. RADAR DURASI (WAKTU)
        int rIdx = _dapatkanRadarIndex(klas);
        if (rIdx != -1 && rIdx < _daftarMurid[idx].radarData.length) {
          List<double> semuaSkorRadar = _daftarMurid[idx].riwayatLatihanDurasi
              .where((item) => item['klasifikasi'] == klas)
              .map((item) {
                double pembagiI = (item['tipePembagi'] == 'J') ? 60.0 : 90.0;
                double skorSederhana = ((item['skor'] ?? 0) as num).toDouble() / pembagiI;

                if (skorSederhana > 0) {
                  double skorDibalik = 1.0 / skorSederhana; 
                  if (skorDibalik < 1.0) {
                    return math.pow(skorDibalik, 1.5).toDouble(); 
                  } else {
                    return skorDibalik; 
                  }
                }
                return 0.0;
              }).toList();

          if (semuaSkorRadar.isNotEmpty) {
            double total = semuaSkorRadar.reduce((a, b) => a + b);
            double rataRata = total / semuaSkorRadar.length;
            _daftarMurid[idx].radarData[rIdx] = rataRata.clamp(0.0, 1.2);
          }
        }

        // 2. BOXPLOT DURASI
        int bIdx = _dapatkanBoxIndex(klas);
        if (bIdx != -1 && bIdx < _daftarMurid[idx].boxData.length) {
          List<double> dataLama = List<double>.from(_daftarMurid[idx].boxData[bIdx]);
          if (dataLama.every((v) => v == 0.0)) {
            dataLama.clear();
          }

          dataLama.add(skorGrafik);
          dataLama.sort();

          double min = dataLama.first;
          double max = dataLama.last;
          double median = dataLama[dataLama.length ~/ 2];
          double q1 = dataLama[(dataLama.length * 0.25).floor()];
          double q3 = dataLama[(dataLama.length * 0.75).floor().clamp(0, dataLama.length - 1)];
          double current = skorGrafik;

          _daftarMurid[idx].boxData[bIdx] = [min, q1, median, current, q3, max];
        }

        _selectedMuridId = id;
      }
    });
     _simpanKeStorage();
  }

  @override
  Widget build(BuildContext context) {
    List<Murid> filtered = _daftarMurid.where((m) => m.nama.contains(_searchQuery.toUpperCase()) || m.id.contains(_searchQuery)).toList();

    final List<Widget> pages = [
      DashboardAtletPage(activeMurid: _currentMurid, teamBoxAverages: _teamAverageBoxScores, teamRadarAverages: _teamAverageRadar, dapatkanBoxIndexFunc: _dapatkanBoxIndex),
      DaftarMuridPage(
        daftarMurid: filtered, selectedId: _selectedMuridId, namaController: _namaController, searchController: _searchController,
        onSearchChanged: (v) => setState(() => _searchQuery = v),
        onSelect: (id) => setState(() { _selectedMuridId = id; _currentIndex = 0; }), 
        onDelete: (m) => setState(() => _daftarMurid.remove(m)),
        onAdd: () {
          if (_namaController.text.trim().isEmpty) return;
          setState(() {
            int maxId = 0;
            for (var m in _daftarMurid) {
              int? cId = int.tryParse(m.id);
              if (cId != null && cId > maxId) maxId = cId;
            }
            String nextId = (maxId + 1).toString().padLeft(3, '0');
            _daftarMurid.add(Murid(id: nextId, nama: _namaController.text.trim().toUpperCase(), boxData: List.generate(7, (_) => [0, 0, 0, 0, 0, 0]), radarData: List.generate(10, (_) => 0.0)));
          });
          _namaController.clear();
        },
      
         onEkspor: () => _eksporDataBackup(context),
         onImpor: () => _tampilkanDialogInputImpor(context),
      ),
      InputLatihanKuantitatifPage(daftarMurid: _daftarMurid, selectedMuridId: _selectedMuridId, onMuridChanged: (id) => setState(() => _selectedMuridId = id!), onSimpan: _simpanDataKuantitatif),
      InputLatihanDurasiPage(daftarMurid: _daftarMurid, selectedMuridId: _selectedMuridId, onMuridChanged: (id) => setState(() => _selectedMuridId = id!), onSimpan: _simpanDataDurasi),
      TimelineHistoryPage(activeMurid: _currentMurid), 
    ];

        return Scaffold(
      body: Stack(
        children: [
          SafeArea(child: pages[_currentIndex]),

          // <-- KODE FAKE SPLASH SAAT PINDAH HALAMAN -->
          if (_isPageLoading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF0F172A), 
              child: Center(
                child: Image.asset(
                  'assets/splash.png', 
                  width: 200, 
                ),
              ),
            ),
        ],
      ),
// ...

            bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        // <-- UBAH onTap MENJADI SEPERTI INI -->
        onTap: (i) async {
          if (_currentIndex == i) return; 

          setState(() => _isPageLoading = true); 

          await Future.delayed(const Duration(seconds: 1)); 

          setState(() {
            _currentIndex = i; 
            _isPageLoading = false; 
          });
        },
        backgroundColor: const Color(0xFF1E293B), 
// ...
        selectedItemColor: const Color(0xFF38BDF8),
        unselectedItemColor: const Color(0xFF64748B),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'DASHBOARD'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'DAFTAR SISWA'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'INPUT REPS'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'INPUT WAKTU'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'HISTORY'),
        ],
      ),
    );
  }
}

// ==================== HALAMAN 1: DASHBOARD PERFORMANCE ====================
class DashboardAtletPage extends StatelessWidget {
  final Murid activeMurid;
  final List<double> teamBoxAverages;
  final List<double> teamRadarAverages;
  final int Function(String) dapatkanBoxIndexFunc;

  const DashboardAtletPage({
    Key? key, 
    required this.activeMurid, 
    required this.teamBoxAverages, 
    required this.teamRadarAverages, 
    required this.dapatkanBoxIndexFunc
  }) : super(key: key);

   
  


  @override
  Widget build(BuildContext conte
