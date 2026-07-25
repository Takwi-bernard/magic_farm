class Validators {

  Validators._();

  static String? email(String? value) {

    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Enter a valid email";
    }

    return null;
  }

  static String? password(String? value) {

    if (value == null || value.isEmpty) {
      return "Password is required";
    }

    if (value.length < 6) {
      return "Minimum 6 characters";
    }

    return null;
  }

  static String? requiredField(String? value) {

    if (value == null || value.trim().isEmpty) {
      return "This field is required";
    }

    return null;
  }
}