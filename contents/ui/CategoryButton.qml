// it won't work with any lower version (silent error)
import QtQuick 2.4

import org.kde.plasma.core 2.0 as PlasmaCore
// for using the button itself
import org.kde.plasma.components 2.0 as PlasmaComponents

// for using RowLayout
import QtQuick.Layouts 1.1

import QtQml.Models 2.4 as QM2


Rectangle { // rectangle used for marking the bounds for the category button

    id: containerForCategory

    // indexInModel is communicated to the applications grid to change the currently shown category. It's an index that may correspond to rootModel's index or may not (for example, when we want to show recent apps, recent docs or favorites).
    required property int indexInModel
    required property string categoryName

    // font size related properties
    required property bool customizeCategoriesFontSize
    required property int categoriesFontSize

    // button size related properties
    required property bool isButtonSizeSet
    required property int buttonHeight
    required property int buttonWidth

    // design size related properties
    required property bool showCategoriesIcon
    required property bool showCategoriesText
    required property bool showCategoriesIconAndText
    required property bool showCategoriesOnTheRight

    // behavior related properties
    required property bool showCategoriesTooltip
    readonly property bool showToolTip: (categoryTextId.truncated || showCategoriesIcon) && showCategoriesTooltip
    property int categoriesListIndex

    color: "transparent"
    height: isButtonSizeSet ? buttonHeight : t_metrics.height * 2
    width:  isButtonSizeSet ? buttonWidth : t_metrics.width + 4 * units.smallSpacing
    opacity: categoriesListIndex == QM2.ObjectModel.index || mouseArea.containsMouse ? 1 : 0.4

    signal changeCategoryRequested


    TextMetrics {
        id: t_metrics
        text: "Toutes les applications" // long-ass text for making sure most languages will have their applications tag visible out of the box.
        font.pointSize: theme.defaultFont.pointSize * 1.2
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 2 * units.smallSpacing
        anchors.rightMargin: 2 * units.smallSpacing

        layoutDirection: showCategoriesOnTheRight ? Qt.RightToLeft : Qt.LeftToRight


        PlasmaCore.IconItem {
            id: categoryIconId
            visible: showCategoriesIcon || showCategoriesIconAndText

            // arbitrary values because some icon packs cannot behave properly and need to be scaled down.
            Layout.preferredHeight: Math.floor(4 * parent.height / 5)
            Layout.preferredWidth: Math.floor(4 * parent.height / 5)
        }

        PlasmaComponents.Label { // label showing the category name
            id: categoryTextId
            text: categoryName

            // Using font sizes that are consistent with plasma
            font.pointSize: customizeCategoriesFontSize ? categoriesFontSize : theme.defaultFont.pointSize * 1.2
            minimumPointSize: containerForCategory.height

            visible: showCategoriesText || showCategoriesIconAndText
            Layout.preferredHeight: parent.height
            Layout.fillWidth: true
            fontSizeMode: Text.VerticalFit

            PlasmaCore.ToolTipArea { // for showing the tooltip linked to this category's name
                id: toolTip
                mainText: categoryName
            }

            // collapsing text when needed
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
        }


    }

    MouseArea { // I am using this MouseArea to recreate how a button would behave (just using Buttons didn't entirely work the way I intended.)
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: changeCategoryRequested()

        onEntered: { // show tooltips if the user wanted to.
            if (showToolTip) {
                toolTip.showToolTip()
            }
        }

        onExited: { // immediately hide tooltips if the user wanted them to be shown.
            if (showToolTip) {
                toolTip.hideToolTip()
            }

        }
    }

    function setSourceIcon(source) {
        categoryIconId.source = source
    }
}
