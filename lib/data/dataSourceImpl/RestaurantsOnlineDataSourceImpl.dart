import 'package:foodies_app/data/api_manager.dart';
import 'package:foodies_app/domain/model/Restaurant.dart';
import 'package:injectable/injectable.dart';

import '../dataSourceContract/RestaurantsDataSource.dart';

@Injectable(as: RestaurantsDataSource)
class RestaurantsOnlineDataSourceImpl extends RestaurantsDataSource {
  ApiManager apiManager;

  @factoryMethod
  RestaurantsOnlineDataSourceImpl(this.apiManager);

  @override
  Future<List<Restaurant>?> getRestaurants() async {
    var response = await apiManager.getRestaurants();
    return response.data
        ?.map((restaurantDto) => restaurantDto.toRestaurant())
        .toList();
  }
}