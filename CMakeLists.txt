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
        src/catalog/catalog.h src/catalog/catalog.cpp
        src/download/checksum.h src/download/checksum.cpp
        src/download/isolibrary.h src/download/isolibrary.cpp
        src/vm/qemuargs.h src/vm/qemuargs.cpp
    QML_FILES
        qml/DistroPage.qml
        qml/DistroTile.qml
        qml/Heading.qml
        qml/Main.qml
        qml/NavItem.qml
        qml/Theme.qml
    RESOURCES
        catalog/catalog.json
        assets/testux.svg
)

if(WIN32)
    target_sources(testux PRIVATE)
    target_link_libraries(testux PRIVATE setupapi ole32 shell32 propsys)
else()
    target_sources(testux PRIVATE)
endif()

# qmltyperegistrar includes the QML_ELEMENT headers by bare file name.
target_include_directories(testux PRIVATE src
    src/catalog src/download src/vm src/hw src/baremetal)
target_compile_definitions(testux PRIVATE
    TESTUX_VERSION="${PROJECT_VERSION}"
    TESTUX_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}
    TESTUX_VERSION_MINOR=${PROJECT_VERSION_MINOR}
    TESTUX_VERSION_PATCH=${PROJECT_VERSION_PATCH})
target_link_libraries(testux PRIVATE Qt6::Concurrent Qt6::Network Qt6::Quick Qt6::QuickControls2)

# main.cpp loads ":/i18n/testux_<lang>.qm"; English is the source, no plurals file needed.
qt_add_translations(testux
    TS_FILE_BASE testux
    TS_FILE_DIR i18n
    RESOURCE_PREFIX /i18n
    NO_GENERATE_PLURALS_TS_FILE)