import 'package:home_haven/core/util/export.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final LoginController controller = Get.put(LoginController());
    return Scaffold(
      body: GetBuilder<LoginController>(
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor,
                      ),
                    ),
                    Text(
                      "Enter your email to start shopping and get awesome deals today!",
                      style: TextStyle(
                        color: AppColors.neutral70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                      controller: emailController,
                      hintText: "Email",
                      prefixIcon: Image.asset(AppIcons.email),
                    ),
                    const SizedBox(height: 22),
                    CustomTextField(
                      controller: passwordController,
                      hintText: "Passowrd",
                      prefixIcon: Image.asset(AppIcons.lock),
                      suffixIcon: IconButton(
                        onPressed: controller.showPassword,
                        icon: Icon(controller.hidenPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                      ),
                      obscureText: controller.hidenPassword,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.toNamed(RouterConstant.forgotPassword);
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    controller.isLoading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : CustomButton(
                            text: "Login",
                            onTap: () {
                              controller.loginUser(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim());
                            },
                          ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(child: Divider()),
                        Text("OR"),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        controller.signInWithGoogleForceAccountPicker();
                      },
                      child: Container(
                        padding: EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(AppIcons.google),
                            const SizedBox(width: 10),
                            Text(
                              "Login in with Google",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(fontSize: 17),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            Get.offAllNamed(RouterConstant.registorScreen);
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
