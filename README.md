# CMake
  使用CMake模块化管理指南(C/C++)

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
  cmake_minimum_required(VERSION 3.18)

  if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
  endif()

  set(CMAKE_CXX_STANDARD 23)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  set(CMAKE_CXX_EXTENSIONS OFF)
  set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake;${CMAKE_MODULE_PATH}")
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/bin)   # exe
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/lib)   # a
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/lib)   # so

  project(CppCMakeDemo LANGUAGES C CXX)

  add_subdirectory(子项目名称1)
  add_subdirectory(子项目名称2)

  add_executable(yourapp yourmain.cc)
  #find_package(TBB CONFIG REQUIRED COMPONENTS tbb)
  #target_link_libraries(yourapp PUBLIC TBB::tbb)


  include(MyUsefulFuncs)    # from CMAKE_MODULE_PATH
  find_package(OpenCV)      # from CMAKE_MODULE_PATH
  target_link_libraries(yourapp OpenCV::xxx)

  子项目的CMakeLists.txt配置如下:
  file(GLOB_RECURSE srcs CONFIGURE_DEPENDS src/.cc include/.hpp)
  add_library(子项目名称 STATIC ${srcs})
  target_include_directories(子项目名称 PUBLIC include)

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

# -------------- include和add_subdirectory --------------
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
  find_package(XXX)
  if (NOT XXX_FOUND)
    message(FATAL_ERROR "XXX not found")
  endif()
  target_include_directories(yourapp ${XXX_INCLUDE_DIRS})
  target_link_libraries(yourapp ${XXX_LIBRARIES})

  find_package 还可以指定模式
  find_package(TBB MODULE REQUIRED)
    只会寻找FindTBB.cmake,搜索路径为${CMAKE_MODULE_PATH} (默认为/usr/share/cmake/Modules)
  
  find_package(TBB CONFIG REQUIRED)
    只会寻找TBBConfig.cmake,搜索路径为${CMAKE_PREFIX_PATH}/lib/cmake/TBB(默认为/usr/lib/cmake/TBB)
    或者 ${TBB_DIR} / $ENV{TBB_DIR}
  
  find_package(TBB REQUIRED)
    不指定两者都会尝试,先FindTBB.cmake,再TBBConfig.cmake

# -------------- 亲Unix软件从源码安装的通用套路 --------------
  Makefile 构建系统:
  ./configure --prefix=/usr --with-some-options   # 生成 Makefile
  make -j 8                                       # 8核心编译,生成.so
  sudo make install                               # 安装,拷贝到/usr/lib/.so

  CMake 构建系统:
  cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DWITH_SOME_OPTION=ON    # 生成 Makefile
  cmake --build build --parallel 8                                    # 8核心编译,生成.so
  sudo cmake --build --target install                                 # 安装,拷贝到/usr/lib/.so

  注意:如果 -DCMAKE_INSTALL_PREFIX=/usr/local 则会拷贝到/usr/local/lib/.so

  在自己的项目中使用安装的动态库:
  cd yourapp
  cmake -B build -DTBB_DIR=/usr/lib/cmake/TBB
  cmake --build build --parallel 8

# -------------- 不提供Config文件的第三方库怎么伺候 --------------
  自己写一个Find文件(FindXXX.cmake,)
  Find文件会在CMake安装时负责安装到/usr/share/cmake/Modules