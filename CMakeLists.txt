cmake_minimum_required(VERSION 3.21)

project(Testux VERSION 0.0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Concurrent Network Quick QuickControls2 LinguistTools)
qt_standard_project_setup(REQUIRES 6.8 I18N_SOURCE_LANGUAGE en I18N_TRANSLATED_LANGUAGES de)
qt_policy(SET QTP0004 NEW)

qt_add_executable(testux WIN32 src/main.cpp)


set_source_files_properties(qml/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(testux
    URI Testux
    VERSION 1.0
    SOURCES
        src/catalog/catalogparser.h src/catalog/catalogparser.cpp
        src/vm/qemuargs.h src/vm/qemuargs.cpp
    QML_FILES
        qml/Main.qml
    RESOURCES
        catalog/catalog.json
)

if(WIN32)
    target_sources(testux PRIVATE)
    target_link_libraries(testux PRIVATE setupapi ole32 shell32 propsys)
else()
    target_sources(testux PRIVATE)
endif()