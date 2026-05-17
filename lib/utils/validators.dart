String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Email is required';
  final emailRegex = RegExp(r"^[^@]+@[^@]+\.[^@]+$");
  if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < 8) return 'Password must be at least 8 characters';
  if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
    return 'Password must contain a letter';
  }
  if (!RegExp(r'\d').hasMatch(value)) {
    return 'Password must contain a number';
  }
  return null;
}

String? validateConfirmPassword(String? value, String original) {
  if (value == null || value.isEmpty) return 'Please confirm password';
  if (value != original) return 'Passwords do not match';
  return null;
}
