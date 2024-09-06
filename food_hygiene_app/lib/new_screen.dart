import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class NewScreen extends StatefulWidget {
  final String search;
  final String address;

  NewScreen({Key? key, required this.search, required this.address})
      : super(key: key);

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;
  List<Establishments> data = [];
  int currentPage = 0;
  int totalPages = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    fetchUsers();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (currentPage < totalPages) {
        setState(() {
          isLoadingMore = true;
          currentPage++;
        });
        fetchUsers().then((_) {
          setState(() {
            isLoadingMore = false;
          });
        });
      } else {
        _scrollController.removeListener(_scrollListener);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("No More Data")));
      }
    }
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    String url =
        'https://api.ratings.food.gov.uk/Establishments?name=${widget.search}&address=${widget.address}&pageSize=25';
    final response = await http.get(
      Uri.parse(url),
      headers: {'x-api-version': '2', 'Accept-Language': 'cy-GB'},
    );

    if (response.statusCode == 200) {
      UserDetails userDetails =
      UserDetails.fromJson(jsonDecode(response.body));
      totalPages = userDetails.meta!.totalPages ?? 0;
      if (userDetails.establishments != null) {
        setState(() {
          data.addAll(userDetails.establishments!);
        });
      }
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }

    setState(() {
      isLoading = false;
    });
  }

  String formatRatingDate(String ratingDate) {
    DateTime dateTime = DateTime.parse(ratingDate);
    DateFormat ukDateFormat = DateFormat('dd/MM/yyyy');
    return ukDateFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Result',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700),),
        backgroundColor: Colors.yellow,
      ),
      body: Stack(
        children: [
          Scrollbar(
            thickness: 8,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: isLoadingMore ? data.length + 1 : data.length + 1,
              itemBuilder: (context, index) {
                if (index < data.length) {
                  return Card(
                    elevation: 1.9,
                    child: Column(
                      children: [
                        ListTile(
                          visualDensity: VisualDensity(vertical: -1),
                          dense: true,
                          title: Text(
                            data[index].businessName ?? '',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            data[index].businessType ?? '',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        if (data[index].addressLine1 != "" &&
                            data[index].addressLine2 != "" &&
                            data[index].addressLine3 != "" &&
                            data[index].addressLine4 != "")
                          ListTile(
                            dense: true,
                            leading: Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 31,
                              ),
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                data[index].addressLine1 ?? '',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ListTile(
                          dense: true,
                          leading: Padding(
                            padding: const EdgeInsets.only(bottom: 1),
                            child: Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 31,
                            ),
                          ),
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 1),
                            child: Text(
                              data[index].ratingValue ?? '',
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                        ),
                        ListTile(
                          dense: true,
                          leading: Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text("Last Rated On:" +
                                formatRatingDate(data[index].ratingDate ?? '')),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (isLoadingMore) {
                  return Center(child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ));
                } else {
                  return Container(); // Placeholder for the loader
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserDetails {
  List<Establishments>? establishments;
  Meta? meta;
  List<Links>? links;
  UserDetails({this.establishments, this.meta, this.links});
  UserDetails.fromJson(Map<String, dynamic> json) {
    if (json['establishments'] != null) {
      establishments = <Establishments>[];
      json['establishments'].forEach((v) {
        establishments!.add(Establishments.fromJson(v));
      });
    }
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.establishments != null) {
      data['establishments'] =
          this.establishments!.map((v) => v.toJson()).toList();
    }
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
    }
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Establishments {
  int? fHRSID;
  int? changesByServerID;
  String? localAuthorityBusinessID;
  String? businessName;
  String? businessType;
  int? businessTypeID;
  String? addressLine1;
  String? addressLine2;
  String? addressLine3;
  String? addressLine4;
  String? postCode;
  String? phone;
  String? ratingValue;
  String? ratingKey;
  String? ratingDate;
  String? localAuthorityCode;
  String? localAuthorityName;
  String? localAuthorityWebSite;
  String? localAuthorityEmailAddress;
  Scores? scores;
  String? schemeType;
  Geocode? geocode;
  String? rightToReply;
  Null? distance;
  bool? newRatingPending;

  Establishments(
      {this.fHRSID,
        this.changesByServerID,
        this.localAuthorityBusinessID,
        this.businessName,
        this.businessType,
        this.businessTypeID,
        this.addressLine1,
        this.addressLine2,
        this.addressLine3,
        this.addressLine4,
        this.postCode,
        this.phone,
        this.ratingValue,
        this.ratingKey,
        this.ratingDate,
        this.localAuthorityCode,
        this.localAuthorityName,
        this.localAuthorityWebSite,
        this.localAuthorityEmailAddress,
        this.scores,
        this.schemeType,
        this.geocode,
        this.rightToReply,
        this.distance,
        this.newRatingPending});

  Establishments.fromJson(Map<String, dynamic> json) {
    fHRSID = json['FHRSID'];
    changesByServerID = json['ChangesByServerID'];
    localAuthorityBusinessID = json['LocalAuthorityBusinessID'];
    businessName = json['BusinessName'];
    businessType = json['BusinessType'];
    businessTypeID = json['BusinessTypeID'];
    addressLine1 = json['AddressLine1'];
    addressLine2 = json['AddressLine2'];
    addressLine3 = json['AddressLine3'];
    addressLine4 = json['AddressLine4'];
    postCode = json['PostCode'];
    phone = json['Phone'];
    ratingValue = json['RatingValue'];
    ratingKey = json['RatingKey'];
    ratingDate = json['RatingDate'];
    localAuthorityCode = json['LocalAuthorityCode'];
    localAuthorityName = json['LocalAuthorityName'];
    localAuthorityWebSite = json['LocalAuthorityWebSite'];
    localAuthorityEmailAddress = json['LocalAuthorityEmailAddress'];
    scores =
    json['scores'] != null ? new Scores.fromJson(json['scores']) : null;
    schemeType = json['SchemeType'];
    geocode =
    json['geocode'] != null ? new Geocode.fromJson(json['geocode']) : null;
    rightToReply = json['RightToReply'];
    distance = json['Distance'];
    newRatingPending = json['NewRatingPending'];
  }

  get someList => null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FHRSID'] = this.fHRSID;
    data['ChangesByServerID'] = this.changesByServerID;
    data['LocalAuthorityBusinessID'] = this.localAuthorityBusinessID;
    data['BusinessName'] = this.businessName;
    data['BusinessType'] = this.businessType;
    data['BusinessTypeID'] = this.businessTypeID;
    data['AddressLine1'] = this.addressLine1;
    data['AddressLine2'] = this.addressLine2;
    data['AddressLine3'] = this.addressLine3;
    data['AddressLine4'] = this.addressLine4;
    data['PostCode'] = this.postCode;
    data['Phone'] = this.phone;
    data['RatingValue'] = this.ratingValue;
    data['RatingKey'] = this.ratingKey;
    data['RatingDate'] = this.ratingDate;
    data['LocalAuthorityCode'] = this.localAuthorityCode;
    data['LocalAuthorityName'] = this.localAuthorityName;
    data['LocalAuthorityWebSite'] = this.localAuthorityWebSite;
    data['LocalAuthorityEmailAddress'] = this.localAuthorityEmailAddress;
    if (this.scores != null) {
      data['scores'] = this.scores!.toJson();
    }
    data['SchemeType'] = this.schemeType;
    if (this.geocode != null) {
      data['geocode'] = this.geocode!.toJson();
    }
    data['RightToReply'] = this.rightToReply;
    data['Distance'] = this.distance;
    data['NewRatingPending'] = this.newRatingPending;
    return data;
  }
}

class Scores {
  int? hygiene;
  int? structural;
  int? confidenceInManagement;

  Scores({this.hygiene, this.structural, this.confidenceInManagement});

  Scores.fromJson(Map<String, dynamic> json) {
    hygiene = json['Hygiene'];
    structural = json['Structural'];
    confidenceInManagement = json['ConfidenceInManagement'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Hygiene'] = this.hygiene;
    data['Structural'] = this.structural;
    data['ConfidenceInManagement'] = this.confidenceInManagement;
    return data;
  }
}

class Geocode {
  String? longitude;
  String? latitude;

  Geocode({this.longitude, this.latitude});

  Geocode.fromJson(Map<String, dynamic> json) {
    longitude = json['longitude'];
    latitude = json['latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    return data;
  }
}

class Meta {
  String? dataSource;
  String? extractDate;
  int? itemCount;
  String? returncode;
  int? totalCount;
  int? totalPages;
  int? pageSize;
  int? pageNumber;

  Meta(
      {this.dataSource,
        this.extractDate,
        this.itemCount,
        this.returncode,
        this.totalCount,
        this.totalPages,
        this.pageSize,
        this.pageNumber});

  Meta.fromJson(Map<String, dynamic> json) {
    dataSource = json['dataSource'];
    extractDate = json['extractDate'];
    itemCount = json['itemCount'];
    returncode = json['returncode'];
    totalCount = json['totalCount'];
    totalPages = json['totalPages'];
    pageSize = json['pageSize'];
    pageNumber = json['pageNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dataSource'] = this.dataSource;
    data['extractDate'] = this.extractDate;
    data['itemCount'] = this.itemCount;
    data['returncode'] = this.returncode;
    data['totalCount'] = this.totalCount;
    data['totalPages'] = this.totalPages;
    data['pageSize'] = this.pageSize;
    data['pageNumber'] = this.pageNumber;
    return data;
  }
}

class Links {
  String? rel;
  String? href;

  Links({this.rel, this.href});

  Links.fromJson(Map<String, dynamic> json) {
    rel = json['rel'];
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rel'] = this.rel;
    data['href'] = this.href;
    return data;
  }
}
