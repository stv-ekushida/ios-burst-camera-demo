# ios-burst-camera-demo
ios10 バーストカメラのデモ

|category | Version| 
|---|---|
| Swift | 3.0.2 |
| XCode | 8.2 |
| iOS | 10.0〜 |

#### 備忘録
1. AVFoundation.frameworkを追加する
2. Info.plistにNSCameraUsageDescriptionとNSPhotoLibraryUsageDescriptionを追加する

```
    <key>NSCameraUsageDescription</key>
    <string>カメラへアクセスするために必要です</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>アルバムへアクセスするために必要です</string>
```
