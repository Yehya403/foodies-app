import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodies_app/ui/auth/login/cubit/login_view_model.dart';

import '../../../di/di.dart';
import '../../common/form_input_field.dart';
import '../../common/primary_button.dart';
import '../../order_choice/order_choice_screen.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/validation_utils.dart';
import '../forget_password/forget_password_screen.dart';
import '../register/register_screen.dart';
import 'cubit/login_states.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "LoginSc";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var viewModel = getIt<LoginViewModel>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginViewModel, LoginStates>(
        bloc: viewModel,
        listener: (context, state) async {
          if (state is LoginLoadingState) {
            DialogUtils.showLoading(context, state.loadingMessage ?? 'Waiting');
          } else if (state is LoginErrorState) {
            DialogUtils.hideLoading(context);
            DialogUtils.showMessage(context, state.errorMessage!,
                title: 'Error', posActionName: 'Ok');
          } else if (state is LoginSuccessState) {
            DialogUtils.hideLoading(context);
            Navigator.pushReplacementNamed(context, OrderChoiceScreen.routeName,
                arguments: state.authResult.data?.name ?? '');
          }
        },
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //Logo
                    Image.asset(
                      'assets/images/app_logo.png',
                    ),

                    const SizedBox(
                      height: 32,
                    ),
                    //Welcome
                    Text(
                        textAlign: TextAlign.start,
                        'Login to your account',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(
                      height: 24,
                    ),
                    //Form
                    Form(
                      key: viewModel.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FormInputField(
                            label: 'Email',
                            icon: Icons.email_outlined,
                            controller: viewModel.emailController,
                            //hint: 'yehya404@gmail.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (text) {
                              if (text == null || text.trim().isEmpty) {
                                return 'Please enter email';
                              }
                              if (!ValidationUtils.isValidEmail(text)) {
                                return 'Please enter valid email';
                              }
                              return null;
                            },
                          ),

                          SizedBox(
                            height: 16,
                          ),

                          FormInputField(
                            icon: Icons.lock_outlined,
                            controller: viewModel.passwordController,
                            label: 'Password',
                            //hint: 'Ehab123@',
                            isSecured: true,
                            validator: (text) {
                              if (text == null || text.trim().isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 8),

                          //Forget Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(ForgetPasswordScreen.routeName);
                              },
                              child: Text(
                                'Forget Password?',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          //Login Button
                          PrimaryButton(
                            text: 'Login',
                            onPressed: () {
                              viewModel.login();
                            },
                          ),

                          const SizedBox(height: 8),

                          //Do not have account ?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Do not have account? ',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                              InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed(RegisterScreen.routeName);
                                  },
                                  child: Text(
                                    ' Sign up',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  )),
                            ],
                          ),

                          //Social Connect
                          // const SocialSignInOptions(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

// void login() {
//   if (viewModel.formKey.currentState?.validate() == false) {
//     return;
//   }
//   Navigator.of(context).pushNamed(OrderChoiceScreen.routeName);
// }
}
