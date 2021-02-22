String getLastWordInString(String val) {
  List words = val.split(" ");
  return words.last;
}

String replaceLastWordInString(String originalString, String newWord) {
  if (originalString.split(" ").length == 1) {
    return "$newWord";
  } else {
    return originalString.substring(0, originalString.lastIndexOf(" ")) + " $newWord";
  }
}
