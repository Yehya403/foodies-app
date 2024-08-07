import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodies_app/ui/home/profile_tab/settings/my_addresses/maps/location_helper.dart';
import 'package:foodies_app/ui/home/profile_tab/settings/my_addresses/maps/place_item.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:uuid/uuid.dart';
import '../../../../../../di/di.dart';
import '../../../../../../domain/model/place.dart';
import '../../../../../../domain/model/place_suggestions.dart';
import '../form_address/form_address_screen.dart';
import 'cubit/maps_cubit.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  static const String routeName = 'map_screen';

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<PlaceSuggestion> places = [];


  FloatingSearchBarController controller = FloatingSearchBarController();
  static Position? position;
  Completer<GoogleMapController> _mapController = Completer();
  static final CameraPosition _myCurrentLocationCameraPosition = CameraPosition(
    bearing: 0.0,
    target: LatLng(position!.latitude, position!.longitude),
    tilt: 0.0,
    zoom: 17,
  );

  //these variables for getPlaceLocation
  Set<Marker> markers = Set();
  PlaceSuggestion? placeSuggestion;
  late Place selectedPlace;
  late Marker searchedPlaceMarker;
  late Marker currentLocationMarker;
  late CameraPosition goToSearchedForPlace;

  void buildCameraNewPosition() {
    goToSearchedForPlace = CameraPosition(
      bearing: 0.0,
      tilt: 0.0,
      target: LatLng(
        selectedPlace.result.geometry.location.lat,
        selectedPlace.result.geometry.location.lng,
      ),
      zoom: 13,
    );
  }

  var viewModel = getIt<MapsCubit>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyCurrentLocation();
  }

  Future<void> getMyCurrentLocation() async {
    await LocationHelper.getCurrentLocation();
    position = await LocationHelper.getCurrentLocation().whenComplete(() {
      setState(() {});
    });
  }
  Widget buildMap() {
    return GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      markers: markers,
      initialCameraPosition: _myCurrentLocationCameraPosition,
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
      },
      /*polylines: placeDirections != null
          ? {
        Polyline(
          polylineId: const PolylineId('my_polyline'),
          color: Colors.black,
          width: 2,
          points: polylinePoints,
        ),
      }
          : {},*/
    );
  }
  Future<void> _goToMyCurrentLocation() async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(_myCurrentLocationCameraPosition));
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      controller: controller,
      elevation: 3,
      hintStyle: const TextStyle(fontSize: 18),
      queryStyle: const TextStyle(fontSize: 18),
      hint: 'Find a place..',
      border: const BorderSide(style: BorderStyle.none),
      margins: const EdgeInsets.fromLTRB(8, 32, 8, 0),
      padding: const EdgeInsets.all(0),
      height: 54,
      iconColor: Theme.of(context).primaryColor,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 600),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      //progress: progressIndicator,
      onQueryChanged: (query) {
       getPlacesSuggestions(query);
      },
      onFocusChanged: (_) {
        // hide distance and time row
        /*setState(() {
          isTimeAndDistanceVisible = false;
        });*/
      },
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
              icon: Icon(Icons.place, color: Theme.of(context).primaryColor),
              onPressed: () {}),
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildSuggestionsBloc(),
              buildSelectedPlaceLocationBloc(),
              //buildDiretionsBloc(),
            ],
          ),
        );
      },
    );

  }


  Widget buildSelectedPlaceLocationBloc() {
    return BlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is PlaceLocationLoaded) {
          selectedPlace = (state).place;

          goToMySearchedForLocation();
          //getDirections();
        }
      },
      child: Container(),
    );
  }

  Future<void> goToMySearchedForLocation() async {
    buildCameraNewPosition();
    final GoogleMapController controller = await _mapController.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(goToSearchedForPlace));
    buildSearchedPlaceMarker();
  }

  void buildSearchedPlaceMarker() {
    searchedPlaceMarker = Marker(
      position: goToSearchedForPlace.target,
      markerId: const MarkerId('1'),
      onTap: () {
        buildCurrentLocationMarker();
        // show time and distance
        /* setState(() {
          isSearchedPlaceMarkerClicked = true;
          isTimeAndDistanceVisible = true;
        });*/
      },
      infoWindow: InfoWindow(title: "${placeSuggestion?.description}"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    addMarkerToMarkersAndUpdateUI(searchedPlaceMarker);
  }

  void buildCurrentLocationMarker() {
    currentLocationMarker = Marker(
      position: LatLng(position!.latitude, position!.longitude),
      markerId: const MarkerId('2'),
      onTap: () {},
      infoWindow: const InfoWindow(title: "Your current Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    addMarkerToMarkersAndUpdateUI(currentLocationMarker);
  }

  void addMarkerToMarkersAndUpdateUI(Marker marker) {
    setState(() {
      markers.add(marker);
    });
  }

  void removeAllMarkersAndUpdateUI() {
    setState(() {
      markers.clear();
    });
  }

  void getPlacesSuggestions(String query) {
    final sessionToken = const Uuid().v4();
    viewModel.emitPlaceSuggestions(query, sessionToken);
  }

  Widget buildSuggestionsBloc() {
    return BlocBuilder<MapsCubit, MapsState>(
      builder: (context, state) {
        if (state is PlacesLoaded) {
          places = (state).places;
          if (places.length != 0) {
            return buildPlacesList();
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }


  Widget buildPlacesList() {
    return ListView.builder(
        itemBuilder: (ctx, index) {
          return InkWell(
            //key: UniqueKey(), // Assign a unique key to each InkWell
            onTap: () async {
              placeSuggestion = places[index];
              controller.close();
              getSelectedPlaceLocation();
              //polylinePoints.clear();
              removeAllMarkersAndUpdateUI();
            },
            child: PlaceItem(
              suggestion: places[index],
            ),
          );
        },
        itemCount: places.length,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics());
  }

  void getSelectedPlaceLocation() {
    final sessionToken = const Uuid().v4();
    viewModel.emitPlaceLocation(placeSuggestion?.placeId ?? '', sessionToken);
  }


    @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => viewModel,
      child: BlocBuilder<MapsCubit, MapsState>(
        builder: (context, state) {
          return Scaffold(
            //appBar: AppBar(title: const Text('Map'),),
            body: Stack(
              fit: StackFit.expand,
              children: [
                position != null
                    ? buildMap()
                    : Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                buildFloatingSearchBar(),
                Positioned(
                  bottom: 43, // Adjust the bottom position as needed
                  left: 24, // Adjust the left position as needed
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                          FormAddressScreen.routeName,
                          arguments: placeSuggestion?.description);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      // Change the button's background color
                      foregroundColor: Colors.white,
                      // Change the button's text color
                      elevation: 4,
                      // Add elevation to the button
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      // Adjust padding as needed
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8), // Adjust border radius as needed
                      ),
                    ),
                    child: const Text("Confirm Address"),
                  ),
                ),
              ],
            ),

            floatingActionButton: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 8, 30),
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: _goToMyCurrentLocation,
                child: const Icon(
                  Icons.place_outlined,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
