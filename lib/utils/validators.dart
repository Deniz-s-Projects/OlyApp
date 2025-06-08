String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Email is required';
  final emailRegex = RegExp(r"^[^@]+@[^@]+\.[^@]+$");
  if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < 6) return 'Password must be at least 6 characters';
  return null;
}

String? validateConfirmPassword(String? value, String original) {
  if (value == null || value.isEmpty) return 'Please confirm password';
  if (value != original) return 'Passwords do not match';
  return null;
}
