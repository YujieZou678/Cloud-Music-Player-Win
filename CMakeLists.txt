cmake_minimum_required(VERSION 3.24)

project(Cloud_Music_Player VERSION 0.1 LANGUAGES CXX)

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick Network)

qt_standard_project_setup()

qt_add_executable(appCloud_Music_Player  main.cpp)

qt_add_qml_module(appCloud_Music_Player
    URI Cloud_Music_Player
    VERSION 1.0
    QML_FILES 
        Main.qml
    SOURCES
    RESOURCES resources.qrc
    SOURCES logo.rc
    QML_FILES LayoutTopView.qml
    QML_FILES LayoutBottomView.qml
    QML_FILES PageHomeView.qml
    QML_FILES MusicIconButton.qml
    QML_FILES MusicToolButton.qml
    QML_FILES MusicRoundImage.qml
    QML_FILES DetailRecommendPageView.qml
    QML_FILES DetailSearchPageView.qml
    QML_FILES DetailLocalPageView.qml
    QML_FILES DetailFavoritePageView.qml
    QML_FILES DetailHistoryPageView.qml
    SOURCES httprequest.h httprequest.cpp
    QML_FILES MusicBannerView.qml
    QML_FILES MusicGridHotView.qml
    QML_FILES MusicGridLatestView.qml
    QML_FILES MusicListView.qml
    QML_FILES DetailPlayListPageView.qml
    QML_FILES requestNetwork.js
    QML_FILES MusicBorderImage.qml
    QML_FILES PageDetailView.qml
    QML_FILES MusicLyricView.qml
    QML_FILES MusicTextButton.qml
    SOURCES mysubthread.h mysubthread.cpp
    QML_FILES Background.qml
    QML_FILES MainSystemTrayIcon.qml
    QML_FILES MusicToolTip.qml
)

target_compile_features(appCloud_Music_Player PRIVATE cxx_std_20)

set_target_properties(appCloud_Music_Player PROPERTIES
    AUTORCC TRUE
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appCloud_Music_Player
    PRIVATE 
        Qt6::Quick
        Qt6::Network
)

include(GNUInstallDirs)
install(TARGETS appCloud_Music_Player
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)























































#qt_add_executable(Cloud_Music_Player)  //Creates and finalizes an application target of a platform-specific type.
#This command performs the following tasks:
#    1. Create a CMake target of the appropriate type for the target platform.
#    2. Link the target to the Qt::Core library.
#    3. Handle finalization of the CMake target.



# qt_standard_project_setup()     #set(CMAKE_AUTOUIC ON)  set(CMAKE_AUTOMOC ON)

# @if %{HasTranslation}
# find_package(Qt6 REQUIRED COMPONENTS Core Quick LinguistTools)
# @else
# find_package(Qt6 REQUIRED COMPONENTS Core Quick)
# @endif

# target_sources(appCloud_Music_Player
#     PRIVATE
#         main.cpp
#         qml.qrc
#     @if %{HasTranslation}
#         %{TsFileName}
#     @endif
#         
#     PUBLIC
#         
# )

# qt_import_qml_plugins(Cloud_Music_Player)

















# cmake_minimum_required(VERSION 3.16)
# 
# project(Cloud_Music_Player VERSION 0.1 LANGUAGES CXX)
# 
# @if !true
# set(CMAKE_AUTOMOC ON)
# @endif
# set(CMAKE_CXX_STANDARD_REQUIRED ON)
# 
# find_package(Qt6 6.4 REQUIRED COMPONENTS Quick)
# 
# @if true
# @if false
# qt_standard_project_setup(REQUIRES 6.5)
# @else
# qt_standard_project_setup()
# @endif
# @endif
# 
# qt_add_executable(appCloud_Music_Player
#     main.cpp
# )
# 
# qt_add_qml_module(appCloud_Music_Player
#     URI Cloud_Music_Player
#     VERSION 1.0
#     QML_FILES Main.qml
# )
# 
# # Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# # If you are developing for iOS or macOS you should consider setting an
# # explicit, fixed bundle identifier manually though.
# set_target_properties(appCloud_Music_Player PROPERTIES
# #    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appCloud_Music_Player
#     MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
#     MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
#     MACOSX_BUNDLE TRUE
#     WIN32_EXECUTABLE TRUE
# )
# 
# target_link_libraries(appCloud_Music_Player
#     PRIVATE Qt6::Quick
# )
# 
# include(GNUInstallDirs)
# install(TARGETS appCloud_Music_Player
#     BUNDLE DESTINATION .
#     LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
#     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
# )
