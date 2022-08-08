import 'dart:core';
import 'CostPageViewBean.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///UI全局单例
class CostPageViewSingleton {

  static CostPageViewSingleton? _instance;

  ///默认颜色
  Color baseColor = Color.fromRGBO(87, 119, 142, 1);
  Color baseColor2 = Color.fromRGBO(121, 153, 174, 1);
  Color baseColor3 = Color.fromRGBO(149, 179, 199, 1);
  Color baseColor4 = Color.fromRGBO(173, 192, 201, 1);
  Color baseColor5 = Color.fromRGBO(224, 230, 230, 1);


  ///分页色彩
  List<Color> myHomePageColors = [
    Color.fromRGBO(223, 109, 46, 1),
    Color.fromRGBO(255, 186, 109, 1),
    Color.fromRGBO(250, 216, 152, 1),
    Color.fromRGBO(223, 109, 46, 1),
    Color.fromRGBO(255, 186, 109, 1),
    Color.fromRGBO(250, 216, 152, 1),
    Color.fromRGBO(223, 109, 46, 1),
    Color.fromRGBO(255, 186, 109, 1),
    Color.fromRGBO(250, 216, 152, 1),
    Color.fromRGBO(223, 109, 46, 1),
  ];

  ///测试分页标题
  List<String> testTitles = [
    '一',
    '二二',
    '三三三',
    '四四四四',
    '五五五五五',
    '六',
    '七七',
    '八八八',
    '九九九九',
    '十十十十十',
  ];

  ///所有分页移动数据
  Map<String,Map<int,PageBean>> allPageViewBeans = {};

  ///所有分页标题位移数据
  Map<String,double> allListViewDistanceRolled = {};


  ///ListView位移计算
  ///
  /// [pageViewBean]：ListView中每个对应分页的标题元素，
  /// [scrollOffset]：已滚动距离
  /// [isToRight]：指示器是否是往右滑动，
  /// [willIndex]：下一个将要跨越的元素下标
  /// [total]：分页标题总数
  /// [listScrollController]：分页控制器
  void listViewDisplacement(Map<int,PageBean>? pageViewBean,double scrollOffset,bool isToRight,int willIndex,int total,ScrollController listScrollController){
    ///可视区域宽度
    double viewPortLength = pageViewBean?[0]?.viewportWidth??0.0;
    ///下一个item的下标，注意极值
    int nextItemIndex = (willIndex + 1) == total?willIndex:(willIndex + 1);
    ///下一个item距离起点的距离
    double nextItemToLeading = pageViewBean?[nextItemIndex]?.offsetRevealToLeading??0.0;
    ///下一个item宽度
    double nextItemWidth = pageViewBean?[nextItemIndex]?.pageWidth??0.0;
    ///上一个item的下标，注意极值
    int previousItemIndex = willIndex == 0?willIndex:(willIndex - 1);
    ///上一个item的距离起点的距离
    double previousItemToLeading = pageViewBean?[previousItemIndex]?.offsetRevealToLeading??0.0;
    ///下一个item宽度
    double previousItemWidth = pageViewBean?[previousItemIndex]?.pageWidth??0.0;
    ///移动距离
    double moveOffset = 0.0;
    ///动画耗时
    int milliseconds = 300;
    ///动画方式
    Curve listCurve = Curves.easeInOutQuint;

    ///指示器往右移动
    if(isToRight){

      if( nextItemToLeading >= (scrollOffset + viewPortLength)){///下一个item在右侧不可见区域
        ///计算需要滚动到的位置
        moveOffset = scrollOffset + nextItemToLeading + nextItemWidth - ( scrollOffset + viewPortLength );
        ///动画滚动
        listScrollController.animateTo(
            moveOffset,
            duration: Duration(milliseconds: milliseconds),
            curve: listCurve
        );
      }else if( nextItemToLeading < (scrollOffset + viewPortLength) && (nextItemToLeading + nextItemWidth) > (scrollOffset + viewPortLength)){///下一个item在右侧一部分可见
        ///计算需要滚动到的位置
        moveOffset = scrollOffset + nextItemWidth - ( scrollOffset + viewPortLength - nextItemToLeading);
        ///动画滚动
        listScrollController.animateTo(
            moveOffset,
            duration: Duration(milliseconds: milliseconds),
            curve: listCurve
        );
      }else if( (nextItemToLeading + nextItemWidth) <= scrollOffset){///下一个item在左侧不可见区域
        ///计算需要滚动到的位置
        moveOffset = nextItemToLeading - viewPortLength + nextItemWidth;
        ///动画滚动
        listScrollController.animateTo(
            moveOffset,
            duration: Duration(milliseconds: milliseconds),
            curve: listCurve
        );
      }
    }else{///指示器往左移动
      if( (previousItemToLeading + previousItemWidth) <= scrollOffset){///下一个item在左侧不可见区域
        ///动画滚动
        listScrollController.animateTo(
            previousItemToLeading,
            duration: Duration(milliseconds: milliseconds),
            curve: listCurve
        );
      }else if( previousItemToLeading < scrollOffset && (previousItemToLeading + previousItemWidth) > scrollOffset){///下一个item在左侧一部分可见
        ///动画滚动
        listScrollController.animateTo(
            previousItemToLeading,
            duration: Duration(milliseconds: milliseconds),
            curve: listCurve
        );
      }else if( previousItemToLeading >= (scrollOffset + viewPortLength)){///下一个item在右侧不可见区域
        ///动画滚动
        listScrollController.animateTo(
            previousItemToLeading,
            duration: Duration(milliseconds: milliseconds),
            curve: listCurve
        );
      }
    }
  }

  ///分页滑动=>计算指示器位移距离
  ///
  /// [pageViewBean]：ListView中每个对应分页的标题元素，
  /// [isToRight]：指示器是否是往右滑动，
  /// [spanIndex]：将要跨越的元素下标
  /// [total]：分页标题总数
  /// [nowListViewDistanceRolled]：当前ListView位移距离
  /// [pageController]：分页控制器
  /// [percent]：进度
  double indicatorDisplacement(Map<int,PageBean>? pageViewBean,bool isToRight,int spanIndex,int total,double nowListViewDistanceRolled,PageController pageController,double percent){
    double offSetX = 0.0;
    ///当前已经翻过的页数宽度
    double spanPageWidth = 1.0.sw*spanIndex;
    ///上一个item距离起点的距离
    double previousItemToLeading = pageViewBean?[spanIndex - 1]?.offsetRevealToLeading??0.0;
    ///当前item距离起点的距离
    double nowItemToLeading = pageViewBean?[spanIndex]?.offsetRevealToLeading??0.0;
    ///下一个item距离起点的距离
    double nextItemToLeading = pageViewBean?[spanIndex + 1]?.offsetRevealToLeading??0.0;
    ///要跨越的距离
    double gap = 0.0;

    if(isToRight){///右滑
      if(spanIndex == (total - 1)){
        ///如果指示器右滑到终点位置仍旧位移，那么通过滑动距离和阻尼系数(0.1)达到效果
        offSetX = nowItemToLeading + (pageController.position.pixels - spanPageWidth)*0.1 - nowListViewDistanceRolled;
      }else{
        ///计算两个item之间的差值
        gap = nextItemToLeading - nowItemToLeading;
        offSetX = nowItemToLeading + percent*gap - nowListViewDistanceRolled;
      }
    }else{///左滑
      ///处理临界滑动
      if(spanIndex == 0){
        ///如果指示器左滑到起始位置仍旧位移，那么通过滑动距离和阻尼系数(0.1)达到效果
        offSetX = nowItemToLeading + pageController.position.pixels*0.1 - nowListViewDistanceRolled;
      }else{
        ///计算两个item之间的差值
        gap = nowItemToLeading - previousItemToLeading;
        offSetX = nowItemToLeading - (percent == 1.0?0:percent)*gap - nowListViewDistanceRolled;
      }
    }
    return offSetX;
  }

  ///ListView滚动监听，用于标题滑动的时候，指示器能随着移动
  ///
  /// [percent]；进度
  /// [isToRight]；是否右移
  /// [spanIndex]；即将跨越的item
  /// [listMovePixels]；ListView移动的距离
  /// [pageTitle]；当前分页标题
  double listOffSetX(double percent,bool isToRight,int spanIndex,double listMovePixels,String pageTitle){
    double offSetX = 0.0;

    ///只有当进度在0.8~1.0之间时候，自动定位下一个item，主要因为percent在左移结束为1.0，右移结束为0.0
    if(percent > 0.8 && percent < 1.0){
      ///老样子判断左右位移
      int temporaryIndex = isToRight?spanIndex + 1:spanIndex - 1;
      if(temporaryIndex < spanIndex){
        debugPrint('percent$percent  isToRight$isToRight  temporaryIndex$temporaryIndex');
      }
      offSetX = allPageViewBeans[pageTitle]![temporaryIndex]!.offsetRevealToLeading - listMovePixels;
    }else{///当percent为1.0和0.0时候，基本上分页滑动接近结束才会滑动标题，其他情况手速没这么快，所以直接判断两种情况
      offSetX = allPageViewBeans[pageTitle]![spanIndex]!.offsetRevealToLeading - listMovePixels;
    }
    return offSetX;
  }


  ///单例基础设置
  CostPageViewSingleton._() {
    // initialization and stuff
  }

  CostPageViewSingleton._internal();

  static CostPageViewSingleton getInstance() {
    if (_instance == null) {
      _instance = CostPageViewSingleton._internal();
    }
    return _instance!;
  }

  ///UI全局单例
  factory CostPageViewSingleton() {
    if (_instance== null) {
      _instance = CostPageViewSingleton._();
    }
    // since you are sure you will return non-null value, add '!' operator
    return _instance!;
  }

  ///初始化
  static void reset() {
    _instance = null;
  }
}