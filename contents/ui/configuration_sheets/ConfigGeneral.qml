/***************************************************************************
 *   Copyright (C) 2014 by Eike Hein <hein@kde.org>                        *
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

import QtQuick 2.0

import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

// SwipeView and Spinbox values
import QtQuick.Controls 2.2

Item {
    id: configGeneral

    property string cfg_icon: plasmoid.configuration.icon
    property bool cfg_useCustomButtonImage: plasmoid.configuration.useCustomButtonImage
    property string cfg_customButtonImage: plasmoid.configuration.customButtonImage

    property alias cfg_iconSize:      iconSize.value
    property alias cfg_favoritesIconSize: favoritesIconSize.value

    property alias cfg_isBackgroundImageSet: setBackgroundImageCheckbox.checked
    property alias cfg_backgroundImage: fileDialog.chosenPath

    property alias cfg_showLabelBackground: showBackgroundLabelCheckbox.checked
    property alias cfg_labelTransparency: labelAlphaValue.value

    property alias cfg_tooltipsInGrid: tooltipsInGrid.checked

    property alias cfg_favoritesInGrid: favoritesInGrid.checked
    property alias cfg_writeSomething: writeSomething.checked
    property alias cfg_greetingText: greetingText.text

    property alias cfg_opacitySet: opacitySetter.checked
    property alias cfg_alphaValue: alphaValue.value

    property alias cfg_clickToToggle: clickToToggle.checked

    property alias cfg_startOnFavorites: startOnFavorites.checked

    property alias cfg_paginateGrid: paginateGrid.checked
    property alias cfg_drawPaginationRectangle: drawPaginationRectangle.checked

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter

        PlasmaExtras.Heading {
            text: "Icons"
        }

        RowLayout {
            spacing: units.smallSpacing

            Label {
                text: i18n("Icon:")
            }

            IconPicker {
                currentIcon: cfg_icon
                defaultIcon: "start-here-kde"
                onIconChanged: cfg_icon = iconName
            }
        }

        RowLayout{
            Layout.fillWidth: true
            Label {
                Layout.leftMargin: units.smallSpacing
                text: i18n("Size of icons")
            }
            SpinBox{
                id: iconSize
                from: 24
                to: 256
                stepSize: 4
            }
        }

        PlasmaExtras.Heading {
            text: "Background and labels"
        }

        RowLayout{

            Row{
                spacing: units.smallSpacing
                CheckBox {
                    id: setBackgroundImageCheckbox
                    checked: false
                    text: i18n("Image background:")
                }

                Label {
                    id: backgroundImage
                    text: "Select image:"
                }

                Button {
                    id: imageButton
                    implicitWidth: height
                    PlasmaCore.IconItem {
                        anchors.fill: parent
                        source: "document-open-folder"
                        PlasmaCore.ToolTipArea {
                            anchors.fill: parent
                            subText: "Select image"
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {fileDialog.open() }
                    }
                }
                FileDialog {
                    id: fileDialog

                    property string chosenPath

                    selectMultiple : false
                    title: "Pick a image file"
                    nameFilters: [ "Image files (*.jpg *.png *.jpeg)", "All files (*)" ]
                    onAccepted: {
                        chosenPath = fileDialog.fileUrls[0]
//                         cfg_backgroundImage = backgroundImage.text
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: units.smallSpacing
            CheckBox{
                id: showBackgroundLabelCheckbox
                text: i18n("Add background to your applications' labels")
            }
        }

        RowLayout {
            Layout.fillWidth: true

            PlasmaComponents.Slider {
                id: labelAlphaValue
                enabled: showBackgroundLabelCheckbox.checked
            }

            PlasmaComponents.Label {
                id: labelAlphaValueText
                text: Math.floor(labelAlphaValue.value * 100) + "%"
                visible: showBackgroundLabelCheckbox.checked
            }
        }


        PlasmaExtras.Heading {
            text: "Layout"
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: units.smallSpacing
            CheckBox{
                id: tooltipsInGrid
                text: i18n("Show tooltips when hovering on an application")
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: units.smallSpacing
            CheckBox{
                id: favoritesInGrid
                text: i18n("Show favorite applications")
            }
        }

        RowLayout{
            Layout.fillWidth: true
            Label {
                Layout.leftMargin: units.smallSpacing
                text: i18n("Size of favorite icons")
            }
            SpinBox{
                id: favoritesIconSize
                from: 24
                to: 256
                stepSize: 4
            }
        }

        RowLayout {
            Layout.fillWidth: true
            CheckBox {
                Layout.leftMargin: units.smallSpacing
                id: writeSomething
                text: i18n("Write a greeting text")
            }
            PlasmaComponents.TextField {
                id: greetingText
                enabled: writeSomething.checked
            }
        }

        CheckBox {
            Layout.fillWidth: true
            Layout.leftMargin: units.smallSpacing
            id: paginateGrid
            text: i18n("Paginate the applications grid")
        }

        CheckBox {
            Layout.fillWidth: true
            Layout.leftMargin: units.smallSpacing
            id: drawPaginationRectangle
            text: i18n("Draw rectangle around the applications grid")
            visible: paginateGrid.checked
        }

        RowLayout {
            Layout.fillWidth: true

            CheckBox {
                Layout.leftMargin: units.smallSpacing
                id: opacitySetter
                text: i18n("Select the menu's opacity")
            }
        }

        RowLayout {
            Layout.fillWidth: true

            PlasmaComponents.Slider {
                id: alphaValue
                enabled: opacitySetter.checked
            }

            PlasmaComponents.Label {
                id: alphaValueText
                text: Math.floor(alphaValue.value * 100) + "%"
                visible: opacitySetter.checked
            }
        }

        PlasmaExtras.Heading {
            text: i18n("Behavior")
        }

        RowLayout {

            Layout.fillWidth: true

            CheckBox {
                Layout.leftMargin: units.smallSpacing
                id: clickToToggle
                text: i18n("Hide the menu by clicking in an empty region")
            }
        }

        PlasmaExtras.Heading {
            text: "Startup"
        }

        RowLayout {
            Layout.fillWidth: true

            CheckBox {
                Layout.leftMargin: units.smallSpacing
                id: startOnFavorites
                text: i18n("Start the menu on the \"Favorites\" category")
            }
        }

    }

}
