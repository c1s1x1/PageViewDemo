import 'package:flutter_screenutil/src/size_extension.dart';

import 'CostPageViewBean.dart';
import 'CostPageViewSingleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CostPaginationIndicator extends StatefulWidget{

  final String pageKey;///当前是哪个分页
  final String title;///标题
  final double pageTitlePadding;///分页标题间距
  final double indicatorWidth;///分页标题间距
  final Widget? bodyWidget;
  final int index;///下标
  final bool isToRight;///往左 or 往右
  final void Function(PageBean?) onPressed;///点击事件

  CostPaginationIndicator(
      {
        Key? key,
        required this.pageKey,
        required this.title,
        required this.pageTitlePadding,
        required this.indicatorWidth,
        required this.index,
        required this.isToRight,
        required this.onPressed,
        this.bodyWidget,
      }
      ) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CostPaginationIndicator();
  }

}

class _CostPaginationIndicator extends State<CostPaginationIndicator>{

  @override
  void initState() {

    ///当前Frame最后一帧绘制完毕
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      ///记录数据
      getViewPortSize(context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        widget.onPressed(CostPageViewSingleton().allPageViewBeans[widget.pageKey]![widget.index]);
      },
      child: Container(
        // color: Colors.deepOrange,
        margin: EdgeInsets.only(right: widget.pageTitlePadding),
        child: Row(
          children: [
            ///指示器占位组件
            Container(
              key: Key('${widget.index}-RoundedRectangle'),
              width: widget.indicatorWidth,
              height: widget.indicatorWidth,
              margin: EdgeInsets.only(right: widget.bodyWidget == null ?0:16.w),///如果没有主体，就不需要间距
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),///这里设置圆角
                  border: Border.all(color: CostPageViewSingleton().myHomePageColors[widget.index],width: 1)
              ),
            ),
            ///自定义标题
            widget.bodyWidget??Container()
          ],
        ),
      ),
    );
  }


  Size? getViewPortSize(BuildContext context) {
    ///获取当前组件
    final RenderObject? box = context.findRenderObject();
    ///获取可视区域
    final RenderAbstractViewport? viewport = RenderAbstractViewport.of(box);
    ///判空处理
    if (viewport == null || box == null || !box.attached) {
      debugPrint('是否父组件是ScrollView');
      return Size(0, 0);
    }
    /// box 为当前 Item 的 RenderObject
    /// alignment 为 0 的时候获得距离起点的相对偏移量,为 1 的时候获得距离可视区域终点的相对偏移量。
    final RevealedOffset offsetRevealToLeading = viewport.getOffsetToReveal(box, 0.0, rect: Rect.zero);
    ///可视区域大小
    final Size? size = viewport.paintBounds.size;
    ///当前组件大小
    final Size? sizeItem = box.paintBounds.size;
    ///放到分页数据model里
    if(CostPageViewSingleton().allPageViewBeans[widget.pageKey] != null){
      ///每个元素下标对应的数据
      CostPageViewSingleton().allPageViewBeans[widget.pageKey]![widget.index] = PageBean(
          widget.index,///下标
          widget.title, ///标题
          sizeItem?.width??0, ///宽度
          sizeItem?.height??0,///高度
          offsetRevealToLeading.offset,///距离起点的长度
          size?.width??0.0///可视区域的宽度
      );
    }else{
      ///首次添加数据
      CostPageViewSingleton().allPageViewBeans[widget.pageKey] = {
        widget.index:PageBean(
            widget.index,///下标
            widget.title, ///标题
            sizeItem?.width??0, ///宽度
            sizeItem?.height??0,///高度
            offsetRevealToLeading.offset,///距离起点的长度
            size?.width??0.0///可视区域的宽度
        )
      };
    }
    return size;
  }

}