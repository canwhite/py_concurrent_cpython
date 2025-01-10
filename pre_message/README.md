## 如何直接运行.c文件

在Linux/Unix系统中，可以通过以下步骤直接运行C语言文件：

1. 打开终端
2. 使用gcc编译器编译C文件：
   ```bash
   gcc -o output_name your_file.c
   ```
   例如：
   ```bash
   gcc -o start start.c
   ```
   
3. 运行编译后的可执行文件：
   ```bash
   ./output_name
   ```
   例如：
   ```bash
   ./start
   ```

在Windows系统中：

1. 安装MinGW或Cygwin等C编译器
2. 打开命令提示符
3. 使用gcc编译：
   ```bash
   gcc -o output_name.exe your_file.c
   ```
4. 运行可执行文件：
   ```bash
   output_name.exe
   ```

注意事项：
- 确保系统已安装gcc编译器
- 如果程序需要输入参数，可以在运行时添加
- 可以使用`-Wall`选项开启所有警告信息
- 可以使用`-g`选项生成调试信息
