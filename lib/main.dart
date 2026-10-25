import 'package:flutter/material.dart';

void main() {
  runApp(const PoolHackApp());
}

// نموذج بيانات المستخدم
class UserModel {
  final String username;
  final String password;
  final String role;
  int daysLeft;
  String status;

  UserModel({
    required this.username,
    required this.password,
    required this.role,
    required this.daysLeft,
    required this.status,
  });
}

// قاعدة بيانات مؤقتة جوه التطبيق (لحد ما نربطها بسيرفر خارجي)
List<UserModel> globalUsers = [
  UserModel(username: "AdamHaitham2011", password: "AdamHaitham(179)", role: "Admin", daysLeft: 999, status: "Active"),
  UserModel(username: "user1", password: "1234", role: "User", daysLeft: 2, status: "Active"),
];

class PoolHackApp extends StatelessWidget {
  const PoolHackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pool Hack Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1020),
        primaryColor: Colors.purpleAccent,
      ),
      home: const LoginScreen(),
    );
  }
}

// شاشة تسجيل الدخول
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك ادخل اسم المستخدم وكلمة المرور!'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });

      // البحث عن المستخدم في القائمة
      var foundUser = globalUsers.firstWhere(
        (u) => u.username == username && u.password == password,
        orElse: () => UserModel(username: "", password: "", role: "", daysLeft: 0, status: "Notfound"),
      );

      if (foundUser.status == "Notfound") {
        // لو اليوزر مش موجود أو الباسورد غلط
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ: اسم المستخدم أو كلمة المرور غير صحيحة أو غير موجودة!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        // فحص صلاحية الأيام للمستخدم العادي
        if (foundUser.role != "Admin" && foundUser.daysLeft <= 0) {
          foundUser.status = "Expired";
        }

        // الانتقال للوحة التحكم المناسبة
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen(currentUser: foundUser)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل دخول الهاك - 8 Ball Pool'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.purpleAccent),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'اسم المستخدم (Username)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'كلمة المرور (Password)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 25),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.purpleAccent)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _login,
                    child: const Text('دخول (Login)', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
          ],
        ),
      ),
    );
  }
}

// لوحة التحكم المشتركة (تتغير حسب الصلاحية: أدمن أو يوزر عادي)
class DashboardScreen extends StatefulWidget {
  final UserModel currentUser;

  const DashboardScreen({super.key, required this.currentUser});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _newUserInput = TextEditingController();
  final TextEditingController _newPassInput = TextEditingController();
  final TextEditingController _daysInput = TextEditingController();

  // دالة إضافة يوزر جديد بواسطة الأدمن
  void _createNewUser() {
    String newU = _newUserInput.text.trim();
    String newP = _newPassInput.text.trim();
    int days = int.tryParse(_daysInput.text.trim()) ?? 2; // افتراضياً يومين زي ما طلبت

    if (newU.isEmpty || newP.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب اليوزر والباسورد الجديدين!'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    setState(() {
      globalUsers.add(UserModel(
        username: newU,
        password: newP,
        role: "User",
        daysLeft: days,
        status: "Active",
      ));
    });

    _newUserInput.clear();
    _newPassInput.clear();
    _daysInput.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إنشاء اليوزر $newU بنجاح لمدة $days أيام!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.currentUser.role == "Admin";

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'لوحة تحكم الأدمن (Admin Panel)' : 'لوحة تحكم الهاك'),
        backgroundColor: const Color(0xFF1F1B3A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مرحباً بك، ${widget.currentUser.username} 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            // كارت حالة الاشتراك
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1B3A),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('حالة الاشتراك:', style: TextStyle(fontSize: 16)),
                  Text(
                    widget.currentUser.status == "Active" 
                        ? 'Active • (${widget.currentUser.daysLeft} أيام متبقية)' 
                        : 'Expired ❌',
                    style: TextStyle(
                      color: widget.currentUser.status == "Active" ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // لو الأدمن هو اللي فاتح، يظهر له قسم إنشاء وإدارة اليوزرات
            if (isAdmin) ...[
              const Divider(color: Colors.purpleAccent),
              const SizedBox(height: 10),
              const Text('إدارة وتوليد اليوزرات:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
              const SizedBox(height: 10),
              TextField(
                controller: _newUserInput,
                decoration: InputDecoration(
                  labelText: 'يوزر الشخص الجديد',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _newPassInput,
                decoration: InputDecoration(
                  labelText: 'كلمة مرور الشخص الجديد',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _daysInput,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'عدد الأيام (مثلاً: 2)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.styleFrom().hasChild() ? Container() : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _createNewUser,
                child: const Text('إنشاء يوزر جديد وتحديد المدة', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 20),
              const Text('قائمة اليوزرات النشطة حالياً:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              // عرض لستة اليوزرات المسجلة
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: globalUsers.length,
                itemBuilder: (context, index) {
                  var u = globalUsers[index];
                  return Card(
                    color: const Color(0xFF1A1832),
                    child: ListTile(
                      title: Text(u.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('المدة: ${u.daysLeft} أيام • الدور: ${u.role}'),
                      trailing: Text(u.status, style: TextStyle(color: u.status == "Active" ? Colors.green : Colors.red)),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(200, 50),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('تسجيل الخروج', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
