file(GLOB_RECURSE srcs CONFIGURE_DEPENDS src/*.cc include/*.hpp)
add_library(project2 STATIC ${srcs})
target_include_directories(project2 PUBLIC include)