import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/location_search_response.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/widgets/select_current_location.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  TextEditingController textEditingController = TextEditingController();

  LocationSearchResponse? response;

  bool _isSearching = false;

  String getSearchUrl(String query) {
    final encodedQuery = Uri.encodeComponent(query);
    return 'https://photon.komoot.io/api/?q=${query}&limit=10';
  }

  Future<void> _searchLocations(String query) async {
    try {
      setState(() {
        _isSearching = true;
      });

      // search logic here

      // final res = LocationSearchResponse.fromJson(response?.body)

      // res.features.first.properties.name

      setState(() {
        response = LocationSearchResponse();
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      // Handle error appropriately
    }
  }

  @override
  void initState() {
    super.initState();

    textEditingController.addListener(
      () => debouncer.value = textEditingController.text,
    );
    debouncer.values.listen((search) => _searchLocations(search));
  }

  final debouncer = Debouncer<String>(
    Duration(
      milliseconds: 200,
    ),
    initialValue: '',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Select a location",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          child: Column(
            spacing: 16,
            children: [
              SizedBox(
                // width: 320,
                height: 45,
                child: TextFormField(
                  onChanged: (value) {
                    _searchLocations(value);
                  },
                  style: TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.grey.withAlpha(100),
                      ),
                    ),
                    hintText: "Search an area",
                    hintStyle: TextStyle(
                      color: Colors.grey.withAlpha(120),
                      fontWeight: FontWeight.bold,
                      fontSize: 15.5,
                    ),
                    prefixIcon: Icon(Icons.search_rounded),
                    prefixIconColor: Color.fromARGB(255, 30, 136, 229),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: SizedBox(
                      width: 16,
                      height: 16,
                      child: Center(
                        child: IconButton.filled(
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            fixedSize: Size(16, 16),
                            backgroundColor: Colors.grey,
                          ),
                          icon: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SelectCurrentLocationScreen(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  height: 45,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.gps_fixed_sharp,
                          color: Colors.red,
                          size: 26,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Use current location",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),

                  child: Column(
                    children: [
                      _LocationList(
                        icon: Icons.home_outlined,
                        distance: "5.6 km",
                        location: "Home",
                        city: "Azhikode",
                        district: "Kannur",
                        state: "Kerala",
                      ),
                      _Separator(),
                      _LocationList(
                        icon: Icons.location_on_outlined,
                        distance: "5.0 km",
                        location: "Kannur Jn",
                        city: "Padanapalam",
                        district: "Kannur",
                        state: "Kerala",
                      ),
                      _Separator(),
                      _LocationList(
                        icon: Icons.location_on_outlined,
                        distance: "21 km",
                        location: "Kannur International Airport",
                        city: "Mattanur",
                        district: "Kannur",
                        state: "Kerala",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.grey[100],
      thickness: 2,
      height: 3,
    );
  }
}

class _LocationList extends StatelessWidget {
  final IconData icon;
  final String distance;
  final String location;
  final String city;
  final String district;
  final String state;

  const _LocationList({
    required this.icon,
    required this.distance,
    required this.location,
    required this.city,
    required this.district,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity(horizontal: 0, vertical: -1),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 27.5,
          ),
          Text(
            distance,
            style: TextStyle(fontSize: 9.0),
          ),
        ],
      ),
      title: Text(
        location,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        "$city,$district,$state",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 11.0,
        ),
      ),
    );
  }
}
