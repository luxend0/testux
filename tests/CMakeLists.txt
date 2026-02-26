find_package(Qt6 REQUIRED COMPONENTS Qml Test)

set(src ${PROJECT_SOURCE_DIR}/src)
testux_test(tst_qemuargs ${src}/vm/qemuargs.cpp)