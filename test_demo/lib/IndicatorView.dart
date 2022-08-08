import 'package:flutter/material.dart';

class Point {
  double x;
  double y;
  Point({required this.x,required this.y});
}

class IndicatorView extends CustomPainter{

  ///半径
  final double radius;
  final double M = 1.0;
  // final double M = 0.551915024494;
  final double percent;
  final bool isToRight;
  final Color color;
  late Paint curvePaint;
  late Path curvePath;

  IndicatorView({
    required this.radius,
    required this.percent,
    required this.isToRight,
    required this.color,
  }){
    curvePaint = Paint()
      ..style = PaintingStyle.fill;
    curvePath = Path();
  }

  @override
  void paint(Canvas canvas, Size size) {
    curvePath.reset();
    curvePaint.color = color;
    _canvasBesselPath(curvePath);
    canvas.drawPath(curvePath, curvePaint);
  }

  void _canvasBesselPath(Path path) {

    ///控制点的位置，半径的0.55倍左右，这时候是正圆，所以我们从0.55倍的比例开始
    double tangentLineLength = radius*M;

    ///挤压系数
    double extrusion = 0.4;

    ///拉伸系数
    double stretch = 0.5;

    ///回弹系数，回弹系数，乘以4是为了回弹效果明显一点，数字越大效果越明显）
    double rebound = 4;

    ///位移距离
    double displacementDistance = radius*stretch;

    ///回弹距离
    double reboundDistance = radius*2;

    ///回弹效果的左右压缩的距离,因为是从80%开始缩进递增，所以要percent - 0.8
    double leftAndRightIndentedDistance = reboundDistance*(percent - 0.9)*rebound;

    ///回弹效果的左右恢复的距离,因为是回弹需要递减，而percent是递增，所以要1 - percent
    double leftAndRightReboundDistance = reboundDistance*(1 - percent)*rebound;

    ///顶端
    Point p1 = Point(x: radius,y: 0);
    ///右边
    Point p2 = Point(x: radius*2,y: radius);
    ///底端
    Point p3 = Point(x: radius,y: radius*2);
    ///左边
    Point p4 = Point(x: 0,y: radius);

    ///顶端左右控制点
    Point p1L = Point(x: radius - tangentLineLength,y: p1.y);
    Point p1R = Point(x: radius + tangentLineLength,y: p1.y);

    ///右边左右控制点
    Point p2L = Point(x: p2.x,y: radius - tangentLineLength);
    Point p2R = Point(x: p2.x,y: radius + tangentLineLength);

    ///底端左右控制点
    Point p3L = Point(x: radius - tangentLineLength,y: p3.y);
    Point p3R = Point(x: radius + tangentLineLength,y: p3.y);

    ///左边左右控制点
    Point p4L = Point(x: p4.x,y: radius + tangentLineLength);
    Point p4R = Point(x: p4.x,y: radius - tangentLineLength);

    ///涨就是位移的距离长，缩就是位移的距离短，速率要一致（倍数）
    if (isToRight) {///判断左划右划

      ///先涨后缩
      if (percent > 0 && percent <= 0.5) {

        ///坐标右移，原本的位置 + 进度✖半径
        p2.x = p2.x + displacementDistance*percent;
        p2L.x = p2L.x + displacementDistance*percent;
        p2R.x = p2R.x + displacementDistance*percent;

        ///上下压缩的效果
        compressionAndRebound(p1L, p1, p1R, p3L, p3, p3R, percent, extrusion);

      }else if (percent > 0.5 && percent < 1.0) {

        ///在进度末尾的时候完成回弹效果，另一边的点，先缩后恢复
        if(percent >= 0.9 && percent < 0.95){

          ///第一步，缩，比例为：0 ~ 0.2
          ///因为是点P4，起始X坐标为0，所以X轴向右位移，加就等于缩
          p4.x = leftAndRightIndentedDistance;
          p4L.x = leftAndRightIndentedDistance;
          p4R.x = leftAndRightIndentedDistance;
          // debugPrint('缩进距离：$leftAndRightIndentedDistance\n');

        }else if( percent >= 0.95){

          ///第二步，恢复，比例为：0.2 ~ 0
          ///恢复其实就是向右位移的距离逐步减少
          ///比例为：0.2 ~ 0，这里的倍数要和之前缩的倍数一致
          p4.x = leftAndRightReboundDistance;
          p4L.x = leftAndRightReboundDistance;
          p4R.x = leftAndRightReboundDistance;
          // debugPrint('回弹距离：$leftAndRightReboundDistance\n-------------------');

        }

        ///坐标恢复，原本的位置 + 半径✖系数，系数为： 0.5 ~ 0
        p2.x = p2.x + displacementDistance*(1 - percent);
        p2L.x = p2L.x + displacementDistance*(1 - percent);
        p2R.x = p2R.x + displacementDistance*(1 - percent);

        ///上下回弹的效果
        compressionAndRebound(p1L, p1, p1R, p3L, p3, p3R, (1 - percent), extrusion);

      }
    } else {

      ///先涨后缩
      if (percent > 0 && percent <= 0.5) {

        ///坐标左移，原本的位置 + 进度✖半径
        p4.x = p4.x - displacementDistance*percent;
        p4L.x = p4L.x - displacementDistance*percent;
        p4R.x = p4R.x - displacementDistance*percent;

        ///不论左划右划，重复
        ///上下压缩的效果
        compressionAndRebound(p1L, p1, p1R, p3L, p3, p3R, percent, extrusion);

      }else if (percent > 0.5 && percent < 1.0) {

        ///在进度末尾的时候完成回弹效果，另一边的点，先缩后恢复
        if(percent >= 0.9 && percent < 0.95){

          ///因为是点P2，起始X坐标为radius*2，所以X轴向左位移，减就等于缩
          ///第一步，缩，比例为：0 ~ 0.2
          p2.x = p2.x - leftAndRightIndentedDistance;
          p2L.x = p2L.x - leftAndRightIndentedDistance;
          p2R.x = p2R.x - leftAndRightIndentedDistance;

        }else if( percent >= 0.95){

          ///第二步，恢复，比例为：0.2 ~ 0
          p2.x = p2.x - leftAndRightReboundDistance;
          p2L.x = p2L.x - leftAndRightReboundDistance;
          p2R.x = p2R.x - leftAndRightReboundDistance;

        }

        ///坐标恢复，原本的位置 + 半径✖系数，系数为： 0.5 ~ 0
        p4.x = p4.x - displacementDistance*(1 - percent);
        p4L.x = p4L.x - displacementDistance*(1 - percent);
        p4R.x = p4R.x - displacementDistance*(1 - percent);

        ///重复，和右滑一样
        compressionAndRebound(p1L, p1, p1R, p3L, p3, p3R,(1 - percent), extrusion);

      }
    }

    ///所有点都确定位置后，开始绘制连接
    ///先从原点移动到第一个点P1
    path.moveTo(p1.x, p1.y);

    ///顺时针一起连接点，p1-p1R-p2L-p2
    path.cubicTo(
        p1R.x, p1R.y,
        p2L.x, p2L.y,
        p2.x, p2.y
    );

    ///p2-p2R-p3R-p3
    path.cubicTo(
        p2R.x, p2R.y,
        p3R.x, p3R.y,
        p3.x, p3.y
    );

    ///p3-p3L-p4L-p4
    path.cubicTo(
        p3L.x, p3L.y,
        p4L.x, p4L.y,
        p4.x, p4.y
    );

    ///p4-p4R-p1L-p1
    path.cubicTo(
        p4R.x, p4R.y,
        p1L.x, p1L.y,
        p1.x, p1.y
    );

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  /// 上下压缩和回弹的效果
  /// p1L、p1、p1R、p3L、p3、p3R 上下6个坐标
  /// radius 要位移的距离(纵轴的缩放小，所以只选择一个半径的距离)
  /// percent 当前页面滑动的进度
  /// extrusion 效果放大的系数
  void compressionAndRebound(Point p1L,Point p1,Point p1R,Point p3L,Point p3,Point p3R,double percent,double extrusion){

    ///根据percent进度变化，压缩和回弹的区别：
    ///进度的大小：递增 = 压缩    递减 = 回弹

    ///顶部y轴变化
    ///所有坐标都是在原本的位置变化
    ///p1原y轴：0
    p1L.y = 2*radius*percent*extrusion;
    p1.y = 2*radius*percent*extrusion;
    p1R.y = 2*radius*percent*extrusion;

    ///底部y轴变化
    ///p3原y轴：radius*2
    p3L.y = radius*2 - 2*radius*percent*extrusion;
    p3.y = radius*2 - 2*radius*percent*extrusion;
    p3R.y = radius*2 - 2*radius*percent*extrusion;
  }

}