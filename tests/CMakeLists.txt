find_package(Qt6 REQUIRED COMPONENTS Qml Test)

# Tests compile only the pure logic sources they cover, no QML engine involved.
function(testux_test name)
    qt_add_executable(${name} ${name}.cpp ${ARGN})
    target_include_directories(${name} PRIVATE ${PROJECT_SOURCE_DIR}/src)
    target_link_libraries(${name} PRIVATE Qt6::Qml Qt6::Test)
    add_test(NAME ${name} COMMAND ${name})
endfunction()

set(src ${PROJECT_SOURCE_DIR}/src)
testux_test(tst_qemuargs ${src}/vm/qemuargs.cpp)