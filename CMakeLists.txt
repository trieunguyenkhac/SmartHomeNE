cmake_minimum_required(VERSION 3.16)

project(SmartEnergyHome VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml Charts)

qt_standard_project_setup()

# Application target
qt_add_executable(SmartEnergyHome
    main.cpp
    device.h device.cpp
    room.h room.cpp
    homemanager.h homemanager.cpp
    simulationengine.h simulationengine.cpp
)

# QML Resources and files
qt_add_qml_module(SmartEnergyHome
    URI SmartHome
    VERSION 1.0
    QML_FILES
        Main.qml
        DashboardView.qml
        DeviceControlView.qml
        StatisticsView.qml
)

target_link_libraries(SmartEnergyHome PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Qml
    Qt6::Charts
)

include(GNUInstallDirs)
install(TARGETS SmartEnergyHome
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)