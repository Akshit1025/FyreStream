// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:bloc/bloc.dart';

import 'package:fyrestream/model/MediaPlaylistModel.dart';
import 'package:fyrestream/model/chart_model.dart';
import 'package:fyrestream/plugins/chart_defines.dart';
import 'package:fyrestream/repository/Youtube/yt_charts_home.dart';
import 'package:fyrestream/screens/screen/chart/show_charts.dart';
import 'package:fyrestream/services/db/fyrestream_db_service.dart';

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
  ChartCubit(
      this.chartInfo,
      ) : super(ChartInitial()) {
    getChartFromDB();
    getChart();
  }

  void getChart() async {
    final chart = await chartInfo.chartFunction(chartInfo.url);
    emit(state.copyWith(
        chart: chart, coverImg: chart.chartItems?.first.imageUrl));
  }

  void getChartFromDB() async {
    final chart = await FyreStreamDBService.getChart(chartInfo.title);
    if (chart != null) {
      emit(state.copyWith(
          chart: chart, coverImg: chart.chartItems?.first.imageUrl));
    }
  }
}