# TZImagePickerHelper
一个对TZImagePickerController进行封装的工具TZImagePickerHelper。非常方便调用手机图片库和回调所选图片路径。
三步集成
 1. 控制器中初始化一个helper ;
 2. 调用[self.helper showImagePickerControllerWithMaxCount:(NSInteger )maxCount WithViewController: (UIViewController *)superController]
 3. 调用结束后，刷新界面;
