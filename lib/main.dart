import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'জুয়েলারি বিক্রয় ও হিসাব',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: SalesPage(),
    );
  }
}

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController totalWagesController = TextEditingController();
  final TextEditingController voriWagesController = TextEditingController();
  final TextEditingController customKhathController = TextEditingController();

  final TextEditingController voriController = TextEditingController();
  final TextEditingController anaController = TextEditingController();
  final TextEditingController ratiController = TextEditingController();
  final TextEditingController pointController = TextEditingController();
  final TextEditingController gramController = TextEditingController();

  String selectedKhath = 'উৎপাদিত নতুন গহনা';
  final List<String> khathOptions = [
    'উৎপাদিত নতুন গহনা',
    'কেনা নতুন গহনা',
    'পুরাতন গহনা',
    'বন্ধকী গহনা',
    'অন্যান্য খাত (নিচে লিখুন)'
  ];

  File? productImage;
  File? idCardImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // ভরি, আনা, রতি, পয়েন্ট টাইপ করার সাথে সাথে গ্রামের অটোমেটিক হিসাব চালু করা
    voriController.addListener(_calculateGram);
    anaController.addListener(_calculateGram);
    ratiController.addListener(_calculateGram);
    pointController.addListener(_calculateGram);
  }

  // ১. স্বর্ণের সঠিক আন্তর্জাতিক ওজন হিসাবের লজিক (১ ভরি = ১১.৬৬৪ গ্রাম)
  void _calculateGram() {
    double vori = double.tryParse(voriController.text) ?? 0.0;
    double ana = double.tryParse(anaController.text) ?? 0.0;
    double rati = double.tryParse(ratiController.text) ?? 0.0;
    double point = double.tryParse(pointController.text) ?? 0.0;

    if (vori == 0 && ana == 0 && rati == 0 && point == 0) {
      return; 
    }

    // ১ ভরি = ১৬ আনা = ৯৬ রতি = ৯৬০ পয়েন্ট
    double totalVori = vori + (ana / 16.0) + (rati / 96.0) + (point / 960.0);
    double totalGram = totalVori * 11.664;

    // গ্রামের টেক্সট ফিল্ডে ৩ দশমিক স্থান পর্যন্ত অটো-আপডেট করা
    gramController.text = totalGram.toStringAsFixed(3);
  }

  // ২. ডিভাইস গ্যালারি থেকে ছবি আপলোড সচল করার ফাংশন
  Future<void> _pickImage(bool isProduct) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          if (isProduct) {
            productImage = File(pickedFile.path);
          } else {
            idCardImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ছবি আপলোড করতে সমস্যা হয়েছে: $e')),
      );
    }
  }

  // ৩. ডিজিটাল বিক্রয় মেমো স্ক্রিনে সুন্দরভাবে প্রদর্শন করার ফাংশন
  void _showMemo() {
    String finalKhath = selectedKhath == 'অন্যান্য খাত (নিচে লিখুন)' 
        ? customKhathController.text 
        : selectedKhath;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ডিজিটাল বিক্রয় মেমো রশিদ', 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                SizedBox(height: 10),
                Text('👤 ক্রেতার নাম: ${nameController.text.isEmpty ? "উল্লেখ নেই" : nameController.text}', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('📍 ঠিকানা: ${addressController.text.isEmpty ? "উল্লেখ নেই" : addressController.text}'),
                Text('📞 মোবাইল: ${phoneController.text.isEmpty ? "কোড নাই" : phoneController.text}'),
                Divider(color: Colors.amber, thickness: 1.5),
                Text('⚖️ স্বর্ণের মোট ওজন:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[800])),
                Text('- ভরি: ${voriController.text.isEmpty ? "০" : voriController.text} ভরি, ${anaController.text.isEmpty ? "০" : anaController.text} আনা, ${ratiController.text.isEmpty ? "০" : ratiController.text} রতি, ${pointController.text.isEmpty ? "০" : pointController.text} পয়েন্ট'),
                Text('- গ্রামে হিসাব: ${gramController.text.isEmpty ? "০.০০০" : gramController.text} গ্রাম', style: TextStyle(fontWeight: FontWeight.bold)),
                Divider(),
                Text('💰 সোনার দর (ভরি): ${rateController.text.isEmpty ? "০" : rateController.text} টাকা'),
                Text('🛠️ মোট মজুরি: ${totalWagesController.text.isEmpty ? "০" : totalWagesController.text} টাকা'),
                Text('📂 বিক্রয়ের খাত: $finalKhath', style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w500)),
                Divider(color: Colors.amber, thickness: 1.5),
                Row(
                  children: [
                    Icon(Icons.image, size: 18, color: productImage != null ? Colors.green : Colors.red),
                    SizedBox(width: 5),
                    Text('পণ্যের ছবি: ${productImage != null ? "সফলভাবে যুক্ত" : "আপলোড করা হয়নি"}'),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.credit_card, size: 18, color: idCardImage != null ? Colors.green : Colors.red),
                    SizedBox(width: 5),
                    Text('আইডি কার্ড: ${idCardImage != null ? "সফলভাবে যুক্ত" : "আপলোড করা হয়নি"}'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: Text('বন্ধ করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    voriController.dispose();
    anaController.dispose();
    ratiController.dispose();
    pointController.dispose();
    gramController.dispose();
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    rateController.dispose();
    totalWagesController.dispose();
    voriWagesController.dispose();
    customKhathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('জুয়েলারি বিক্রয় ও হিসাব', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(controller: nameController, decoration: InputDecoration(labelText: 'ক্রেতার নাম', icon: Icon(Icons.person, color: Colors.amber))),
                    TextField(controller: addressController, decoration: InputDecoration(labelText: 'ঠিকানা', icon: Icon(Icons.location_on, color: Colors.amber))),
                    TextField(controller: phoneController, decoration: InputDecoration(labelText: 'মোবাইল নাম্বার', icon: Icon(Icons.phone, color: Colors.amber)), keyboardType: TextInputType.phone),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(true),
                        icon: Icon(Icons.camera_alt, color: Colors.white),
                        label: Text('পণ্যের ছবি', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                      if (productImage != null) 
                        Text('✓ ছবি যুক্ত হয়েছে', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
