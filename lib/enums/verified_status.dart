enum VerifiedStatus {
  verified,
  pending,
  unverified,
}

class VerifiedStatusConverter {
  static VerifiedStatus stringToVerifiedStatus(String verifiedStatus) {
    if (verifiedStatus == 'verified') {
      return VerifiedStatus.verified;
    } else if (verifiedStatus == 'pending') {
      return VerifiedStatus.pending;
    } else {
      return VerifiedStatus.unverified;
    }
  }

  static String verifiedStatusToString(VerifiedStatus verifiedStatus) {
    if (verifiedStatus == VerifiedStatus.verified) {
      return 'verified';
    } else if (verifiedStatus == VerifiedStatus.pending) {
      return 'pending';
    } else {
      return 'unverified';
    }
  }
}
