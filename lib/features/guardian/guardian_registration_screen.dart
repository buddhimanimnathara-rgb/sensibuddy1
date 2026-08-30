import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/firestore_service.dart';
import '../../modules/authentication/email_verification/email_verification_screen.dart';
import '../face/guardian_face_screen.dart';

import '../../core/services/auth_service.dart';

class GuardianRegistrationScreen extends StatefulWidget {
  final String childId;

  const GuardianRegistrationScreen({
    super.key,
    required this.childId,
  });

  @override
  State<GuardianRegistrationScreen> createState() =>
      _GuardianRegistrationScreenState();
}

class _GuardianRegistrationScreenState
    extends State<GuardianRegistrationScreen> {

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  String relationship = "Mother";
  bool loading = false;

  bool hidePassword = true;
  bool hideConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();

    passwordController.dispose();

    confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon,color: Colors.deepPurple),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget relationCard(String value, IconData icon) {
    final bool selected = relationship == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          relationship = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 34,
              color: selected
                  ? Colors.white
                  : Colors.deepPurple,
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> registerGuardian() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {

      /// Check Email

      final emailExists =
      await firestoreService.checkEmailExists(
        emailController.text.trim(),
      );

      if (emailExists) {

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(

            backgroundColor: Colors.red,

            content: Text(
              "Email already registered.",
            ),

          ),

        );

        setState(() {
          loading = false;
        });

        return;

      }

      /// Create Firebase Account

      await authService.register(

        email: emailController.text.trim(),

        password: passwordController.text.trim(),

      );

      /// Send Verification Email

      await authService.sendVerificationEmail();

      if (!mounted) return;

      Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) => EmailVerificationScreen(

            childId: widget.childId,

            guardianName:
            nameController.text.trim(),

            email:
            emailController.text.trim(),

            phone:
            phoneController.text.trim(),

            relationship:
            relationship,

          ),

        ),

      );

    }

    catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          backgroundColor: Colors.red,

          content: Text(
            e.toString(),
          ),

        ),

      );

    }

    if (mounted) {

      setState(() {
        loading = false;
      });

    }

  }

  Future<void> saveGuardian() async {
    if(!_formKey.currentState!.validate()) return;
    setState(()=>loading=true);
    try{
      final guardianId = await firestoreService.saveGuardian({
        "childId":widget.childId,
        "name":nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone":phoneController.text.trim(),
        "relationship":relationship,
        "emailVerified": true,
        "createdAt":DateTime.now().toIso8601String(),
      });

      if(!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          content: Text(
            "Guardian registered successfully",
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:(_)=>GuardianFaceScreen(
            childId: widget.childId,
            guardianId: guardianId,
          ),
        ),
      );
    }catch(e){
      if(mounted){
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    if(mounted) setState(()=>loading=false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      appBar: AppBar(
        title: const Text("Guardian Registration"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:[
              Color(0xFFF6F2FF),
              Color(0xFFE4D7FF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Form(
              key:_formKey,
              child: Column(
                children:[
                  Image.asset("assets/images/mascot.png",height:120)
                      .animate(onPlay:(c)=>c.repeat(reverse:true))
                      .moveY(begin:0,end:-10,duration:2.seconds),

                  const SizedBox(height:18),

                  const Text(
                    "Guardian Registration",
                    style:TextStyle(
                      fontSize:28,
                      fontWeight:FontWeight.bold,
                      color:Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(height:8),

                  const Text(
                    "Register the child's parent or guardian before continuing.",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height:30),

                  Card(
                    elevation:6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children:[
                          TextFormField(
                            controller:nameController,
                            decoration:inputDecoration("Guardian Name",Icons.person),
                            validator:(v)=>v==null||v.trim().isEmpty?"Enter guardian name":null,
                          ),

                          const SizedBox(height:20),

                          TextFormField(
                            controller:phoneController,
                            keyboardType:TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration:inputDecoration("Phone Number",Icons.phone),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "Please enter your mobile number";
                              }

                              final phone = v.trim();

                              if (!RegExp(r'^07\d{8}$').hasMatch(phone)) {
                                return "Enter a valid Sri Lankan mobile number";
                              }

                              return null;
                            },
                          ),

                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: "Email Address",
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter email";
                              }

                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+$',
                              ).hasMatch(value)) {
                                return "Invalid email";
                              }

                              return null;
                            },
                          ),

                          TextFormField(
                            controller: passwordController,
                            obscureText: hidePassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock),

                              suffixIcon: IconButton(
                                icon: Icon(
                                  hidePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    hidePassword = !hidePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return "Password must be at least 6 characters";
                              }

                              return null;
                            },
                          ),

                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: hideConfirmPassword,
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              prefixIcon: const Icon(Icons.lock_outline),

                              suffixIcon: IconButton(
                                icon: Icon(
                                  hideConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    hideConfirmPassword =
                                    !hideConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {

                              if (value != passwordController.text) {
                                return "Passwords do not match";
                              }

                              return null;
                            },
                          ),


                          const SizedBox(height:25),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Relationship",
                              style: TextStyle(
                                fontSize:18,
                                fontWeight:FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height:15),

                          Row(
                            children: [
                              Expanded(
                                child: relationCard(
                                  "Mother",
                                  Icons.woman,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: relationCard(
                                  "Father",
                                  Icons.man,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            child: relationCard(
                              "Guardian",
                              Icons.shield_outlined,
                            ),
                          ),

                          const SizedBox(height:30),

                          SizedBox(
                            width:double.infinity,
                            height:55,
                            child:ElevatedButton(
                              style:ElevatedButton.styleFrom(
                                backgroundColor:Colors.deepPurple,
                                foregroundColor:Colors.white,
                                shape:RoundedRectangleBorder(
                                  borderRadius:BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: loading ? null : registerGuardian,
                              child: loading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                "Continue",
                                style:TextStyle(
                                  fontSize:18,
                                  fontWeight:FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}