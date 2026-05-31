import 'package:dartz/dartz.dart';
import 'package:lost_n_found/core/error/failures.dart';
import 'package:lost_n_found/features/batch/data/datasources/remote/batch_datasource.dart';
import 'package:lost_n_found/features/batch/data/models/batch_hive_model.dart';
import 'package:lost_n_found/features/batch/domain/entities/batch_entity.dart';
import 'package:lost_n_found/features/batch/domain/repositories/batch_repository.dart';

class BatchRepository implements IBatchRepository{

  final IBatchDataSource _dataDatasource;

  BatchRepository({required IBatchDataSource datasource})
  : _dataDatasource=datasource;
  @override
  Future<Either<Failure, bool>> createBatch(BatchEntity entity) async{
    try{
      //convert entity into model
      final model=BatchHiveModel.fromEntity(entity);
      final result=await _dataDatasource.createBatch(model);
      if(result){
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to create batch'));

    }catch (e){
      return Left(LocalDatabaseFailure(message: e.toString()));

    }
  }

   @override
  Future<Either<Failure, bool>> deleteBatch(String batchId) async {
    try {
      final result = await _dataDatasource.deleteBatch(batchId);
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to delete batch'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BatchEntity>>> getAllBatches()async {
    try{
      final models= await _dataDatasource.getAllBatches();
      final entities= BatchHiveModel.toEntityList(models);
      return Right(entities);

    }catch(e){
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

   @override
  Future<Either<Failure, BatchEntity>> getBatchById(String batchId) async {
    try {
      // fetch all and filter by id — avoids needing a separate datasource method
      final models = await _dataDatasource.getAllBatches();
      final match = models.where((m) => m.batchId == batchId).firstOrNull;

      if (match == null) {
        return Left(LocalDatabaseFailure(message: 'Batch not found'));
      }
      return Right(match.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateBatch(BatchEntity entity) async {
    try {
      // Validate the entity has an id before attempting update
      if (entity.batchId == null) {
        return Left(LocalDatabaseFailure(message: 'Batch ID is required for update'));
      }
      final model = BatchHiveModel.fromEntity(entity);
      final result = await _dataDatasource.updateBatch(model);
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to update batch'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}