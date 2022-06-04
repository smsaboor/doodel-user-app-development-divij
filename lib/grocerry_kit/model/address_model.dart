class Address {
  String address;
  double lat;
  double lng;

  Address({
    this.address,
    this.lat,
    this.lng,
  });

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
    };
  }

  Address.fromMap(Map<String, dynamic> map) {
    this.lat = map['lat'];
    this.lng = map['lng'];
    this.address = map['address'];
  }
}
