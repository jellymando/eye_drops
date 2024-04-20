class DataItem {
  final String type;
  final String time;

  DataItem(this.type, this.time);

  // Convert the item to a JSON object
  Map<String, dynamic> toJson() {
    return {'type': type, 'time': time};
  }

  // Create an Item object from a JSON object
  factory DataItem.fromJson(Map<String, dynamic> json) {
    return DataItem(json['type'], json['time']);
  }
}

class DataMap {
  final Map<String, List<DataItem>> dataMap;

  DataMap(this.dataMap);

  // Convert the data to a JSON object
  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonMap = {};
    dataMap.forEach((date, items) {
      jsonMap[date] = items.map((item) => item.toJson()).toList();
    });
    return jsonMap;
  }

  // Create a Data object from a JSON object
  factory DataMap.fromJson(Map<String, dynamic> json) {
    Map<String, List<DataItem>> dataMap = {};
    json.forEach((date, itemList) {
      dataMap[date] = (itemList as List)
          .map((itemJson) => DataItem.fromJson(itemJson))
          .toList();
    });
    return DataMap(dataMap);
  }
}
