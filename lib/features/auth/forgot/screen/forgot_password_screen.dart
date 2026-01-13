import 'package:home_haven/core/util/export.dart';
import 'package:home_haven/features/auth/forgot/controller/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final controller = Get.put(ForgotPasswordController());
    return Scaffold(
        appBar: AppBar(
          title: Text('Forgot Password'),
          centerTitle: true,
        ),
        body: GetBuilder<ForgotPasswordController>(builder: (_) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Enter your email to reset your password',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 20),
                  controller.isLoading
                      ? CircularProgressIndicator()
                      : CustomButton(
                          text: "Reset Password",
                          onTap: () {
                            if (emailController.text.isEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Get.snackbar(
                                  "Error",
                                  "Please fill the filed",
                                  duration: Duration(seconds: 3),
                                );
                              });
                              return;
                            }
                            controller.resetPassword(
                                email: emailController.text);
                          },
                        ),
                ],
              ),
            ),
          );
        }));
  }
}
