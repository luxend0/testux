cmake_minimum_required(VERSION 3.21)

project(Testux VERSION 0.0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
qt_standard_project_setup()

qt_add_executable(testux src/main.cpp)

qt_add_qml_module(testux
    URI Testux
    VERSION 1.0
    SOURCES
        src/launcher.h src/launcher.cpp
        src/vm/qemuargs.h src/vm/qemuargs.cpp
    QML_FILES qml/Main.qml
)

target_include_directories(testux PRIVATE src)
target_link_libraries(testux PRIVATE Qt6::Quick)
