file(GLOB_RECURSE srcs CONFIGURE_DEPENDS src/*.cc include/*.hpp)
add_library(project1 STATIC ${srcs})
target_include_directories(project1 PUBLIC include)