/// edit gen file content
class GenFileEdit {
  /// remove dart nullSafe keywords
  static String removeDartNullSafe(String content) {
    return content.replaceAll("!", "").replaceAll("?", "");
  }

  /// remove java nullSafe keywords
  static String removeJavaNullSafe(String content) {
    return content.replaceAll("@Nullable", "").replaceAll("@NotNull", "");
  }
}
