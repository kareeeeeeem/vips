import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Validation method type
enum ValidationMethod { pin, biometrics }

/// Generic PIN validation class with biometric support - Fine UI Version
class PinValidator extends StatefulWidget {
  final int pinLength;
  final bool Function(String pin) validatePin;
  final Future<bool> Function()? validateBiometrics;
  final void Function() onValidPin;
  final Color primaryColor;
  final List<ValidationMethod> supportedMethods;
  final int maxAttempts;
  final int lockoutDurationMinutes;

  const PinValidator({
    Key? key,
    this.pinLength = 4,
    required this.validatePin,
    this.validateBiometrics,
    required this.onValidPin,
    required this.primaryColor,
    this.supportedMethods = const [
      ValidationMethod.pin,
      ValidationMethod.biometrics,
    ],
    this.maxAttempts = 5,
    this.lockoutDurationMinutes = 5,
  }) : super(key: key);

  @override
  _PinValidatorState createState() => _PinValidatorState();
}

class _PinValidatorState extends State<PinValidator>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String? _errorMessage;
  ValidationMethod _currentMethod = ValidationMethod.pin;
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool _rememberMe = false;
  int _failedAttempts = 0;
  DateTime? _lockoutEndTime;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _currentMethod = widget.supportedMethods.first;
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _loadRememberMeStatus();
    _checkLockoutStatus();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadRememberMeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
    });

    if (_rememberMe &&
        widget.supportedMethods.contains(ValidationMethod.biometrics) &&
        widget.validateBiometrics != null) {
      setState(() {
        _currentMethod = ValidationMethod.biometrics;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      await _validateBiometrics();
    }
  }

  Future<void> _saveRememberMeStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', value);
  }

  Future<void> _checkLockoutStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _failedAttempts = prefs.getInt('failed_attempts') ?? 0;
    final lockoutEndString = prefs.getString('lockout_end_time');

    if (lockoutEndString != null) {
      _lockoutEndTime = DateTime.parse(lockoutEndString);
      if (_lockoutEndTime!.isAfter(DateTime.now())) {
        setState(() {
          _isLocked = true;
        });
        _startLockoutTimer();
      } else {
        await _resetAttempts();
      }
    }
  }

  void _startLockoutTimer() {
    if (_lockoutEndTime == null) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      if (DateTime.now().isAfter(_lockoutEndTime!)) {
        _resetAttempts();
      } else {
        setState(() {});
        _startLockoutTimer();
      }
    });
  }

  Future<void> _resetAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('failed_attempts', 0);
    await prefs.remove('lockout_end_time');
    setState(() {
      _failedAttempts = 0;
      _lockoutEndTime = null;
      _isLocked = false;
    });
  }

  Future<void> _incrementFailedAttempts() async {
    _failedAttempts++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('failed_attempts', _failedAttempts);

    if (_failedAttempts >= widget.maxAttempts) {
      _lockoutEndTime = DateTime.now().add(
        Duration(minutes: widget.lockoutDurationMinutes),
      );
      await prefs.setString(
        'lockout_end_time',
        _lockoutEndTime!.toIso8601String(),
      );
      setState(() {
        _isLocked = true;
      });
      _startLockoutTimer();
    }
  }

  String _getRemainingLockoutTime() {
    if (_lockoutEndTime == null) return '';
    final remaining = _lockoutEndTime!.difference(DateTime.now());
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  void _addDigit(String digit) {
    if (_isLocked) return;

    if (_pin.length < widget.pinLength) {
      setState(() {
        _pin += digit;
        _errorMessage = null;
      });

      if (_pin.length == widget.pinLength) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _validateAndExecute();
        });
      }
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _resetPin() {
    setState(() {
      _pin = '';
      _errorMessage = null;
    });
  }

  void _validateAndExecute() async {
    if (_currentMethod == ValidationMethod.pin) {
      _validatePin();
    } else {
      await _validateBiometrics();
    }
  }

  void _validatePin() async {
    if (_pin.length != widget.pinLength) {
      setState(() {
        _errorMessage = 'Please enter a complete PIN';
      });
      return;
    }

    if (widget.validatePin(_pin)) {
      await _resetAttempts();
      setState(() {
        _errorMessage = null;
      });
      widget.onValidPin();
    } else {
      await _incrementFailedAttempts();
      _shakeController.forward(from: 0);

      if (_isLocked) {
        setState(() {
          _errorMessage =
              'Too many attempts. Locked for ${widget.lockoutDurationMinutes} minutes';
        });
      } else {
        final remainingAttempts = widget.maxAttempts - _failedAttempts;
        setState(() {
          _errorMessage =
              'Invalid PIN ($remainingAttempts attempt${remainingAttempts > 1 ? 's' : ''} remaining)';
        });
      }

      Future.delayed(const Duration(seconds: 2), () {
        _resetPin();
      });
    }
  }

  Future<void> _validateBiometrics() async {
    if (widget.validateBiometrics == null) {
      setState(() {
        _errorMessage = 'Biometric validation not supported';
      });
      return;
    }

    try {
      bool canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
      if (!canCheckBiometrics) {
        setState(() {
          _errorMessage = 'No biometric method configured';
        });
        return;
      }

      bool authenticated = await widget.validateBiometrics!();

      if (authenticated) {
        await _resetAttempts();
        setState(() {
          _errorMessage = null;
        });
        widget.onValidPin();
      } else {
        setState(() {
          _errorMessage = 'Biometric validation failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error during biometric validation';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header minimalist
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                      size: 24.sp,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),

                    // Method toggle - Design fin
                    if (widget.supportedMethods.length > 1)
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            widget.supportedMethods.length,
                            (index) {
                              final method = widget.supportedMethods[index];
                              final isSelected = method == _currentMethod;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _currentMethod = method;
                                    _resetPin();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10.r),
                                    boxShadow:
                                        isSelected
                                            ? [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.06,
                                                ),
                                                blurRadius: 12,
                                                offset: Offset(0, 2),
                                              ),
                                            ]
                                            : [],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        method == ValidationMethod.pin
                                            ? Icons.pin_outlined
                                            : Icons.fingerprint,
                                        color:
                                            isSelected
                                                ? widget.primaryColor
                                                : Colors.grey.shade500,
                                        size: 18.sp,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        method == ValidationMethod.pin
                                            ? 'PIN'
                                            : 'Biometric',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isSelected
                                                  ? widget.primaryColor
                                                  : Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    SizedBox(height: 60.h),

                    // Title - Police fine
                    Text(
                      _currentMethod == ValidationMethod.pin
                          ? 'Enter your PIN'
                          : 'Use your fingerprint',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w300,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      _currentMethod == ValidationMethod.pin
                          ? 'Enter your confidential code'
                          : 'Authenticate to continue',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),

                    SizedBox(height: 60.h),

                    if (_currentMethod == ValidationMethod.pin) ...[
                      // PIN display - Design fin et élégant
                      AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              _shakeController.isAnimating
                                  ? (_shakeAnimation.value *
                                      (1 - _shakeController.value) *
                                      2)
                                  : 0,
                              0,
                            ),
                            child: child,
                          );
                        },
                        child: _buildFinePinDisplay(),
                      ),

                      SizedBox(height: 30.h),

                      // Error message
                      SizedBox(
                        height: 24.h,
                        child:
                            _isLocked
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock_outline,
                                      color: Colors.red.shade400,
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'Locked: ${_getRemainingLockoutTime()}',
                                      style: TextStyle(
                                        color: Colors.red.shade400,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                )
                                : _errorMessage != null
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.red.shade400,
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Flexible(
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          color: Colors.red.shade400,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.2,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                )
                                : const SizedBox.shrink(),
                      ),

                      SizedBox(height: 50.h),

                      // Numeric keyboard - Design minimal
                      _buildFineKeyboard(),

                      SizedBox(height: 40.h),

                      // Remember me - Design minimal
                      if (widget.supportedMethods.contains(
                            ValidationMethod.biometrics,
                          ) &&
                          widget.validateBiometrics != null)
                        InkWell(
                          onTap: () {
                            setState(() {
                              _rememberMe = !_rememberMe;
                            });
                            _saveRememberMeStatus(_rememberMe);
                          },
                          borderRadius: BorderRadius.circular(8.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  width: 20.w,
                                  height: 20.w,
                                  decoration: BoxDecoration(
                                    color:
                                        _rememberMe
                                            ? widget.primaryColor
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4.r),
                                    border: Border.all(
                                      color:
                                          _rememberMe
                                              ? widget.primaryColor
                                              : Colors.grey.shade400,
                                      width: 1.5,
                                    ),
                                  ),
                                  child:
                                      _rememberMe
                                          ? Icon(
                                            Icons.check,
                                            size: 14.sp,
                                            color: Colors.white,
                                          )
                                          : null,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  'Remember me',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ] else
                      // Biometrics - Design minimal
                      Column(
                        children: [
                          Container(
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                              color: widget.primaryColor.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.fingerprint,
                              size: 56.sp,
                              color: widget.primaryColor,
                            ),
                          ),
                          SizedBox(height: 40.h),
                          Text(
                            'Place your finger on the sensor',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 30.h),
                          TextButton(
                            onPressed: _validateBiometrics,
                            style: TextButton.styleFrom(
                              foregroundColor: widget.primaryColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: 28.w,
                                vertical: 14.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                side: BorderSide(
                                  color: widget.primaryColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              'Authenticate',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          if (_errorMessage != null) ...[
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.red.shade400,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinePinDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.pinLength, (index) {
        final isFilled = index < _pin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 14.w,
          height: 14.w,
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color:
                _isLocked
                    ? Colors.grey.shade300
                    : isFilled
                    ? widget.primaryColor
                    : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  _isLocked
                      ? Colors.grey.shade400
                      : isFilled
                      ? widget.primaryColor
                      : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFineKeyboard() {
    final digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];

    return Column(
      children: [
        // Grille 5 colonnes
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          alignment: WrapAlignment.center,
          children:
              digits.map((digit) => _buildFineKeyboardButton(digit)).toList(),
        ),
        SizedBox(height: 16.h),
        // Bouton delete centré
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: _isLocked ? null : _removeDigit,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Icon(
                  Icons.backspace_outlined,
                  color:
                      _isLocked ? Colors.grey.shade400 : Colors.grey.shade600,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFineKeyboardButton(String digit) {
    return InkWell(
      onTap: _isLocked ? null : () => _addDigit(digit),
      borderRadius: BorderRadius.circular(50),
      splashColor: widget.primaryColor.withOpacity(0.1),
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color:
                _isLocked
                    ? Colors.grey.shade200
                    : widget.primaryColor.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w300,
              color: _isLocked ? Colors.grey.shade400 : Colors.black87,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
