class PaymentCalc {

  double getAttendanceMultiplier(int attendanceCount){
    double multiplier = 0.75;
    if (attendanceCount > 5 && attendanceCount <= 10){
      multiplier = 0.85;
    } else if (attendanceCount > 10 && attendanceCount <= 20){
      multiplier = 1.00;
    } else if (attendanceCount > 20 && attendanceCount <= 100){
      multiplier = 1.25;
    } else if (attendanceCount > 100 && attendanceCount <= 500){
      multiplier = 1.75;
    } else if (attendanceCount > 500 && attendanceCount <= 1000){
      multiplier = 2.00;
    } else if (attendanceCount > 1000 && attendanceCount <= 2000){
      multiplier = 2.15;
    } else if (attendanceCount > 2000){
      multiplier = 2.5;
    }
    return multiplier;
  }

  double getEventValueEstimate(int turnoutEstimate){
    double estimate = turnoutEstimate * getAttendanceMultiplier(turnoutEstimate).toDouble();
    return estimate;
  }

  double getPotentialEarnings(int turnoutEstimate){
    double eventVal = turnoutEstimate * getAttendanceMultiplier(turnoutEstimate).toDouble();
    double earnings = eventVal/turnoutEstimate.toDouble();
    return earnings.isNaN? 0.00 : earnings;
  }

}