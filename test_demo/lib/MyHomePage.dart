import 'IndicatorView.dart';
import 'CostPaginationIndicator.dart';
import 'CostPageViewSingleton.dart';
import 'PreventRepeatedEvent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vector_math/vector_math_64.dart' as v;

class MyHomePage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {

  ///标题
  String pageTitle = '分页测试';

  ///当前页码，小数代表进度
  double nowCurPosition = 0.0;

  ///上一次的page
  double oldCurPosition = 0.0;

  ///上一次的page下标，用于有动画的时候判断左移右移
  int oldIndex = 0;

  ///半径
  double radius = 24.w;

  ///页数去掉整数部分，一次翻页的进度,不论左滑还是右滑都得是同一个百分数。用于计算动画的进度
  double percent = 0.0;

  ///颜色进度
  double colorPercent = 0.0;

  ///颜色透明度
  double colorOpacity = 0.0;

  ///当前颜色
  Color nowColor = CostPageViewSingleton().myHomePageColors.first;

  ///是否是向右
  bool isToRight = true;

  ///将要跨越的分页下标
  int spanIndex = 0;

  ///标题listview是否开始滑动
  bool listScrollStart = false;
  ///分页是否开始滑动
  bool pageScrollStart = false;

  ///分页间距
  double pageTitlePadding = 40.w;

  ///分页指示器外边距
  double overallMargin = 64.w;

  ///指示器宽高
  double indicatorWidth = 48.w;

  ///标题列表高度
  double listViewHeight = 80.w;

  ///起始位置
  double offSetX = 0.0;

  ///分页控制器
  late PageController pageController;

  ///分页标题控制器
  ScrollController listScrollController = ScrollController();

  ///指示器变化矩阵
  Matrix4 transform = Matrix4.translationValues(0, 0, 0);///主体

  ///请求控制器
  PreventRepeatedEvent repeatedEvent = PreventRepeatedEvent();

  ///分页总数
  int pageTotal = 0;

  @override
  void initState() {
    super.initState();
    ///获取分页总数
    pageTotal = 10;
    ///设置系数比例为0.8
    pageController = PageController(viewportFraction: 1.0);
    ///分页监听
    pageController.addListener((){
      ///监听计算
      ///
      /// [nowCurPosition] 当前分页移动的距离
      /// [isToRight] 是否是向右位移
      /// [percent] 进度：右是 0 ~ 1.0 左：0 ~ 1.0
      /// [colorPercent] 颜色进度：和右滑进度一样 正向取值
      /// [spanIndex] 要跨越的元素下标 = 当前的下标
      /// [colorOpacity] 颜色透明度
      /// [nowColor] 当前颜色
      /// [offSetX] 需要位移的距离
      pageControllerListener();

    });
    ///注册请求控制回调
    repeatedEvent.addEventListener(_getDataCallBack);
  }

  @override
  Widget build(BuildContext context) {
    transform = Matrix4.compose(v.Vector3(offSetX, 0.0, 0.0), v.Quaternion.euler(0, 0, 0), v.Vector3(1.0, 1.0, 1.0));
    return Scaffold(
      body: Container(
        color: Color.fromRGBO(20, 26, 36, 1),///统一背景色
        padding: EdgeInsets.only(top: 112.w),
        child: Column(
          children: [
            ///分页指示器
            Stack(
              children: [
                ///分页标题和隐藏的指示器
                Container(
                  padding: EdgeInsets.only(left: overallMargin,right: overallMargin),
                  height: listViewHeight,
                  child: IntrinsicHeight(
                    child: NotificationListener<ScrollNotification>(
                      child: ListView.builder(///列表
                        itemCount: pageTotal,
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        controller: listScrollController,
                        itemBuilder: (BuildContext context, int index) {
                          ///item
                          return CostPaginationIndicator(
                            pageKey: pageTitle,
                            title: CostPageViewSingleton().testTitles[index],
                            pageTitlePadding: pageTitlePadding,
                            index: index,
                            isToRight: isToRight,
                            indicatorWidth: radius*2,
                            bodyWidget: Text(///自定义标题
                              CostPageViewSingleton().testTitles[index],
                              style: TextStyle(
                                  color: CostPageViewSingleton().baseColor3,
                                  fontSize: ScreenUtil().setSp(32),
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            onPressed: (value){
                              ///点击处理
                              pageController.animateToPage(value?.pageIndex??0, duration: Duration(milliseconds: 800), curve: Curves.easeInOutBack);
                            },
                          );
                        },
                      ),
                      onNotification: (ScrollNotification notification){
                        //开始滚动
                        if(notification is ScrollStartNotification){
                          // print("开始滚动");
                          // listScrollStart = true;
                        } else if (notification is ScrollUpdateNotification){
                          ///当前ListView位移距离
                          CostPageViewSingleton().allListViewDistanceRolled[pageTitle] = notification.metrics.pixels;

                          offSetX = CostPageViewSingleton().listOffSetX(percent, isToRight, spanIndex, notification.metrics.pixels, pageTitle);
                          /// 更新滚动
                          setState(() {});
                        } else if (notification is ScrollEndNotification){
                          // print("结束滚动");
                          // listScrollStart = false;
                        }
                        // 返回值是防止冒泡， false是可以冒泡
                        return true;
                      },
                    ),
                  ),
                ),
                ///指示器动画
                Positioned(
                  top: (listViewHeight - radius*2)/2,
                  left: overallMargin,
                  right: overallMargin,
                  bottom: (listViewHeight - radius*2)/2,
                  child: IgnorePointer(
                    child: ClipRect(
                      clipper: _MyClipper(),
                      child:AnimatedContainer(
                        duration: Duration(microseconds: 100),
                        transform: transform,
                        child: CustomPaint(
                          painter: IndicatorView(
                              radius: radius,
                              percent: percent,
                              isToRight: isToRight,
                              color: nowColor
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            ///分页主体
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: 32.w),
                child: PageView.builder(///分页
                  itemBuilder: (context,pageIndex){
                    return MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.builder(///列表
                          itemCount: pageTotal,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            ///item
                            return Container(
                              margin: EdgeInsets.all(32.w),
                              height: 220,
                              child: Card(
                                elevation: 10,
                                color: CostPageViewSingleton().myHomePageColors[pageIndex],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                        )
                    );
                  },
                  itemCount: pageTotal,
                  scrollDirection: Axis.horizontal,
                  reverse: false,
                  controller: pageController,
                  physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  ///翻页过程中，翻页动作完毕触发
  void _getDataCallBack(data) {
    if(nowCurPosition >= oldIndex){
      isToRight = true;
    }else{
      isToRight = false;
    }
    oldIndex = nowCurPosition.toInt();
    ///ListView位移计算
    CostPageViewSingleton().listViewDisplacement(
        CostPageViewSingleton().allPageViewBeans[pageTitle],
        CostPageViewSingleton().allListViewDistanceRolled[pageTitle]??0.0,
        isToRight,
        spanIndex,
        pageTotal,
        listScrollController
    );
  }

  ///ListView滑动监听处理
  void pageControllerListener(){

    ///当前page数据
    nowCurPosition = pageController.page!;
    ///比对上一次来判断左滑还是右滑
    if (nowCurPosition > oldCurPosition) {///新 > 旧 往右移动
      isToRight = true;
      // debugPrint('指示器往右滑');
    } else if (nowCurPosition < oldCurPosition) {///新 < 旧 往左移动
      isToRight = false;
      // debugPrint('指示器往左滑');
    }else{
      if(nowCurPosition == oldCurPosition && oldCurPosition == 0.0){ ///极值 处于起始位置，还不停往左移动
        isToRight = false;
        // debugPrint('指示器往左滑');
      }else{///极值 处于终点位置，还不停往右移动
        isToRight = true;
        // debugPrint('指示器往右滑');
      }
    }

    ///比对结束赋值
    oldCurPosition = nowCurPosition;

    if (isToRight) {
      /// 2.0354 - 2 正向运动 = 0.0354
      percent = nowCurPosition - nowCurPosition.toInt();
      ///往右，即将跨越的 = 当前的，舍弃小数位
      spanIndex = nowCurPosition.toInt();
    } else {
      ///反向运动，进度由大变小 0.9 -> 0.1 所以 2.9 - 2 = 0.9 ，但实际是 1 - 0.9 = 0.1
      percent =  1 - (nowCurPosition - nowCurPosition.toInt());
      ///往右，即将跨越的 = 当前的，小数位进位
      spanIndex = nowCurPosition.ceil();
    }

    ///颜色进度不需要反向计算
    colorPercent = nowCurPosition - nowCurPosition.toInt();

    // debugPrint('进度$percent');
    ///每次每页翻到后，触发(percent代表一次翻页结束)
    if(percent == 0 || percent == 1){
      ///翻页进度监听，会多次触发，但只需要最后一次有效触发
      if(!listScrollStart) repeatedEvent.sendEvent(nowCurPosition);
    }

    ///颜色变化在进度70%左右开始
    if (colorPercent >= 0 && colorPercent <= 0.7) {
      colorOpacity = ( 1.0 - colorPercent );
      ///不到70%就是之前的分页颜色
      nowColor = CostPageViewSingleton().myHomePageColors[nowCurPosition.toInt()].withOpacity(colorOpacity <= 0.3 ?0.5:colorOpacity);
    }else if (colorPercent > 0.7 && colorPercent <= 1.0) {
      ///过了70%就是后面的分页的颜色
      nowColor = CostPageViewSingleton().myHomePageColors[nowCurPosition.ceil()].withOpacity(colorPercent);
    }

    if(!listScrollStart){
      ///分页滑动=>计算指示器位移距离
      offSetX = CostPageViewSingleton().indicatorDisplacement(
        CostPageViewSingleton().allPageViewBeans[pageTitle],
        isToRight,
        spanIndex,
        pageTotal,
        (CostPageViewSingleton().allListViewDistanceRolled[pageTitle]??0.0),
        pageController,
        percent,
      );
    }

    setState(() {});
  }

}

class _MyClipper extends CustomClipper<Rect>{
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(-48.w, 0, size.width + 48.w,  size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
