part of values;

class Borders {
  static const BorderSide borderSide = BorderSide(color: AppColors.grey3, width: 1.0);
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(5));

  static const OutlineInputBorder border = OutlineInputBorder(
    borderSide: borderSide,
    borderRadius: borderRadius,
  );

  static const OutlineInputBorder enabledBorder = OutlineInputBorder(
    borderSide: borderSide,
    borderRadius: borderRadius,
  );

  static const OutlineInputBorder focusedBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: AppColors.nord2, width: 1.0),
    borderRadius: borderRadius,
  );

  static const OutlineInputBorder errorBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.red, width: 1),
    borderRadius: borderRadius,
  );

  static customBorder({double borderRadius = 5}) {
    return OutlineInputBorder(
      borderSide: borderSide,
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
    );
  }

  static customFocusedBorder({double borderRadius = 5}) {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.nord2, width: 1.0),
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
    );
  }
}
