class WebblenAchievements {

  String uid;
  String involvementStatusLevel;
  bool attendFirstEvent;
  bool createFirstEvent;
  bool attendEventWith10Plus;
  bool attendEventWith50Plus;
  bool attendEventWith100Plus;
  bool attendEventWith500Plus;
  bool attendEventWith1000Plus;
  bool joinFirstGroup;
  bool goToEventWithGroup;
  bool attendEventBefore10AM;
  bool attendEventAfter12AM;

  WebblenAchievements({
    this.involvementStatusLevel,
    this.attendFirstEvent,
    this.createFirstEvent,
    this.attendEventWith10Plus,
    this.attendEventWith50Plus,
    this.attendEventWith100Plus,
    this.attendEventWith500Plus,
    this.attendEventWith1000Plus,
    this.joinFirstGroup,
    this.goToEventWithGroup,
    this.attendEventBefore10AM,
    this.attendEventAfter12AM
  });

  WebblenAchievements.fromMap(Map<String, dynamic> data)
      : this(involvementStatusLevel: data['involvementStatusLevel'],
      attendFirstEvent: data['attendFirstEvent'],
      createFirstEvent: data['createFirstEvent'],
      attendEventWith10Plus: data['attendEventWith10Plus'],
      attendEventWith50Plus: data['attendEventWith50Plus'],
      attendEventWith100Plus: data['attendEventWith100Plus'],
      attendEventWith500Plus: data['attendEventWith500Plus'],
      attendEventWith1000Plus: data['attendEventWith1000Plus'],
      joinFirstGroup: data['joinFirstGroup'],
      goToEventWithGroup: data['goToEventWithGroup'],
      attendEventBefore10AM: data['attendEventBefore10AM'],
      attendEventAfter12AM: data['attendEventAfter12AM']
  );

  Map<String, dynamic> toMap() => {
    'involvementStatusLevel': this.involvementStatusLevel,
    'attendFirstEvent': this.attendFirstEvent,
    'createFirstEvent': this.createFirstEvent,
    'attendEventWith10Plus': this.attendEventWith10Plus,
    'attendEventWith50Plus': this.attendEventWith50Plus,
    'attendEventWith100Plus': this.attendEventWith100Plus,
    'attendEventWith500Plus': this.attendEventWith500Plus,
    'attendEventWith1000Plus': this.attendEventWith1000Plus,
    'joinFirstGroup': this.joinFirstGroup,
    'goToEventWithGroup': this.goToEventWithGroup,
    'attendEventBefore10AM': this.attendEventBefore10AM,
    'attendEventAfter12AM': this.attendEventAfter12AM
  };
}