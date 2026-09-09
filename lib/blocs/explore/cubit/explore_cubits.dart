// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'package:fyrestream/services/db/GlobalDB.dart';
import 'package:bloc/bloc.dart';
import 'package:fyrestream/model/MediaPlaylistModel.dart';
import 'package:fyrestream/model/chart_model.dart';
import 'package:fyrestream/plugins/chart_defines.dart';
import 'package:fyrestream/repository/Youtube/yt_charts_home.dart';
import 'package:fyrestream/screens/screen/chart/show_charts.dart';
import 'package:fyrestream/services/db/fyrestream_db_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

part 'explore_states.dart';

class TrendingCubit extends Cubit<TrendingCubitState> {
  bool isLatest = false;
  TrendingCubit() : super(TrendingCubitInitial()) {
    getTrendingVideosFromDB();
    getTrendingVideos();
  }

  void getTrendingVideos() async {
    final ytCharts = await fetchTrendingVideos();
    emit(state.copyWith(ytCharts: ytCharts));
    isLatest = true;
  }

  void getTrendingVideosFromDB() async {
    final ytChart = await FyreStreamDBService.getChart("Trending Videos");
    if ((!isLatest) &&
        ytChart != null &&
        (ytChart.chartItems?.isNotEmpty ?? false)) {
      emit(state.copyWith(ytCharts: [ytChart]));
    }
  }
}

class RecentlyCubit extends Cubit<RecentlyCubitState> {
  late Stream<void> watcher;
  RecentlyCubit() : super(RecentlyCubitInitial()) {
    FyreStreamDBService.refreshRecentlyPlayed();
    getRecentlyPlayed();
    watchRecentlyPlayed();
  }

  Future<void> watchRecentlyPlayed() async {
    watcher = await FyreStreamDBService.watchRecentlyPlayed();
    watcher.listen((event) {
      getRecentlyPlayed();
      log("Recently Played Updated");
    });
  }

  void getRecentlyPlayed() async {
    final mediaPlaylist = await FyreStreamDBService.getRecentlyPlayed();
    emit(state.copyWith(mediaPlaylist: mediaPlaylist));
  }
}

class ChartCubit extends Cubit<ChartState> {
  ChartInfo chartInfo;
  StreamSubscription? strm;
  FetchChartCubit fetchChartCubit;
  ChartCubit(
      this.chartInfo,
      this.fetchChartCubit,
      ) : super(ChartInitial()) {
    getChartFromDB();
    initListener();
  }

  void initListener() {
    strm = fetchChartCubit.stream.listen((state) {
      if (state.isFetched) {
        log("Chart Fetched from Isolate - ${chartInfo.title}", name: "Isolate Fetched");
        getChartFromDB();
      }
    });
  }

  Future<void> getChartFromDB() async {
    final chart = await FyreStreamDBService.getChart(chartInfo.title);
    if (chart != null) {
      emit(state.copyWith(
          chart: chart, coverImg: chart.chartItems?.first.imageUrl));
    }
  }

  @override
  Future<void> close() {
    fetchChartCubit.close();
    strm?.cancel();
    return super.close();
  }
}

class FetchChartCubit extends Cubit<FetchChartState> {
  FetchChartCubit() : super(FetchChartInitial()) {
    fetchCharts();
  }

  Future<void> fetchCharts() async {
    String _path = (await getApplicationDocumentsDirectory()).path;
    BackgroundIsolateBinaryMessenger.ensureInitialized(
        ServicesBinding.rootIsolateToken!);

    final chartList = await Isolate.run<List<ChartModel>>(() async {
      log(_path, name: "Isolate Path");
      List<ChartModel> _chartList = List.empty(growable: true);
      ChartModel chart;
      final db = await Isar.open(
        [
          ChartsCacheDBSchema,
        ],
        directory: _path,
      );
      for (var i in chartInfoList) {
        final chartCacheDB = db.chartsCacheDBs
            .where()
            .filter()
            .chartNameEqualTo(i.title)
            .findFirstSync();
        if ((chartCacheDB?.lastUpdated.difference(DateTime.now()).inHours ??
            0) >
            12) {
          chart = await i.chartFunction(i.url);
          if ((chart.chartItems?.isNotEmpty) ?? false) {
            db.writeTxnSync(() =>
                db.chartsCacheDBs.putSync(chartModelToChartCacheDB(chart)));
          }
          log("Chart Fetched - ${chart.chartName}", name: "Isolate");
          _chartList.add(chart);
        }
      }
      db.close();
      return _chartList;
    });

    if (chartList.isNotEmpty) {
      emit(state.copyWith(isFetched: true));
    }
  }
}