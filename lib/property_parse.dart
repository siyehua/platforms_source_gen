class Property {
  String type = "";
  String name = "";
  String defaultValue1 = "";
  bool isStatic = false;
  bool isConst = false;
  bool isFinal = false;
  bool isPrivate = false;
  List<Property> subType = []; //sub type, for example: list ,  map , Future

  Property.fromJson(Map<String, dynamic> json) {
    // typeInt = json['typeInt'];
    type = json['type'];
    name = json['name'];
    defaultValue1 = json['defaultValue1'];
    isStatic = json['isStatic'];
    isConst = json['isConst'];
    isFinal = json['isFinal'];
    isPrivate = json['isPrivate'];
    if (json['subType'] != null) {
      subType = [];
      json['subType'].forEach((v) {
        subType.add(new Property.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // data['typeInt'] = this.typeInt;
    data['type'] = this.type;
    data['name'] = this.name;
    data['defaultValue1'] = this.defaultValue1;
    data['isStatic'] = this.isStatic;
    data['isConst'] = this.isConst;
    data['isFinal'] = this.isFinal;
    data['isPrivate'] = this.isPrivate;
    if (this.subType != null) {
      data['subType'] = this.subType.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return """{
                "type": "$type", 
                "name": "$name", 
                "defaultValue1": "$defaultValue1", 
                "isStatic": $isStatic, 
                "isConst": $isConst, 
                "isFinal": $isFinal, 
                "isPrivate": $isPrivate, 
                "subType": $subType, 
              }""";
  }

  Property();
}
