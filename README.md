# 使用CMake模块化管理指南(C/C++)

# 第一部分

# -------------- 目录组织方式 --------------
  目录组织方式:
  项目名/include/项目名/模块名.hppC
  项目名/src/模块名.cc

  CMakeLists.txt中写:
  target_include_directories(项目名 PUBLIC include)

  源码文件中写:
  #include<项目名/模块名.hpp>
  项目名::函数名();

  头文件(项目名/include/项目名/模块名.hpp)中写:
  #pragma once
  namespace 项目名 {
    void 函数名();
  }

  实现文件中(项目名/src/模块名.cc)中写:
  #include<项目名/模块名.hpp>
  namespace 项目名 {
    void 函数名() {}
  }
# -------------- CMakeLists.txt --------------
  项目分为根项目和多个子项目,每个项目里面都有自己的CMakeLists.txt
  根项目的CMakeLists.txt配置如下:
  `cmake_minimum_required(VERSION 3.18)`

  `if (NOT CMAKE_BUILD_TYPE)`
    `set(CMAKE_BUILD_TYPE Release)`
  `endif()`

  `set(CMAKE_CXX_STANDARD 23)`
  `set(CMAKE_CXX_STANDARD_REQUIRED ON)`
  `set(CMAKE_CXX_EXTENSIONS OFF)`
  `set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake;${CMAKE_MODULE_PATH}")`
  `set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/bin)   # exe`
  `set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/lib)   # a`
  `set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/lib)   # so`

  `project(CppCMakeDemo LANGUAGES C CXX)`

  `add_subdirectory(子项目名称1)`
  `add_subdirectory(子项目名称2)`

  `add_executable(yourapp yourmain.cc)`
  `#find_package(TBB CONFIG REQUIRED COMPONENTS tbb)`
  `#target_link_libraries(yourapp PUBLIC TBB::tbb)`


  `include(MyUsefulFuncs)    # from CMAKE_MODULE_PATH`
  `find_package(OpenCV)      # from CMAKE_MODULE_PATH`
  `target_link_libraries(yourapp OpenCV::xxx)`

  子项目的CMakeLists.txt配置如下:
  `file(GLOB_RECURSE srcs CONFIGURE_DEPENDS src/.cc include/.hpp)`
  `add_library(子项目名称 STATIC ${srcs})`
  `target_include_directories(子项目名称 PUBLIC include)`

# -------------- EXPLAIN --------------
  下面是解释:
  PUBLIC include是为了让其他子项目也能共享这个子项目下的include
  这里我们给srcs批量添加了src/.cc,那为什么还要添加include/.hpp? 为了头文件也能被纳入VS的项目资源管理器,方便浏览
  还有就是有的函数非常小直接会实现在头文件中,这个时候这个函数需要使用static或者inline声明一下(ODR)
  static各自有一个,inline所有共享同一个.

  file(GLOB project CONFIGURE_DEPENDS src/*.cc)
  file(GLOB_RECURSE project CONFIGURE_DEPENDS src/*.cc)
  下面是区别:
    GLOB:   src/main.cc(ok)   src/test/main.cc(no)
    GLOB:   src/main.cc(ok)   src/test/main.cc(ok)
    CONFIGURE_DEPENDS的作用:每次cmake --build的时候会自动检测目录是否更新,如果目录有新文件了,CMake会自动重新运行cmake -B build更新project变量.

# -------------- 模块之间的依赖 --------------
  如果新模块中用到了其他模块的类或者函数,就需要在新模块的头文件和源文件中都导入其他模块的头文件.
  注意不论是项目自己的头文件还是外部的系统的头文件,全部统一采用#include <项目名/模块名.hpp>,避免模块名和系统已有头文件名冲突.

# -------------- CMake中的include功能 --------------
  CMake中也有一个include命令.
  在CMakeLists.txt中写include(XXX),其会在CMAKE_MODULE_PATH这个列表中的所有路径下查找XXX.cmake文件
  所以可以在XXX.cmake里编写一些常用的函数,宏,变量等.其本质是一个小脚本.
  前提:在根CMakeLists.txt中需要编写:
  set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake;${CMAKE_MODULE_PATH}")

# -------------- macro和function --------------
  macro相当于直接把代码粘贴过去,直接访问调用者的作用域.
  function会创建一个闭包,优先访问定义者的作用域

# -------------- include和function --------------
  include相当于直接把代码粘贴过去,直接访问调用者的作用域,这里创建的变量和外面共享
  function中则是基于定义者所在路径,优先访问定义者的作用域,需要set(key val PARENT_SCOPE)才能修改到外面的变量.

# 第二部分(最重要的部分)

# -------------- 第三方库/依赖项配置(find_package) --------------
  find_package(OpenCV)
    查找名为OpenCV的包,找不到不报错,事后可以通过${OpenCV_FOUND}查询是否找到.
  find_package(OpenCV QUIET)
    找不到不报错,也不打印任何信息,事后可以通过${OpenCV_FOUND}查询是否找到.
  find_package(OpenCV REQUIRED) # 最常见的用法
    找不到就报错并终止cmake进程,不再继续往下执行
  find_package(OpenCV REQUIRED COMPONENTS core videoio)
    找不到就报错,且必须有OpenCV::core和OpenCV::videoio这两个组件,如果没有也会报错.
  find_package(OpenCV REQUIRED OPTIONAL_COMPONENTS core videoio)
    找不到就报错,没有core videoio也不会报错,通过${OpenCV_core_FOUND}查询是否找到core组件.

  find_package(OpenCV)本质上是在找一个名为OpenCVConfig.cmake(OpenCV-config.cmake)的文件.
  形如 包名 + Config.cmake 的文件,称之为 包配置文件.

  包配置文件中包含了包的具体信息,包括动态库文件的位置,头文件的目录,链接时需要开启的编译选项等等.
  包配置文件由第三方库的作者提供,在这个库安装时会自动放到/usr/lib/cmake/XXX/XXXConfig.cmake
  /usr/lib/cmake这个位置是CMake和第三方库作者约定俗成的.如果第三方库没有提供CMake支持,那么就得
  使用FindXXX.cmake

  如果是特别古代的库
  `find_package(XXX)
  if (NOT XXX_FOUND)
    message(FATAL_ERROR "XXX not found")
  endif()
  target_include_directories(yourapp ${XXX_INCLUDE_DIRS})
  target_link_libraries(yourapp ${XXX_LIBRARIES})`

  find_package 还可以指定模式
  `find_package(TBB MODULE REQUIRED)`
    只会寻找FindTBB.cmake,搜索路径为${CMAKE_MODULE_PATH} (默认为/usr/share/cmake/Modules)
  
  `find_package(TBB CONFIG REQUIRED)`
    只会寻找TBBConfig.cmake,搜索路径为${CMAKE_PREFIX_PATH}/lib/cmake/TBB(默认为/usr/lib/cmake/TBB)
    或者 ${TBB_DIR} / $ENV{TBB_DIR}
  
  `find_package(TBB REQUIRED)`
    不指定两者都会尝试,先FindTBB.cmake,再TBBConfig.cmake

# -------------- 亲Unix软件从源码安装的通用套路 --------------
  Makefile 构建系统:
  `./configure --prefix=/usr --with-some-options`   # 生成 Makefile
  `make -j 8`                                       # 8核心编译,生成.so
  `sudo make install`                               # 安装,拷贝到/usr/lib/.so

  CMake 构建系统:
  `cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DWITH_SOME_OPTION=ON`    # 生成 Makefile
  `cmake --build build --parallel 8`                                    # 8核心编译,生成.so
  `sudo cmake --build --target install`                                 # 安装,拷贝到/usr/lib/.so

  注意:如果 -DCMAKE_INSTALL_PREFIX=/usr/local 则会拷贝到/usr/local/lib/.so

  在自己的项目中使用安装的动态库:
  `cd yourapp`
  `cmake -B build -DTBB_DIR=/usr/lib/cmake/TBB`
  `cmake --build build --parallel 8`

# -------------- 不提供Config文件的第三方库怎么伺候 --------------
  自己写一个Find文件(FindXXX.cmake,)
  Find文件会在CMake安装时负责安装到/usr/share/cmake/Modules

# -------------- 一些常见的问题 --------------
  1.find_package(Qt5 REQUIRED) 出错
   errno: The Qt5 package requires at least one component
   解决方案: find_package(Qt5 COMPONENTS Widgets Gui REQUIRED)
   target_link_libraries(main PUBLIC Qt5::Widgets Qt5::Gui)
  
  2.Lars中CMakeLists.txt中的配置
    如果是自己写的lib,在CMakeLists中要 添加头文件搜索路径include_directories(...) 添加自己的静态库的路径link_directories(..)
    如果是第三方库 先得在前面加上 add_complie_options(-fPIC) (动态库), 再使用find_package(...) 找库(系统默认安装的位置,如果你指定了库的安装位置那就需要重新设置 
      eg: cmake -B build -DCMAKE_PREFIX=/usr/local/protobuf) 接着就是将当前目录下的所有*.cc 和 *.hpp都加入到srcs变量中,创建可执行文件.下面就是链接
      target_link_libraries(name PUBLIC lib)
    如果要将当前项目中的头文件共享给其他项目: target_include_directories(name PUBLIC include) -> 将include下的文件放到环境变量中.

  3.安装了相应的包但是无法找到
    第一种方法:设置CMAKE_MODULE_PATH变量,添加一下包含XXXConfig.cmake这个文件的目录路径,eg : set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} /usr/local/XXX/lib/cmake)

    第二种方法:设置XXX_DIR变量,这样只有XXX这个包会去目录里搜索XXXConfig.cmake,更有针对性,eg : set(XXX_DIR /usr/local/XXX/lib/cmake)

    第三种方法(推荐):直接再命令行通过-DXXX_DIR="..."指定

    第四种方法:通过设置环境变量 export 

  4.关于find_package(TBB) 和 find_package(TBB REQUIRED)
    前者找不到不会报错,后者找不到直接拿头来见
    前者的实现eg:
      `find_package(TBB)
      if (TBB_FOUND)
        message(STATUS "TBB found at: ${TBB_DIR})
        target_link_libraries(main PUBLIC TBB::tbb)
        # 找到了,定义WITH_TBB宏,这样在其他文件中可以通过宏定义来是否使用包中的函数
        target_compile_definitions(main PUBLIC WITH_TBB)
      else()
        message(WARNING "TBB not found! using serial for")
      endif()`
    也可以 :
      `find_package(TBB)
      # TARGET 伪对象
      if (TARGET TBB_FOUND)
        message(STATUS "TBB found at: ${TBB_DIR})
        target_link_libraries(main PUBLIC TBB::tbb)
        # 找到了,定义WITH_TBB宏,这样在其他文件中可以通过宏定义来是否使用包中的函数
        # 相当于在main文件中 #define WITH_TBB
        target_compile_definitions(main PUBLIC WITH_TBB)
      else()
        message(WARNING "TBB not found! using serial for")
      endif()`

    `message(...) 直接输出... 调试信息
    message(STATUS ...) 在前面会带上--符号 状态信息
    message(WARNING ...) 会以黄色的形式打印出来
    message(AUTHOR_WARNING ...) 只对项目作者可见, 可以通过cmake -B build -Wno-dev关掉
    message(FATAL_ERROR ...) 直接出错,以红色形式打印出来,接下来的程序都不会执行.
    message 中可以直接打印变量 ${var}`
    不确定的情况下都加上""(CMake中一切皆字符串)

# -------------- 变量与缓存 --------------
  重复执行cmake -B build 会有什么区别?
    第二次执行的输出很少,CMake第一遍需要检测编译器和C++特性等比较耗时,检测完会把结果存储到缓存中,后面再cmake -B build 的时候就会直接用缓存中的值.
  如果出现诡异的错误,直接删除build文件重新-B build就行(删build大法)
  find_package也会使用缓存.

  自己设置缓存变量
  set(变量名 "变量值" CACHE 变量类型 "注释")
  eg: set(myvar "hello" CACHE string "this is a string")
  后面如果这个变量改了不推荐删build大法而是 cmake -B build -Dmyvar=world
  使用ccmake -B build 可视化配置
  还可以set(变量名 "变量值" CACHE 变量类型 "注释" FORCE) 强制更新缓存变量.

  缓存变量的类型
    STRING FILEPATH PATH BOOL
    注意: TRUE ON 等价 FALESE OFF 等价 YES NO 等价 NO OFF 等价
  
  CMake对BOOL类型缓存的set指令提供了简写:option
  option(变量名 "描述" 变量值)
  等价于
  set(变量名 CACHE BOOL 变量值 "描述")
  CMake区分大小写(只是指令不分)

  变量传播规则:
    父会传给子,子不传父.要子传父就得 set(MYVAR ON PARENT_SCOPE)就可以往上传递一层.