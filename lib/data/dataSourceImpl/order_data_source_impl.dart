import 'package:dartz/dartz.dart';
import 'package:foodies_app/data/api_manager.dart';
import 'package:foodies_app/domain/failures.dart';
import 'package:foodies_app/domain/model/DeliveryAddress.dart';
import 'package:foodies_app/domain/model/OnlineOrder.dart';
import 'package:injectable/injectable.dart';

import '../../domain/model/OrderEntity.dart';
import '../dataSourceContract/order_data_source.dart';

@Injectable(as: OrderDataSource)
class OrderDataSourceImpl extends OrderDataSource {
  ApiManager apiManager;

  @factoryMethod
  OrderDataSourceImpl(this.apiManager);

  @override
  Future<Either<Failures, OrderEntity>> createOnlineOrder(
      {required DeliveryAddress deliveryAddress}) async {
    var either =
        await apiManager.createOnlineOrder(deliveryAddress: deliveryAddress);
    return either.fold((error) {
      return Left(Failures(errorMessage: error.errorMessage));
    }, (response) {
      return Right(response.data!.toOrderEntity());
    });
  }

  @override
  Future<Either<Failures, OnlineOrder>> deleteOrder() {
    // TODO: implement deleteOrder
    throw UnimplementedError();
  }

  @override
  Future<Either<Failures, OrderEntity>> getOrder({required String orderId}) async {
    var either =
        await apiManager.getOrder(orderId: orderId);
    return either.fold((error) {
      return Left(Failures(errorMessage: error.errorMessage));
    }, (response) {
      return Right(response.data!.toOrderEntity());
    });

  }

  @override
  Future<Either<Failures, List<OrderEntity>>> getAllOrders() async {
    var either =
        await apiManager.getAllOrders();
    return either.fold((error) {
      return Left(Failures(errorMessage: error.errorMessage));
    }, (response) {
      return Right(response.data!.map((order) => order.toOrderEntity()).toList());
    });

  }

  @override
  Future<Either<Failures, OnlineOrder>> updateOrder() {
    // TODO: implement updateOrder
    throw UnimplementedError();
  }

  @override
  Future<Either<Failures, OrderEntity>> createCashOrder(
      {required DeliveryAddress deliveryAddress}) async {
    var either =
        await apiManager.createCashOrder(deliveryAddress: deliveryAddress);
    return either.fold((error) {
      return Left(Failures(errorMessage: error.errorMessage));
    }, (response) {
      return Right(response.data!.toOrderEntity());
    });
  }

  @override
  Future<Either<Failures, OrderEntity>> reOrder(
      {required String orderId}) async {
    var either = await apiManager.reOrder(orderId: orderId);
    return either.fold((error) {
      return Left(Failures(errorMessage: error.errorMessage));
    }, (response) {
      return Right(response.data!.toOrderEntity());
    });
  }
}
