enum ClothingSize {
  XS,
  S,
  M,
  L,
  XL,
  XXL,
  XXXL,
}

class ClothingSizeConverter {
  static ClothingSize stringToClothingSize(String clothingSize) {
    if (clothingSize == 'XS') {
      return ClothingSize.XS;
    } else if (clothingSize == 'S') {
      return ClothingSize.S;
    } else if (clothingSize == 'M') {
      return ClothingSize.M;
    } else if (clothingSize == 'L') {
      return ClothingSize.L;
    } else if (clothingSize == 'XL') {
      return ClothingSize.XL;
    } else if (clothingSize == 'XXL') {
      return ClothingSize.XXL;
    } else {
      return ClothingSize.XXL;
    }
  }

  static String clothingSizeToString(ClothingSize clothingSize) {
    if (clothingSize == ClothingSize.XS) {
      return 'XS';
    } else if (clothingSize == ClothingSize.S) {
      return 'S';
    } else if (clothingSize == ClothingSize.M) {
      return 'M';
    } else if (clothingSize == ClothingSize.L) {
      return 'L';
    } else if (clothingSize == ClothingSize.XL) {
      return 'XL';
    } else if (clothingSize == ClothingSize.XXL) {
      return 'XXL';
    } else {
      return 'XXXL';
    }
  }
}
