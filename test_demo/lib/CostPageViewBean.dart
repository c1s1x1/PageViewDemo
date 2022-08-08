class PageBean extends Object {

  ///下标
  int pageIndex;

  ///标题
  String pageTitle;

  ///宽度
  double pageWidth;

  ///高度
  double pageHeight;

  ///距离起点的长度
  double offsetRevealToLeading;

  ///可视区域的宽度
  double viewportWidth;

  PageBean(this.pageIndex,this.pageTitle,this.pageWidth,this.pageHeight,this.offsetRevealToLeading,this.viewportWidth);

}