/***************************************************************************
 *   Copyright (C) 2014 by Weng Xuetian <wengxt@gmail.com>
 *   Copyright (C) 2013-2017 by Eike Hein <hein@kde.org>                   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.4

// for using RowLayout
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.kicker 0.1 as Kicker

import "../code/tools.js" as Tools
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4


// for vanilla scrollview
import QtQuick.Controls 2.15

Kicker.DashboardWindow {
    
    id: root

    property int iconSize:    plasmoid.configuration.iconSize // if iconSize == 48 then the icons' size will be 48x48. Enormous will make them look decent (in my screen, that is! :-) )

    property int cellSize: iconSize + Math.floor(1.5 * PlasmaCore.Theme.mSize(PlasmaCore.Theme.defaultFont).height)
        + (2 * PlasmaCore.Units.smallSpacing)
        + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
                        highlightItemSvg.margins.left + highlightItemSvg.margins.right))


    backgroundColor: "transparent"

    // whenever a key is pressed that is not "grabbed" by anything with focus by our application, the search field will react to it
    keyEventProxy: searchField


    property int rootWidth: width

    property int columns: Math.floor(0.8 * Math.ceil(width / cellSize))
    property int rows: Math.floor(0.75 * Math.ceil(height / cellSize))

    property int widthScreen:  columns * cellSize
    property int heightScreen: rows    * cellSize

    // this property is exposed because it will determine the behavior of the grid - whenenver we are searching, we will have only a grid dedicated to it. However, when we aren't, we may have two (if favorites support is enabled). It also determines which model we feed to the applications grid.
    property bool searching: searchField.text != ""

    // we will only show a grid dedicated towards favorites when the user tells us to do so and we have at least an application checked as favorite
    property bool showFavoritesInGrid: plasmoid.configuration.favoritesInGrid && globalFavorites.count > 0

    property bool showCategories: plasmoid.configuration.showCategories

    property real alphaValue: plasmoid.configuration.opacitySet ? plasmoid.configuration.alphaValue : 0.8

    // boolean values to manage how to show categories in their corresponing sidebar
    property bool showCategoriesIcon: plasmoid.configuration.categoriesIcon
    property bool showCategoriesText: plasmoid.configuration.categoriesText
    property bool showCategoriesIconAndText: plasmoid.configuration.categoriesIconAndText

    property bool showCategoriesTooltip: plasmoid.configuration.showCategoriesTooltip

    property bool showCategoriesOnTheRight: plasmoid.configuration.showCategoriesOnTheRight

    // boolean value to know whether or not the user wants the menu to drop the user right into the favorites section instead of the "All applications" section on startup.
    property bool startOnFavorites: plasmoid.configuration.startOnFavorites

    property bool customizeCategoriesSidebarSize: plasmoid.configuration.customizeCategoriesButtonSize
    property int categoriesSidebarWidth: plasmoid.configuration.categoriesButtonWidth

    // cool function to tweak transparency I took from the original launchpad
    function colorWithAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }

    onKeyEscapePressed: { // using escape for both closing the menu and stopping the search
        if (searching) {
            searchField.text = ""
        } else {
            root.toggle()
        }
    }

    onSearchingChanged: {
        if (!searching)
            reset()
    }

    onVisibleChanged: { // start fancy animation and preemptively return to a known state
        animationSearch.start()
        reset();
    }

    function updateCategories() { // this function is dedicated to constructing the applications categories list and preemptively updating it, should changes have been applied
        var categoryStartIndex = 0
        var categoryEndIndex = rootModel.count
        categoriesModel.clear() // given that we feed the model by appending items to it, it's only logical that we have to clear it every time we open the menu (just in case new applications have been installed)
        for (var i = categoryStartIndex; i < categoryEndIndex; i++) { // loop courtesy of Windows 10 inspired menu plasmoid

            if (i == 1 ) { // we are currently adding the category right after "All applications"
                // this is a great time to add Favorites support
                categoriesModel.append({"categoryText": i18n("Favorites"), "categoryIcon": "favorite", "categoryIndex": -1}) // we manually set -1 as category index to distinguish the Favorites category from the rest -- this for loop won't register Favorites as a category.
            }

            var modelIndex = rootModel.index(i, 0) // I don't know how this line works but it does
            var categoryLabel = rootModel.data(modelIndex, Qt.DisplayRole) // this is the name that will be shown in the list, say, "All applications", "Utilities", "Education", blah blah blah
            var categoryIcon = rootModel.data(modelIndex, Qt.DecorationRole)

            var aux = categoryIcon.toString().split('"') // the day the way this prints out changes I will have a huge problem

            //console.log("CAT:",categoryIcon)

            var index = i // we will use this index to swap categories inside the model that feeds our applications grid
            categoriesModel.append({"categoryText": categoryLabel, "categoryIcon": aux[1],"categoryIndex": index})
        }
    }

    function reset() { // return everything to the last known state
        if (!searching) {
            appsGrid.model = rootModel.modelForRow(0).modelForRow(1) // show all applications
        }

        if(showCategories) {
            updateCategories()
        } else {
            categoriesModel.clear() // always preemptively clean the categories model
        }

        appsGrid.focus = true
        searchField.text = "" // force placeholder text to be shown

        if (startOnFavorites) {
            //pageList.currentItem.itemGrid.model = rootModel.modelForRow(0).modelForRow(0) // show favorites
            if (showCategories) {
                categoriesList.currentIndex = 1 // highlight "Favorites" category
            }

        } else {
            //pageList.currentItem.itemGrid.model = rootModel.modelForRow(0).modelForRow(1) // show all applications
            if (showCategories) {
                categoriesList.currentIndex = 0 // highlight "All applications" category
            }
        }

    }

    mainItem:
        Rectangle {

            anchors.fill: parent
            color: 'transparent'

            MouseArea {

                id: mainItemRoot
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
                LayoutMirroring.childrenInherit: true

                ScaleAnimator{
                    id: animationSearch
                    from: 1.1
                    to: 1
                    target: mainItemRoot
                }

                onClicked: {
                    // when clicked inside this area and outside the applications grid or any cool buttons, register it as if the user wanted to get out of the menu
                    root.toggle();
                }

                Rectangle{
                    anchors.fill: parent
                    color: colorWithAlpha(theme.backgroundColor, alphaValue)
                }

                ColumnLayout {

                    id: mainColumn
                    anchors.fill: parent

                    SearchBar {

                        id: searchField
                        Layout.alignment: Qt.AlignCenter
                        Layout.fillWidth: true
                        Layout.topMargin: units.iconSizes.large
                        Layout.bottomMargin: units.iconSizes.medium
                    }

                    RowLayout {

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignCenter

                        layoutDirection: showCategoriesOnTheRight ? Qt.LeftToRight : Qt.RightToLeft

                        Item {
                            id: artifactForProperlyDisplayingEverythingInANiceWay
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ColumnLayout {

                                id: appsRectangle
                                anchors.fill: parent

                                ItemGridView { // this is the grid in which we will store the favorites list
                                    id: myFavorites
                                    model: globalFavorites
                                    visible: showFavoritesInGrid && !searching  // TODO this should be tied to whatever SearchBar is doing!!.
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.maximumHeight: cellSize
//                                     height: (showFavoritesInGrid && !searching) ? cellSize : 0
                                    //width: columns * cellSize
                                    cellWidth:  cellSize
                                    cellHeight: cellSize

                                    onKeyNavDown: {
                                        appsGrid.tryActivate(0, 0); // highlight first entry of our "All Applications" grid
                                    }

                                    onKeyNavUp: {
                                        searchField.focus = true;
                                    }
                                }

                                PlasmaCore.SvgItem { // nice line to separate favorites between all applications
                                    id: horizontalSeparator
                                    visible: showFavoritesInGrid && !searching
                                    Layout.fillHeight: true
                                    Layout.maximumHeight: (showFavoritesInGrid && !searching) ? Math.floor(PlasmaCore.Units.devicePixelRatio * 4) : 0
                                    Layout.preferredWidth: Math.round(widthScreen * 0.75)
                                    elementId: "horizontal-line"
                                    z: 1
                                    Layout.alignment: Qt.AlignCenter
                                    Layout.margins: units.iconSizes.smallMedium

                                    svg: PlasmaCore.Svg {
                                        imagePath: "widgets/line"
                                    }
                                }


                                ItemGridView { // this is actually the applications grid

                                    id: appsGrid
                                    visible: model.count > 0
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    Layout.maximumWidth: columns * cellSize
                                    Layout.alignment: Qt.AlignCenter

                                    //Rectangle { // debugging purposes.
                                        //z: -1
                                        //color: "red"
                                        //anchors.fill: parent
                                    //}

                                    //                                 Layout.preferredWidth: columns * cellSize


                                    cellWidth:  cellSize
                                    cellHeight: cellSize

                                    //dragEnabled: (index == 0)

                                    model: searching ? runnerModel.modelForRow(0) : rootModel.modelForRow(0).modelForRow(1) // if we happen to be searching, then we must show the results of said search. Else, we will default to showing all the applications

                                    //onCountChanged: { // whenever the list of icons has its cardinality modified, account for the change
                                    //currentIndex = 0
                                    //itemGrid.tryActivate(0, 0);
                                    //}

                                    onKeyNavUp: {
                                        currentIndex = -1;
                                        if (showFavoritesInGrid && !searching) {
                                            myFavorites.tryActivate(0,0)
                                        } else {
                                            searchField.focus = true;
                                        }
                                    }

                                    // onKeyNavDown: { //TODO: this needs some work to communicate where to return if we are pressing the "up" key on sessionControlBar
                                    //currentIndex = -1
                                    //sessionControlBar.tryActivate(0,0)
                                    //}

                                    onModelChanged: { // when we stop searching or start searching, highlight the first item just to give the user a hint that pressing "Enter" will launch the first entry.
                                        currentIndex = 0
                                        //appsGrid.itemGrid.tryActivate(0, 0);
                                    }
                                }

                            }
                        }

                        ScrollView { // dedicated to storing the categories list

                            id: categoriesItem

                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            //Layout.preferredWidth: categoriesModel.count == 0 ? 0 : (customizeCategoriesSidebarSize ? Math.min(categoriesSidebarWidth, Math.floor(widthScreen / 8)) : Math.floor(widthScreen / 8))
                            Layout.maximumWidth: categoriesModel.count == 0 ? 0 : (customizeCategoriesSidebarSize ? Math.ceil(categoriesSidebarWidth + units.iconSizes.medium) : Math.floor(widthScreen / 8 + units.iconSizes.medium)) // adding up a little bit of "artificial" size to let the category button breathe with respect to the sidebar's scrollbar.
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                            ListView {

                                id: categoriesList

                                anchors.fill: parent
                                model: ListModel {
                                    id: categoriesModel
                                }
                                delegate: CategoryButton {}
                                focus: true
                                // only add some fancy spacing between the buttons if they are only icons.
                                spacing: (showCategoriesText || showCategoriesIconAndText) ? 0 : units.iconSizes.small

                                // the following lines help maintaining consistency in highlighting with respect to whatever you have set in your Plasma Style. (This is taken from ItemGridDelegate.qml)
                                highlight: PlasmaComponents.Highlight {}
                                highlightFollowsCurrentItem: true
                                highlightMoveDuration: 0

                            }
                        }

                    }

                    SessionControlBar {
                        id: sessionControlBar
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter | Qt.AlignBottom
                        Layout.topMargin: units.iconSizes.medium
                        Layout.bottomMargin: units.iconSizes.smallMedium
                    }

                }




            }
        }

    Component.onCompleted: {
        rootModel.pageSize = -1 // this will, somehow, make it show everything -- again, don't ask me!
        kicker.reset.connect(reset);
        //console.log("Número de columnas", columns)
    }
}

