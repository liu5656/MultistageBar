//<?xml version="1.0" encoding="UTF-8" standalone="no"?>
//<document type="com.apple.InterfaceBuilder3.CocoaTouch.XIB" version="3.0" toolsVersion="13142" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES">
//    <dependencies>
//        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="12042"/>
//    </dependencies>
//    <objects>
//        <placeholder placeholderIdentifier="IBFilesOwner" id="-1" userLabel="File's Owner"/>
//        <placeholder placeholderIdentifier="IBFirstResponder" id="-2" customClass="UIResponder"/>
//    </objects>
//</document>


//attribute vec4 position; // 属性，如果绑定了这个属性，
//uniform  vec4 color; // 需要从程序中传入的值，一会我们会不断改变这个值
//varying lowp vec4 colorVarying; // 这个值需要和片段着色器的声明相同
//
//void main()
//{
//   gl_Position = position; // 设置顶点位置
//   colorVarying = color;  // 设置顶点颜色
// }


attribute vec4 position;
uniform vec4 color;
varying lowp vec4 colorVarying;

void main() {
    gl_Position = position;
    colorVarying = color;
}
