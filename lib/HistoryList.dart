class HistoryList {
  int _id;
  String _code;
  String _reward;
  String _date;

  HistoryList(this._code, this._reward, this._date);
  HistoryList.withId(this._id, this._code, this._reward, this._date);

  int get id => _id;
  String get code => _code;
  String get reward => _reward;
  String get date => _date;

  set code(String newCode) {
    this._code = newCode;
  }

  set reward(String newReward) {
    this._reward = newReward;
  }

  set date(String newDate) {
    this._date = newDate;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['code'] = _code;
    map['reward'] = _reward;
    map['date'] = _date;

    return map;
  }

  HistoryList.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._code = map['code'];
    this._reward = map['reward'];
    this._date = map['date'];
  }
}
