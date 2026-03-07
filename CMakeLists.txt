cmake_minimum_required(VERSION 3.21)

project(Testux VERSION 0.0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Concurrent Network Quick QuickControls2 LinguistTools)
qt_standard_project_setup(REQUIRES 6.8 I18N_SOURCE_LANGUAGE en I18N_TRANSLATED_LANGUAGES de)
qt_policy(SET QTP0004 NEW)

qt_add_executable(testux WIN32 src/main.cpp)


set_source_files_properties(qml/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)