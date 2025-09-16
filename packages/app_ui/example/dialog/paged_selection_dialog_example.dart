import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// 礼物弹窗示例
class PagedSelectionDialogExample extends StatelessWidget {
  final List<String> gifts;
  final ValueChanged<String> callback;

  const PagedSelectionDialogExample({
    super.key,
    required this.gifts,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return PagedSelectionDialog(
      dataList: gifts,
      dialogConfig: DialogConfig(
        backgroundColor: Colors.white,
        indicatorColor: Colors.blue,
        pageMarginHorizontal: 10,
      ),
      pageConfig: PageConfig(
        childAspectRatio: 0.8,
        test: false,
      ),
      itemBuilder: (data, index, pageIndex) {
        String gift = data as String;
        return AppGestureDetector(
          onTap: () {
            callback.call(gift);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(
                "https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcTybPXygepLFR45ivXgj-AHCoYk4sAG22jPX_cl1ZwFY0CDYngBoZ93UFmYeYUh3OrrIT3WG01mSW79CwekGUug7-VLEsHxZ-pefJcSyL8DuA",
                width: 50,
                height: 50,
              ),
              sizedBoxHeight(5),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.g_translate,
                    size: 20,
                  ),
                  sizedBoxWidth(3),
                  AppText(
                    "文本内容",
                  ),
                ],
              ),
            ],
          ),
        );
      },
      bottomBuilder: (context) {
        return Row(
          children: [
            sizedBoxWidth(20),
            Icon(
              Icons.deblur,
              size: 20,
            ),
            sizedBoxWidth(10),
            AppText(
              "文本内容",
            ),
            Spacer(),
            AppContainer(
              height: 25,
              gradient: LinearGradient(
                colors: [Colors.green, Colors.blue],
              ),
              radius: 15,
              paddingHorizontal: 5,
              child: AppText(
                "Submit",
                autoSize: false,
              ),
              onTap: () {
                print("提交");
              },
            ),
            sizedBoxWidth(20),
          ],
        );
      },
    );
  }
}
